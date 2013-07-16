require_relative 'base_source'
require_relative 'lib/obno_text_iterator'

class OBTSource < BaseSource
  def initialize(file, opts={})
    @file = file
    @obno_iterator = OBNOTextIterator.new file
    @count = 0

    super(opts[:processor] || nil)
  end

  def shift
    sent = @obno_iterator.get_next_sentence @file

    sent = sent.words.collect do |ob_word|
      word = {}
      word[:form] = ob_word.orig_string
      ob_tag = ob_word.get_correct_tag
      word[:lemma] = ob_tag.lemma.downcase
      word[:tag] = ob_tag.clean_out_tag

      word
    end

    sent = {index: @count, words: sent}
    @count += 1
    return sent
  end

  def each
    until last_sentence_processed?
      yield process
    end
  end

  def last_sentence_processed?
    return @file.eof?
  end

  def reset
    @file.rewind
    @obno_iterator = OBNOTextIterator.new file
  end

  def size
    size_file = @file.clone
    old_pos = size_file.pos
    size_file.rewind

    size_iterator = OBNOTextIterator.new size_file

    count = 0

    size_iterator.each_sentence { |_| count += 1 }

    @file.pos = old_pos

    return count
  end
end
