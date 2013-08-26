require_relative 'base_source'

class ConcatenatedSource < BaseSource
  def initialize(sources, opts={})
    @sources = sources
    @current_source = 0
    @count = 0
    @size = nil

    super(opts)
  end

  def reset
    @count = 0
    @current_source = 0
    @sources.each do |src|
      src.reset
    end
  end

  def processing_last_source?
    return @current_source >= (@sources.count - 1)
  end

  def last_sentence_processed?
    return (processing_last_source? and @sources.last.last_sentence_processed?)
  end

  def each
    until last_sentence_processed?
      yield process
    end
  end

  def shift
    if @sources[@current_source].last_sentence_processed?
      @current_source += 1

      return shift
    else
      sent = @sources[@current_source].shift
      sent[:inner_index] = [@current_source, sent[:index]]
      sent[:index] = @count

      @count += 1

      return sent
    end
  end

  def size
    if @size.nil?
      @size = @sources.inject(0) { |total, src| total + src.size }
    end

    return @size
  end

  def pipeline_artifacts
    return @processor.pipeline_artifacts + @sources.collect { |s| s.pipeline_artifacts }.flatten
  end
end
