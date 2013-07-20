require_relative 'base_processor'

class POSBuilderProcessor < BaseProcessor
  def process(sent)
    sent[:words].each do |word|
      if word.has_key? :feat and word[:feat] != '_'
        pos = word[:pos]
        word[:pos_bare] = pos
        pos = pos + '_' + word[:feat].split('|').join('_')
        word[:pos] = pos
      end
    end

    return sent
  end
end
