# encoding: utf-8

require_relative 'base_processor'

OB_REPLACE_FORM = lambda { |value| ("\"" if ["«", "»"].include?(value)) || value}

OB_REMOVE_LEMMA = lambda do |value|
  value = value.delete('*') if value.match('\w+')
  value = ("\"" if ["«", "»"].include?(value)) || value

  value
end

# Processor that does arbitrary text normalization.
class NormalizationProcessor < BaseProcessor
  def initialize(opts={})
    @proc_map = opts[:proc_map] || {}

    super(opts)
  end

  # Creates a normaliztion processor for OB and related corpora.
  # See BaseProcessor#new for options.
  #
  # @return [NormalizationProcessor]
  def self.ob_normalization_processor(opts={})
    opts[:proc_map] = { form: OB_REPLACE_FORM,
                        lemma: OB_REMOVE_LEMMA }
    NormalizationProcessor.new(opts)
  end

  def process(sent)
    sent[:words].each do |word|
      @proc_map.each_pair do |field, proc|
        word[field] = proc.call(word[field])
      end
    end

    sent
  end
end
