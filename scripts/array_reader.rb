# Simple reader on array of sentences, mainly for testing
class ArrayReader < BaseReader
  def initialize(sentences)
    @sentences = sentences
  end

  def each(&block)
    @sentences.each(&block)
  end
end