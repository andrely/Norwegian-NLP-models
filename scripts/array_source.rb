require_relative 'base_source'
require_relative 'utilities'
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
    # copy sentence to maintain original form in case of source reset
    sent = Utilities.deep_copy @sentences[@pos]

    if not sent.has_key? :index
      sent[:index] = @pos
    end

    @pos += 1

    return sent
  end

  def size
    return @sentences.size
  end
end
