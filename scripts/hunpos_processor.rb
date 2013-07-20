require_relative 'base_processor'

class HunposProcessor < BaseProcessor

  attr_reader :num_folds, :descr

  def initialize(opts={})
    super(opts[:processor] || nil)

    @base_name = opts[:base_name] || nil
    @descr = opts[:descr] || nil
    @num_folds = opts[:num_folds] || 1

    if @base_name and @descr
      raise ArgumentError
    end
  end

  def process(sent)
    if not @descr
      @descr = create_descr(@base_name)
    end

    words = sent[:words]
    fold = get_fold sent
    len = words.count

    words.each_with_index do |word, i|
      form = word[:form]
      pos = word[:pos]

      if fold
        @descr.each_with_index do |fold_descr, i|
          if i == fold
            write_test_file fold_descr[:pred_file], form
            write_word fold_descr[:true_file], form, pos
          else
            write_word fold_descr[:in_file], form, pos
          end
        end
      else
        write_word @descr[0][:in_file], form, pos
      end
    end

    if fold
      @descr.each_with_index do |fold_descr, i|
        if i == fold
          fold_descr[:pred_file].puts
          fold_descr[:true_file].puts
        else
          fold_descr[:in_file].puts
        end
      end
    else
      @descr[0][:in_file].puts
    end

    return sent
  end

  def post_process
    @descr = @descr[0] unless has_folds?
  end

  def get_fold(sent)
    if has_folds?
      return sent[:fold]
    else
      return nil
    end
  end

  def write_word(file, form, pos)
    file.puts "#{form}\t#{pos}"
  end

  def write_test_file(file, form)
    file.puts form
  end

  def create_descr(base_name=nil)
    if base_name
      if has_folds?
        @descr = (0...num_folds).collect do |i|
          { in_file: File.new("#{base_name}_#{i}_in", 'w'),
            pred_file: File.new("#{base_name}_#{i}_pred", 'w'),
            true_file: File.new("#{base_name}_#{i}_true", 'w') }
        end
      else
        @descr = [{ in_file: File.new("#{base_name}_in", 'w') }]
      end
    else
      if has_folds?
        @descr = (0...num_folds).collect do |i|
          { in_file: StringIO.new,
            pred_file: StringIO.new,
            true_file: StringIO.new }
        end
      else
        # wraps single descr in array
        @descr = [{ in_file: StringIO.new }]
      end
    end

    return @descr
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
    return @num_folds > 1
  end
end