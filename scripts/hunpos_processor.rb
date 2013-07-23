require_relative 'base_processor'
require_relative 'artifact'

class HunposProcessor < BaseProcessor

  attr_reader :num_folds

  def initialize(opts={})
    super(opts)

    @base_name = opts[:base_name] || nil
    @artifact = opts[:artifact] || nil
    @num_folds = opts[:num_folds] || nil

    if @base_name and @artifact
      raise ArgumentError
    end
  end

  def process(sent)
    if not @artifact
      @artifact = create_artifact
    end

    words = sent[:words]
    fold = get_fold sent

    words.each_with_index do |word, i|
      form = word[:form]
      pos = word[:pos]

      if fold
        @artifact.fold_ids.each do |i|
          if i == fold
            write_test_file(@artifact.file(:pred, i), form)
            write_word(@artifact.file(:true, i), form, pos)
          else
            write_word(@artifact.file(:in, i), form, pos)
          end
        end
      else
        write_word(@artifact.file(:in), form, pos)
      end
    end

    if fold
      @artifact.fold_ids.each do |i|
        if i == fold
          @artifact.file(:pred, i).puts
          @artifact.file(:true, i).puts
        else
          @artifact.file(:in, i).puts
        end
      end
    else
      @artifact.file(:in).puts
    end

    return sent
  end

  def post_process
    @artifact.close
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

  def create_artifact
    Artifact.new(basename: @base_name,
                 num_folds: @num_folds,
                 files: :in,
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
    return (@num_folds and (@num_folds > 1))
  end
end
