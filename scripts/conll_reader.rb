class ConllReader
  include Enumerable

  @@default_columns = [:id, :form, :lemma, :pos, :ppos, :feat, :head, :deprel, :u1, :u2]

  def initialize(file, opts = {})
    @columns = opts[:columns] || @@default_columns
    @file = file
  end

  def each
    until @file.eof?
      yield next_sentence
    end
  end

  def next_sentence
    words = []

    begin
      line = @file.readline
    rescue EOFError
      return words
    end

    while line.chomp != ''
      cols = line.chomp.split("\t")

      if cols.count != @columns.count
        raise RuntimeError
      end

      word = {}

      @columns.zip(cols) do |key, val|
        word[key] = val
      end

      words << word

      begin
        line = @file.readline
      rescue EOFError
        return words
      end
    end

    words
  end

  def reset
    @file.rewind
  end

  def size
    size_file = @file.clone
    stored_pos = @file.pos
    size_file.pos = 0

    size_reader = ConllReader.new size_file

    count = 0

    size_reader.each { |sent| count += 1 }

    @file.pos = stored_pos

    return count
  end
end