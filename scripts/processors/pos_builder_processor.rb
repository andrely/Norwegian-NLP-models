# encoding: utf-8

require_relative 'base_processor'

OB_BASE_POS = [
    ['det', 'dem'],
    ['det', 'kvant'],
    ['det', 'poss'],
    ['pron', 'pers'],
    ['subst', 'appell'],
    ['verb', 'imp'],
    ['verb', 'inf'],
    ['verb', 'pret'],
    ['verb', 'pres'],
    ['verb', 'perf-part']]

OB_SEP = [' ', "|"]

OB_PART_FILTER = ['<contok>', '<ikke-clb>', 'clb', '((i|pa|tr|pr|r|rl|a|d|n)\d+(\/til)?)']

##
# Processor for sources read from SB Gull or OBT development corpora.
# Cleans up POS and feature information on words:
# - Removes extranous clb, contok and syntactic features
# - collects bare POS information in :pos field
# - Puts remaining information in :feat field, sorted alphabetically
class PosBuilderProcessor < BaseProcessor

  # @option opts [Enumerable] pos_list List of multiple POS parts corresponding to base POS information.
  # @option opts [Array<String>] sep List of characters separating pos/feature parts.
  # @option opts [Array<String>] part_filter List of POS/feature parts to remove.
  def initialize(opts={})
    @pos_list = opts[:pos_list] || []
    @sep = opts[:sep] || [' ']
    @sep_regex = /[#{@sep.collect { |s| Regexp.quote(s) }.join()}]/
    @part_filter = opts[:part_filter] || []
    @part_filter_regex = /^(#{@part_filter.join('|')})$/

    super(opts)
  end

  # Return POS/feature builder for OB data.
  #
  # @return [PosBuilderProcessor]
  def self.ob_pos_builder(opts={})
    if opts[:expand_tags]
      opts[:pos_list] = OB_BASE_POS
    end

    opts[:sep] = OB_SEP
    opts[:part_filter] = OB_PART_FILTER

    PosBuilderProcessor.new(opts)
  end

  def process(sent)
    sent[:words].each do |word|
      # combine all parts
      pos = word[:pos]
      feat = word[:feat] || ''
      feat = '' if feat == '_'

      parts = (pos.split(@sep_regex) + feat.split(@sep_regex)).uniq
      parts.delete_if { |part| @part_filter_regex.match(part)}

      # split pos/feat
      word[:pos], word[:feat] = extract_pos(parts)

    #  # TODO process the forms in a dedicated processor
    #  word[:form] = "\"" if ["«", "»"].include?(word[:form])
    #
    #  # TODO lemmas should have the case properly restored
    #  word[:lemma] = word[:lemma].delete('*') if word[:lemma].match('\w+')
    end

    sent
  end

  ##
  # @private
  # Extracts the bare pos from other features
  def extract_pos(parts)
    @pos_list.each do |pos_parts|
      if pos_parts.all? { |part| parts.include?(part) }
        parts.delete_if { |part| pos_parts.include?(part) }

        return pos_parts.join('_'), parts.sort
      end
    end

    return parts[0].to_s, (parts[1..-1] || []).sort
  end
end
