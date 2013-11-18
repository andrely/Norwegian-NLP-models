require_relative 'base_processor'
require_relative '../utilities'

class PosProcessor < BaseProcessor
  OB_OPEN_CLASSES =
      ['det', 'det_dem', 'det_poss', 'konj', 'prep', 'pron', 'pron_pers', 'sbu']

  def initialize(opts={})
    super(opts)

    @lexicalize = opts[:lexicalize] || nil
    @open_classes = opts[:open_classes] || []
  end

  def self.ob_lexicalization_processor(opts={})
    opts[:lexicalize] = true
    opts[:open_classes] = OB_OPEN_CLASSES

    PosProcessor.new(opts)
  end

  def process(sent)
    sent[:words].each do |word|
      if @lexicalize and @open_classes.member?(word[:pos]) and word[:form].match(/^[A-Za-z]+$/)
        word[:pos] = "#{word[:pos]}_#{word[:form].downcase}"
      end
    end

    sent
  end
end
