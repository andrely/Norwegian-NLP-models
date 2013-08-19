# encoding: utf-8

require_relative 'base_processor'

##
# Processor for sources read from SB Gull or OBT development corpora.
# Cleans up POS and feature information on words:
# - Removes extranous clb, contok and syntactic features
# - collects bare POS information in :pos field
# - Puts remaining information in :feat field, sorted alphabetically

class POSBuilderProcessor < BaseProcessor
  FEAT_SEP = '#'
  CLEAN_TAG_REGEX = Regexp.compile('((i|pa|tr|pr|r|rl|a|d|n)\d+(\/til)?)')

  def process(sent)
    sent[:words].each do |word|
      # first join together the pos and any features
      if word.has_key? :feat and word[:feat] != '_'
        pos = word[:pos] + ' ' + (word[:feat].split('|')).join(' ')
      else
        pos = word[:pos]
      end

      # clean up the pos like in OBT-Stat
      pos = clean_out_tag(pos).downcase

      # split up back into pos/features list
      parts = pos.split(FEAT_SEP)
      pos = parts.shift
      parts.uniq!

      # remove unwanted features
      parts.delete_if { |p| ['<contok>', '<ikke-clb>', 'clb'].include?(p) }
      parts.sort!

      # construct full pos
      pos, parts = get_base_tag(pos, parts)

      word[:pos] = pos
      word[:feat] = parts

      # TODO process the forms in a dedicated processor
      word[:form] = "\"" if ["«", "»"].include?(word[:form])

      # TODO lemmas should heve the case properly restored
      word[:lemma] = word[:lemma].delete('*') if word[:lemma].match('\w+')
    end

    sent
  end

  ##
  # @private
  # Copied from OBT-Stat
  def clean_out_tag(pos)
    # remove unnecessary info from the tag field for "joined words". These words
    # uniquely have a @ in their tag, with the tag being the token in front of this.
    #
    # ie. "prep+subst prep @adv" is turned into "prep" from the middle field
    if pos.match('@')
      pos = pos.gsub(/^[\w\+]+\s(\w+)\s@.+$/, '\1')
    end

    # we treat clb marked punctuation the same as unmarked
    if pos.match(/^clb /)
      pos = pos.gsub(/^clb (.*)$/, '\1')
    end

    pos.gsub(CLEAN_TAG_REGEX, '').strip.gsub(/\s+/, FEAT_SEP)
  end

  ##
  # @private
  # Extracts the bare pos from other features
  def get_base_tag(pos, parts)
    if pos == 'det' and parts.include?('dem')
      pos = 'det_dem'
      parts.delete('dem')
    elsif pos == 'det' and parts.include?('kvant')
      pos = 'det_kvant'
      parts.delete('kvant')
    elsif pos == 'det' and parts.include?('poss')
      pos = 'det_poss'
      parts.delete('poss')
    elsif pos == 'pron' and parts.include?('pers')
      pos = 'pron_pers'
      parts.delete('pers')
    elsif pos == 'subst' and parts.include?('appell')
      pos = 'subst_appell'
      parts.delete('appell')
    elsif pos == 'verb' and parts.include?('imp')
      pos = 'verb_imp'
      parts.delete('imp')
    elsif pos == 'verb' and parts.include?('inf')
      pos = 'verb_inf'
      parts.delete('inf')
    elsif pos == 'verb' and parts.include?('pret')
      pos = 'verb_pret'
      parts.delete('pret')
    elsif pos == 'verb' and parts.include?('pres')
      pos = 'verb_pres'
      parts.delete('pres')
    elsif pos == 'verb' and parts.include?('perf-part')
      pos = 'verb_perf-part'
      parts.delete('perf-part')
    end

    return pos, parts
  end

end
