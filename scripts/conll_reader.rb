class ConllReader
  include Enumerable

  @@default_columns = [:id, :form, :lemma, :pos, :ppos, :feat, :head, :deprel, :u1, :u2]

  def initialize(file, opts = {})
    @columns = opts[:columns] || @@default_columns
    @file = file
  end

  def each
    while not @file.eof?
      yield next_sentence
    end
  end

  def next_sentence
    words = []
    line = @file.readline

    while line.chomp != ""
      cols = line.chomp.split("\t")

      if cols.count != @columns.count
        raise RuntimeError
      end

      word = {}

      @columns.zip(cols) do |key, val|
        word[key] = val
      end

      words << word

      line = @file.readline
    end

    words
  end

  def reset
    @file.rewind
  end
end