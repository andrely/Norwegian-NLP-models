require 'stringio'

require_relative 'logger_mixin'
require_relative 'base_processor'
require_relative 'artifact'

class TreeTaggerProcessor < BaseProcessor
  attr_reader :num_folds

  @@nn_closed_class_pos = %w(subst verb ufl adj adv fork interj symb ukjent)

  # @option opts [String, NilClass] :base_name (nil) Base filename/path of the file artifacts.
  # @option opts [Artifact, NilClass] :artifact (nil) Properly initialized Artifact instance to write output to.
  # @option opts [Integer, NilClass] :num_folds (nil) Number of folds if using/creating a folded artifact.
  # *option opts [IO, NilClass] :lemma_collision_log_file (nil) Lemma collision log file (Closed on completion).
  def initialize(opts={})
    super(opts)

    @base_name = opts[:base_name] || nil
    @artifact = opts[:artifact] || nil
    @num_folds = opts[:num_folds] || 1
    @lemma_collision_log_file = opts[:lemma_collision_log] || nil

    if @base_name and @artifact
      raise ArgumentError
    end

    @lexicon = nil
    @open_classes = nil
  end

  def process(sent)
    if not @artifact
      @artifact = create_artifact()
    end

    if not @lexicon
      @lexicon = (1..@num_folds).collect { Hash.new }
    end

    if not @open_classes
      @open_classes = (1..@num_folds).collect { Array.new }
    end

    words = sent[:words]
    fold = get_fold sent
    len = words.count

    words.each_with_index do |word, i|
      form = word[:form]
      pos = word[:pos]
      lemma = word[:lemma]

      if i == len - 1 # last word, replace POS
        pos = 'SENT'
      end

      if fold
        @artifact.fold_ids.each do |j|
          if j == fold
            write_test_file(@artifact.file(:pred, j), form)
            write_true_word(@artifact.file(:true, j), form, pos, lemma)
          else
            write_word(@artifact.file(:in, j), form, pos)
            add_to_lexicon(@lexicon[j], word, form, pos)
            add_to_open_classes(@open_classes[j], word, pos)
          end
        end
      else
        write_word(@artifact.file(:in), form, pos)
        add_to_lexicon(@lexicon[0], word, form, pos)
        add_to_open_classes(@open_classes[0], word, pos)
      end
    end

    sent
  end

  def post_process
    create_lexicon_file(@artifact, @lexicon)

    create_open_class_file(@artifact, @open_classes)

    @lemma_collision_log_file.close if @lemma_collision_log_file
    @artifact.close
  end

  def create_open_class_file(artifact, open_classes)
    if has_folds?
      artifact.fold_ids.zip open_classes do |fold_id, fold_open_classes|
        artifact.file(:open, fold_id).write fold_open_classes.join(' ')
        artifact.file(:open, fold_id).write "\n"
      end
    else
      open_classes = open_classes[0]
      artifact.file(:open).write open_classes.join(' ')
      artifact.file(:open).write "\n"
    end
  end

  def create_lexicon_file(artifact, lexicon)
    if has_folds?
      artifact.fold_ids.zip lexicon do |fold_id, fold_lexicon|
        fold_lexicon.each_pair do |k, v|
          artifact.file(:lexicon, fold_id).write k

          v.each_pair do |pos, lemmas|
            artifact.file(:lexicon, fold_id).write "\t#{pos} #{lemmas.join('_')}"
          end

          artifact.file(:lexicon, fold_id).write "\n"
        end
      end
    else
      lexicon = lexicon[0]

      lexicon.each_pair do |k, v|
        artifact.file(:lexicon).write k

        v.each_pair do |pos, lemmas|
          artifact.file(:lexicon).write "\t#{pos} #{lemmas.join('_')}"
        end

        artifact.file(:lexicon).write "\n"
      end
    end
  end

  def add_to_open_classes(open_classes, word, pos)
    if @@nn_closed_class_pos.find { |p| p == word[:pos] } and not open_classes.find { |p| p == pos }
      open_classes << pos
    end
  end

  def log_lemma_collision(form, pos, combined_lemma)
    @lemma_collision_log_file.puts("#{form}\t#{pos}\t#{combined_lemma}") if @lemma_collision_log_file
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
        # lemma is actually combined when writing the lexicon file
        lookup[pos] << lemma
        log_lemma_collision(form, pos, lookup[pos].join('_'))
      end
    end
  end

  ##
  # @private
  def write_word(file, form, pos)
    file.write "#{form}\t#{pos}\n"
  end

  ##
  # @private
  def write_true_word(file, form, pos, lemma)
    file.write "#{form}\t#{pos}\t#{lemma}\n"
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

  def create_artifact
    Artifact.new(basename: @base_name,
                 num_folds: @num_folds,
                 files: [:in, :open, :lexicon],
                 id: @id)
  end

  def artifact
    if @artifact.nil?
      @artifact = create_artifact
    end

    return @artifact
  end

  def pipeline_artifacts
    if @processor
      return [@artifact] + @processor.pipeline_artifacts
    else
      return [@artifact]
    end
  end

  def num_folds=(n)
    if not @artifact
      @num_folds = n

      if @processor
        @processor.num_folds = n
      end
    else
      raise RuntimeError
    end
  end

  def has_folds?
    return @num_folds > 1
  end
end
