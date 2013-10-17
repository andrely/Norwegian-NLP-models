require_relative 'base_source'
require_relative '../test/utilities_test'

# Simple reader on array of sentences, mainly for testing
class ArraySource < BaseSource
  def initialize(sentences, opts={})
    @sentences = sentences
    @pos = 0

    super(opts)
  end

  def reset
    @pos = 0
  end

  def last_sentence_processed?
    (@pos >= @sentences.size)
  end

  def shift
    # copy sentence to maintain original form in case of source reset
    sent = Utilities.deep_copy @sentences[@pos]

    unless sent.has_key? :index
      sent[:index] = @pos
    end

    @pos += 1

    sent
  end

  def size
    @sentences.size
  end
end
