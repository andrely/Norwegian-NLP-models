require_relative 'base_processor'

class NullProcessor < BaseProcessor
  def process(sent)
    return sent
  end
end
