require_relative 'base_processor'

class FoldProcessor < BaseProcessor
  attr_reader :num_folds

  def initialize(opts = {})
    super(opts[:processor] || nil)

    # TODO no way to call num_folds= here ?
    @num_folds = opts[:num_folds] || 5

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

    return sent
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
