require_relative 'base_source'
require_relative '../lib/obno_text_iterator'

class OBTSource < BaseSource
  def initialize(file, opts={})
    @file = file
    @obno_iterator = OBNOTextIterator.new file
    @count = 0

    super(opts)
  end

  def shift
    sent = @obno_iterator.get_next_sentence @file

    sent = sent.words.collect do |ob_word|
      word = {}
      word[:form] = ob_word.orig_string
      ob_pos = ob_word.get_correct_tag
      word[:lemma] = ob_pos.lemma.downcase
      word[:pos] = ob_pos.clean_out_tag

      word
    end

    sent = {index: @count, words: sent}
    @count += 1
    sent
  end

  def last_sentence_processed?
    @file.eof?
  end

  def reset
    @count = 0
    @file.rewind
    @obno_iterator = OBNOTextIterator.new @file
  end

  def size
    size_file = @file.clone
    old_pos = size_file.pos
    size_file.rewind

    size_iterator = OBNOTextIterator.new size_file

    count = 0

    size_iterator.each_sentence { |_| count += 1 }

    @file.pos = old_pos

    count
  end
end
