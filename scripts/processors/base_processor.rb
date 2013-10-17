require_relative '../logger_mixin'

class BaseProcessor
  attr_accessor :source
  attr_reader :processor

  include Logging

  def initialize(opts={})
    @processor = self.processor = opts[:processor] if opts[:processor]
    @source = nil
    @id = opts[:id] || :unknown_processor

    logger.info("Initializing #{self.class.name} id: #{@id}")
  end

  def process(sent)
    raise NotImplementedError
  end

  def process_internal(sent)
    sent = process(sent)

    if @processor
      sent = @processor.process_internal sent
    end

    sent
  end

  def pre_process
    # default is no preprocessing
  end

  def pre_process_internal
    pre_process

    if @processor
      @processor.pre_process_internal
    end

    nil
  end

  def post_process
    # default is no postprocessing
  end

  def post_process_internal
    post_process

    if @processor
      @processor.post_process_internal
    end

    nil
  end

  def pipeline_artifacts
    if @processor
      @processor.pipeline_artifacts
    else
      []
    end
  end

  def size
    @source.size if @source else nil
  end

  def processor=(processor)
    @processor = processor
    processor.source = self
  end
end
