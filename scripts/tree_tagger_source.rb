require_relative 'base_source'

class TreeTaggerSource < BaseSource

  @@default_columns = [:form, :lemma, :tag]
  @@default_sent_tag = 'SENT'

  def initialize(file, opts={})
    @file = file
    @columns = opts[:columns] || @@default_columns
    @count = 0
    @sent_tag = opts[:sent_tag] || @@default_sent_tag

    super(opts[:processor] || nil)
  end

  def each
    until @file.eof?
      yield process
    end
  end

  def last_sentence_processed?
    return @file.eof?
  end

  def shift
    sent = {index: @count, words: next_sentence}
    @count += 1
    return sent
  end

  def next_sentence
    words = []

    while true
      begin
        line = @file.readline
      rescue EOFError
        return words
      end

      if line.chomp.empty?
        next
      end

      word = parse_line(line)

      words << word

      if word[:tag] == @sent_tag
        return words
      end
    end

    words
  end

  def parse_line(line)
    cols = line.chomp.split("\t")

    if cols.count != @columns.count
      raise RuntimeError
    end

    word = {}

    @columns.zip(cols) do |key, val|
      word[key] = val
    end

    return word
  end

  def reset
    @file.rewind
  end

  def size
    size_file = @file.clone
    stored_pos = @file.pos
    size_file.pos = 0

    size_reader = ConllSource.new size_file
    size_reader.to_a

    @file.pos = stored_pos

    return size_reader.count
  end
end
