require_relative '../logger_mixin'

# Default behaviour for reader classes
class BaseSource

  include Enumerable
  include Logging

  attr_accessor :processor

  def initialize(opts={})
    self.processor = opts[:processor] if opts[:processor]
    @id = opts[:id] || :unknown_processor

    logger.info("Initializing #{self.class.name} id: #{@id}")
  end

  def process
    unless last_sentence_processed?
      sent = shift

      if @processor
        sent = @processor.process_internal sent
      end

      sent
    end
  end

  def each
    if @processor
      @processor.pre_process_internal
    end

    until last_sentence_processed?
      yield process
    end

    if @processor
      @processor.post_process_internal
    end
  end

  def process_all
    reset

    self.to_a
  end

  def reset
    raise NotImplementedError
  end

  def last_sentence_processed?
    raise NotImplementedError
  end

  def shift
    raise NotImplementedError
  end

  def size
    raise NotImplementedError
  end

  def has_folds?
    false
  end

  def num_folds
    1
  end

  def pipeline_artifacts
    if @processor
      @processor.pipeline_artifacts
    else
      []
    end
  end

  def processor=(processor)
    @processor = processor
    processor.source = self
  end
end
