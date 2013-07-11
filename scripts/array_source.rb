require_relative 'base_source'

# Simple reader on array of sentences, mainly for testing
class ArraySource < BaseSource
  def initialize(sentences, processor)
    @sentences = sentences
    @pos = 0

    super(processor)
  end

  def reset
    @pos = 0
  end

  def each(&block)
    sent = process

    while sent
      yield sent

      sent = process
    end
  end

  def last_sentence_processed?
    return @pos >= @sentences.size
  end

  def shift
    sent = @sentences[@pos]
    @pos += 1

    return sent
  end

  def size
    return @sentences.size
  end
end
