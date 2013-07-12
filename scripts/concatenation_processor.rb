class ConcatenationProcessor
  def initialize(processor_list)
    @processors = processor_list
  end

  def process_internal(sent)
    sents = @processors.collect do |proc|
      if proc
        proc.process_internal sent
      end
    end

    return sents
  end

  def post_process_internal
    @processors.each do |proc|
      if proc
        proc.post_process_internal
      end
    end

    return nil
  end

  def num_folds=(n)
    @processors.each do |proc|
      if proc
        proc.num_folds = n
      end
    end
  end

  def has_folds?
    return false
  end
end
