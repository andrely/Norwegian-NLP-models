require_relative '../logger_mixin'

class BaseProcessor

  include Logging

  def initialize(opts={})
    @processor = opts[:processor] || nil
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

    return sent
  end

  def post_process
    # default is no postprocessing
  end

  def post_process_internal
    post_process

    if @processor
      @processor.post_process_internal
    end

    return nil
  end

  def pipeline_artifacts
    if @processor
      return @processor.pipeline_artifacts
    else
      return []
    end
  end
end
