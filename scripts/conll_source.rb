require_relative 'utilities'
require_relative 'base_source'

class ConllSource < BaseSource
  attr_reader :count

  @@default_columns = [:id, :form, :lemma, :pos, :ppos, :feat, :head, :deprel, :u1, :u2]

  def initialize(file, opts = {})
    @columns = opts[:columns] || @@default_columns
    @file = file
    @count = 0
    @line_no = 0

    @size = nil

    super(opts)
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
      @line_no += 1
    rescue EOFError
      return words
    end

    while line.chomp != ''
      word = parse_line(line)
      word[:line_no] = @line_no

      words << word

      begin
        line = @file.readline
        @line_no += 1
      rescue EOFError
        return words
      end
    end

    words
  end

  def parse_line(line)
    cols = line.chomp.split("\t")

    if cols.count != @columns.count
      raise "Error parsing line #{@line_no}, #{cols.count} columns found instead of #{@columns.count}"
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

  ##
  # Accessor for the size of the corpus, ie. the number of sentences.
  # @note On first access the whole corpus is read. The size is cached on further accesses.
  # @return [Integer]
  def size
    if @size.nil?
      size_file = @file.clone
      stored_pos = @file.pos
      size_file.pos = 0

      size_reader = ConllSource.new(size_file, columns: @columns)
      size_reader.to_a

      @file.pos = stored_pos

      @size = size_reader.count
    end

    return @size
  end
end
