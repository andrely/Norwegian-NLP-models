require_relative 'base_source'

class TreeTaggerSource < BaseSource

  DEFAULT_COLUMNS = [:form, :lemma, :pos]
  DEFAULT_SENT_POS = 'SENT'

  def initialize(file, opts={})
    @file = file
    @columns = opts[:columns] || DEFAULT_COLUMNS
    @count = 0
    @sent_pos = opts[:sent_pos] || DEFAULT_SENT_POS

    super(opts)
  end

  def last_sentence_processed?
    @file.eof?
  end

  def shift
    sent = {index: @count, words: next_sentence}
    @count += 1
    sent
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

      if word[:pos] == @sent_pos
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

    word
  end

  def reset
    @count = 0
    @file.rewind
  end

  def size
    size_file = @file.clone
    stored_pos = @file.pos
    size_file.pos = 0

    size_reader = ConllSource.new size_file
    size_reader.to_a

    @file.pos = stored_pos

    size_reader.count
  end
end
