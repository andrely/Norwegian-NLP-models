require_relative 'base_processor'
require_relative 'artifact'

class FrequencyStatisticsProcessor < BaseProcessor
  def initialize(opts={})
    @columns = opts[:columns] || [:form, :pos]
    @base_name = opts[:base_name] || nil
    @artifact = opts[:artifact] || nil

    @frequencies = {}
    @columns.each { |col| @frequencies[col] = Hash.new }

    super(opts)
  end

  def process(sent)
    sent[:words].each do |word|
      @columns.each do |col|
        add_to_frequencies(word[col], @frequencies[col])
      end
    end

    return sent
  end

  def post_process
    if @artifact.nil?
      @artifact = Artifact.new(basename: @base_name, id: @id, files: @columns)
    end

    @columns.each do |col|
      write_frequencies(@artifact.file(col), @frequencies[col])
    end

    @artifact.close
  end

  def write_frequencies(file, freq_hash)
    freq_hash.keys.sort.each do |k|
      file.puts("#{k}\t#{freq_hash[k]}")
    end
  end

  def add_to_frequencies(key, freq_hash)
    if freq_hash.has_key?(key)
      freq_hash[key] += 1
    else
      freq_hash[key] = 1
    end
  end
end
