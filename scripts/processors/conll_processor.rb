require_relative 'base_processor'
require_relative '../artifact'

##
# Processor writing CONLL format tab separated files.
#
# @todo Support folds
class ConllProcessor < BaseProcessor
  DEFAULT_COLUMNS = [:id, :form, :lemma, :pos, :ppos, :feat, :head, :deprel, :u1, :u2]
  DEFAULT_PRED_COLUMNS = [:id, :form, :lemma, :pos, :ppos, :feat]
  DEFAULT_COLUMN_VALUE = '_'

  def initialize(opts={})
    super(opts)

    @base_name = opts[:base_name] || nil
    @artifact = opts[:artifact] || nil
    @columns = opts[:columns] || DEFAULT_COLUMNS
    @pred_columns = opts[:pred_columns] || DEFAULT_PRED_COLUMNS

    if @base_name and @artifact
      raise ArgumentError
    end
  end

  def process(sent)
    words = sent[:words]

    words.each do |word|
      write_word(artifact.file(:in), word, @columns)
      write_word(artifact.file(:in_pred), word, @pred_columns)
    end

    artifact.file(:in).puts
    artifact.file(:in_pred).puts

    sent
  end

  def post_process
    artifact.close
  end


  ##
  # @private
  def write_word(file, word, columns)
    line = columns.collect { |col| (word[col] || DEFAULT_COLUMN_VALUE).to_s }

    file.puts(line.join("\t"))
  end

  def artifact
    if @artifact.nil?
      @artifact = Artifact.new(base_name: @base_name, files: [:in, :in_pred], id: @id)
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
end
