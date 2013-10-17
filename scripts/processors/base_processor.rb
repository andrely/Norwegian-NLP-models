require_relative '../logger_mixin'

# @abstract Base class for processors.
#   Processors should override {#processs} and optionally {#pre_process}
#   and {#post_process}.
class BaseProcessor

  attr_accessor :source
  attr_reader :processor

  include Logging

  # @option opts [BaseProcessor] processor Downstream processor.
  # @option opts [String, Symbol] id Textual identifier used in logs etc.
  def initialize(opts={})
    @processor = self.processor = opts[:processor] if opts[:processor]
    @source = nil
    @id = opts[:id] || :unknown_processor

    logger.info("Initializing #{self.class.name} id: #{@id}")
  end

  # Process a single sentence.
  # @param [Hash] sent Hash instance with index and words entries.
  # @return [Hash] Processed sentence instance. May be a copy.
  def process(sent)
    raise NotImplementedError
  end

  # @private
  def process_internal(sent)
    sent = process(sent)

    if @processor
      sent = @processor.process_internal sent
    end

    sent
  end

  # Preprocess hook called before any sentences are processed.
  def pre_process
    # default is no preprocessing
  end

  # @private
  def pre_process_internal
    pre_process

    if @processor
      @processor.pre_process_internal
    end

    nil
  end

  # Postprocess hook called after all sentences have been processed.
  def post_process
    # default is no postprocessing
  end

  # @private
  def post_process_internal
    post_process

    if @processor
      @processor.post_process_internal
    end

    nil
  end

  # Return all artifacts produced by this and downstream processors.
  def pipeline_artifacts
    if @processor
      @processor.pipeline_artifacts
    else
      []
    end
  end

  # Number of sentences in source
  def size
    @source.size if @source
  end

  def processor=(processor)
    @processor = processor
    # inject reference to self in downstream processor
    processor.source = self
  end
end
