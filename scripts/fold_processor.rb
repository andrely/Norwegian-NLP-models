class FoldProcessor
  attr_reader :num_folds

  def initialize(processor, num_folds = 5)
    @processor = processor

    # TODO no way to call num_folds= here ?
    @num_folds = num_folds

    if @processor
      @processor.num_folds = @num_folds
    end
  end

  def process(sent)
    if sent.has_key? :fold
      raise ArgumentError
    end

    index = sent[:index]
    fold = index % @num_folds
    sent[:fold] = fold

    if @processor
      @processor.process sent
    end

    return sent
  end

  def post_process
    if @processor
      @processor.post_process
    end
  end

  def each
    @processor.each do |sent|
      if sent.has_key? :fold
        raise ArgumentError
      end

      index = sent[:index]
      fold = index % @num_folds
      sent[:fold] = fold

      yield sent
    end
  end

  def has_folds?
    return true
  end

  def num_folds=(n)
    @num_folds = n

    if @processor
      @processor.num_folds = @num_folds
    end
  end
end
