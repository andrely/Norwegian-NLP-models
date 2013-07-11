require_relative 'utilities'
require_relative 'base_source'
require_relative 'null_processor'

class ConllSource < BaseSource
  attr_reader :count

  @@default_columns = [:id, :form, :lemma, :pos, :ppos, :feat, :head, :deprel, :u1, :u2]

  def initialize(file, processor, opts = {})
    @columns = opts[:columns] || @@default_columns
    @file = file
    @count = 0

    super(processor)
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

    begin
      line = @file.readline
    rescue EOFError
      return words
    end

    while line.chomp != ''
      word = parse_line(line)

      words << word

      begin
        line = @file.readline
      rescue EOFError
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
    @file.rewind
  end

  def size
    size_file = @file.clone
    stored_pos = @file.pos
    size_file.pos = 0

    size_writer = NullProcessor.new
    size_reader = ConllSource.new size_file, size_writer
    size_reader.to_a

    @file.pos = stored_pos

    return size_reader.count
  end
end
