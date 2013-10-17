require_relative '../utilities'

class ConcatenationProcessor
  attr_accessor :source
  attr_reader :processors

  def initialize(processor_list)
    @processors = processor_list
    @source = nil
  end

  def process_internal(sent)
    self.processors.collect do |proc|
      if proc
        new_sent = Utilities.deep_copy sent
        proc.process_internal new_sent
      end
    end
  end

  def pre_process_internal
    self.processors.each do |proc|
      if proc
        proc.pre_process_internal
      end
    end
  end

  def post_process_internal
    self.processors.each do |proc|
      if proc
        proc.post_process_internal
      end
    end

    nil
  end

  def num_folds=(n)
    self.processors.each do |proc|
      if proc
        proc.num_folds = n
      end
    end
  end

  def has_folds?
    false
  end

  def pipeline_artifacts
    self.processors.collect { |p| p.pipeline_artifacts }.flatten
  end
end
