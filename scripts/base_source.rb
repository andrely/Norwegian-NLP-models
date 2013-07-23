require_relative 'logger_mixin'

# Default behaviour for reader classes
class BaseSource
  include Enumerable
  include Logging

  def initialize(opts={})
    @processor = opts[:processor] || nil
    @id = opts[:id] || :unknown_processor
  end

  def process
    unless last_sentence_processed?
      sent = shift

      if @processor
        sent = @processor.process_internal sent
      end

      return sent
    else
      if @processor
        @processor.post_process_internal
      end

      return nil
    end
  end

  def process_all
    reset

    sent = process

    while sent
      sent = process
    end
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
    return false
  end

  def num_folds
    return 1
  end

  def pipeline_artifacts
    if @processor
      return @processor.pipeline_artifacts
    else
      return []
    end
  end
end
