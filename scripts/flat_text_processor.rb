require_relative 'base_processor'
require_relative 'artifact'

##
# This processor writes a source to flat text files of the tokenized source text, ie. whitespace separated
# word form elements with one sentence for each line.
# @note Does not support folds.

class FlatTextProcessor < BaseProcessor

  ##
  # @option opts [Artifact] :artifact Fully initialized Artifact instance.
  # @option opts [String] :basename Pathname base for generated file artifacts.
  def initialize(opts={})
    super(opts)

    @artifact = opts[:artifact] || nil
    @basename = opts[:basename] || nil
  end

  def process(sent)
    if @artifact.nil?
      @artifact = Artifact.new(basename: @basename, files: [:flat], id: @id)
    end

    write_sent(@artifact.file(:flat), sent)
    
    sent
  end


  def post_process
    @artifact.close
  end

  ##
  # @private
  def write_sent(file, sent)
    words = sent[:words].collect { |w| w[:form] }

    file.puts(words.join(' '))
  end

  def pipeline_artifacts
    if @processor
      [@artifact] + @processor.pipeline_artifacts
    else
      [@artifact]
    end
  end
end
