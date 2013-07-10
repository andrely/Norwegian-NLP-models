class NullProcessor
  attr_accessor :num_folds

  def initialize
    @num_folds = 1
  end

  def process(sentence)
    return sentence
  end

  def post_process

  end
end
