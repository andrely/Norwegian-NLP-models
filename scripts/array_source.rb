require_relative 'base_reader'
require_relative 'logger_mixin'

# Simple reader on array of sentences, mainly for testing
class ArraySource < BaseReader
  include Enumerable
  include Logging

  def initialize(sentences, processor)
    @sentences = sentences
    @processor = processor
    @pos = 0
  end

  def process
    if @pos < @sentences.size
      sent = @processor.process @sentences[@pos]
      @pos += 1

      return sent
    else
      @processor.post_process

      return nil
    end
  end

  def process_all
    unless @pos == 0
      logger.warn "ArrayReader position not at 0, processing from #{pos}"
    end

    sent = process

    while sent
      sent = process
    end
  end

  def each(&block)
    sent = process

    while sent
      yield sent

      sent = process
    end
  end
end
