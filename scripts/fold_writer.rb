class FoldWriter
  def initialize(reader)
    @reader = reader
    @sentence_count = get_sentence_count @reader
  end

  def get_sentence_count(reader)
    return reader.size
  end

end