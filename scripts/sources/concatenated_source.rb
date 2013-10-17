require_relative 'base_source'

class ConcatenatedSource < BaseSource
  attr_reader :sources

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
    self.sources.each do |src|
      src.reset
    end
  end

  def processing_last_source?
    (@current_source >= (self.sources.count - 1))
  end

  def last_sentence_processed?
    (processing_last_source? and self.sources.last.last_sentence_processed?)
  end

  def shift
    if self.sources[@current_source].last_sentence_processed?
      @current_source += 1

      shift
    else
      sent = self.sources[@current_source].shift
      sent[:inner_index] = [@current_source, sent[:index]]
      sent[:index] = @count

      @count += 1

      sent
    end
  end

  def size
    if @size.nil?
      @size = self.sources.inject(0) { |total, src| total + src.size }
    end

    @size
  end

  def pipeline_artifacts
    @processor.pipeline_artifacts + self.sources.collect { |s| s.pipeline_artifacts }.flatten
  end
end
