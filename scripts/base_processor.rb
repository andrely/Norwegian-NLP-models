class BaseProcessor
  def initialize(processor=nil)
    @processor = processor
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
end