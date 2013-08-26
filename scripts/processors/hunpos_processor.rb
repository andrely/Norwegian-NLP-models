require_relative 'base_processor'
require_relative '../artifact'

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
    if @artifact.nil?
      @artifact = create_artifact
    end

    words = sent[:words]
    fold = get_fold sent

    words.each_with_index do |word, _|
      form = word[:form]
      pos = word[:pos]

      if fold
        @artifact.fold_ids.each do |i|
          if i == fold
            write_test_file(@artifact.file(:pred, i), form)
            write_word(@artifact.file(:true, i), form, pos)
          else
            write_word(@artifact.file(:in, i), form, pos)
            write_test_file(@artifact.file(:in_pred, i), form)
          end
        end
      else
        write_word(@artifact.file(:in), form, pos)
        write_test_file(@artifact.file(:in_pred), form)
      end
    end

    if fold
      @artifact.fold_ids.each do |i|
        if i == fold
          @artifact.file(:pred, i).puts
          @artifact.file(:true, i).puts
        else
          @artifact.file(:in, i).puts
          @artifact.file(:in_pred, i).puts
        end
      end
    else
      @artifact.file(:in).puts
      @artifact.file(:in_pred).puts
    end

    sent
  end

  def post_process
    @artifact.close
  end

  def get_fold(sent)
    if has_folds?
      sent[:fold]
    else
      nil
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
                 files: [:in, :in_pred],
                 id: @id)
  end

  def artifact
    if @artifact.nil?
      @artifact = create_artifact
    end

    @artifact
  end

  def pipeline_artifacts
    if @processor
      [@artifact] + @processor.pipeline_artifacts
    else
      [@artifact]
    end
  end

  def num_folds=(n)
    if @artifact.nil?
      @num_folds = n

      if @processor
        @processor.num_folds = n
      end
    else
      raise RuntimeError
    end
  end

  def has_folds?
    (@num_folds and (@num_folds > 1))
  end
end
