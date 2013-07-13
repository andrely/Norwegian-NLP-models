require 'stringio'

require_relative 'logger_mixin'
require_relative 'base_processor'

class TreeTaggerProcessor < BaseProcessor
  attr_reader :descr, :num_folds

  include Logging

  @@nn_closed_class_pos = %w(subst verb ufl adj adv fork interj symb ukjent)

  def initialize(opts={})
    super()

    @base_name = opts[:base_name] || nil
    @descr = opts[:descr] || nil
    @num_folds = opts[:num_folds] || 1

    if @base_name and @descr
      raise ArgumentError
    end

    @lexicon = nil
    @open_classes = nil
  end

  def process(sent)
    if not @descr
      @descr = create_descr(@base_name)
    end

    if not @lexicon
      @lexicon = (1..@num_folds).collect { |i| Hash.new }
    end

    if not @open_classes
      @open_classes = (1..@num_folds).collect { |i| Array.new }
    end

    words = sent[:words]
    fold = get_fold sent
    len = words.count

    words.each_with_index do |word, i|
      form = word[:form]
      pos = word[:pos]

      if word[:feat] != '_'
        pos = pos + '_' + word[:feat].split('|').join('_')
      end

      if i == len - 1 # last word, replace POS
        pos = 'SENT'
      end

      if fold
        @descr.each_with_index do |fold_descr, i|
          if i == fold
            write_test_file fold_descr[:pred_file], form
            write_word fold_descr[:true_file], form, pos
          else
            write_word fold_descr[:in_file], form, pos
            add_to_lexicon(@lexicon[i], word, form, pos)
            add_to_open_classes(@open_classes[i], fold, word, pos)
          end
        end
      else
        write_word @descr[0][:in_file], form, pos
        add_to_lexicon(@lexicon[0], word, form, pos)
        add_to_open_classes(@open_classes[0], fold, word, pos)
      end
    end

    return sent
  end

  def post_process
    create_lexicon_file(@descr, @lexicon)

    create_open_class_file(@descr, @open_classes)

    close_descr @descr

    @descr = @descr[0] unless has_folds?
  end

  def create_open_class_file(descr, open_classes)
    descr.zip open_classes do |fold_descr, fold_open_classes|
      fold_descr[:open_class_file].write fold_open_classes.join(' ')
      fold_descr[:open_class_file].write "\n"
    end
  end

  def create_lexicon_file(descr, lexicon)
    descr.zip lexicon do |fold_descr, fold_lexicon|
      fold_lexicon.each_pair do |k, v|
        fold_descr[:lex_file].write k

        v.each_pair do |pos, lemmas|
          fold_descr[:lex_file].write "\t#{pos} #{lemmas.join('_')}"
        end

        fold_descr[:lex_file].write "\n"
      end
    end
  end

  def add_to_open_classes(open_classes, fold, word, pos)
    if @@nn_closed_class_pos.find { |p| p == word[:pos] } and not open_classes.find { |p| p == pos }
      open_classes << pos
    end
  end

  def add_to_lexicon(lexicon, word, form, pos)
    lex_form = word[:form].downcase

    lemma = word[:lemma].downcase

    lookup = lexicon[lex_form]

    if not lookup
      lexicon[lex_form] = {pos => [lemma]}
    elsif not lookup.has_key? pos
      lookup[pos] = [lemma]
    elsif lookup.has_key? pos
      unless lookup[pos].detect { |l| l == lemma }
        lookup[pos] << lemma
        logger.info "Combining lemma #{lookup[pos].join('_')} for form #{form}, pos #{pos}"
      end
    end
  end

  def write_word(file, form, pos)
    file.write "#{form}\t#{pos}\n"
  end

  def write_test_file(file, form)
    file.write "#{form}\n"
  end

  def get_fold(sent)
    if has_folds?
      return sent[:fold]
    else
      return nil
    end
  end

  # TODO Hacky, rewrite this
  def create_descr(base_name=nil)
    if base_name
      if has_folds?
        @descr = (0...num_folds).collect do |i|
          { in_file: File.new("#{base_name}_#{i}_in", 'w'),
            pred_file: File.new("#{base_name}_#{i}_pred", 'w'),
            true_file: File.new("#{base_name}_#{i}_true", 'w'),
            lex_file: File.new("#{base_name}_#{i}_lex", 'w'),
            open_class_file: File.new("#{base_name}_#{i}_open", 'w') }
        end
      else
        @descr = [{ in_file: File.new("#{base_name}_in", 'w'),
                    lex_file: File.new("#{base_name}_lex", 'w'),
                    open_class_file: File.new("#{base_name}_open", 'w') }]
      end
    else
      if has_folds?
        @descr = (0...num_folds).collect do |i|
          { in_file: StringIO.new,
            pred_file: StringIO.new,
            true_file: StringIO.new,
            lex_file: StringIO.new,
            open_class_file: StringIO.new }
        end
      else
        # wraps single descr in array
        @descr = [{ in_file: StringIO.new,
                    lex_file: StringIO.new,
                    open_class_file: StringIO.new }]
      end
    end

    return @descr
  end

  def close_descr(descr)
    descr.each do |fold_descr|
      fold_descr.each_value { |file| file.close unless file.closed? }
    end

    return descr
  end

  def num_folds=(n)
    if not @descr
      @num_folds = n

      if @processor
        @processor.num_folds = n
      end
    else
      raise RuntimeError
    end
  end

  def has_folds?
    return num_folds > 1
  end
end
