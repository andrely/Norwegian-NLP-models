require 'test/unit'
require_relative '../../test/helper'

require 'stringio'

require_relative '../tree_tagger_source'

class TreeTaggerSourceTest < Test::Unit::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @sample = <<END
En	en	det
setning	setning	nn
.	.	SENT

Vi	vi	pron
trener	trene	vb
.	.	SENT
END
  end

  def test_tree_tagger_source
    src = TreeTaggerSource.new(StringIO.new(@sample))

    sents = src.to_a

    assert_not_nil sents
    assert_equal 2, sents.size

    sent = sents[0]
    assert_not_nil sent
    assert_equal 0, sent[:index]
    words = sent[:words]
    assert_not_nil words
    assert_equal 3, words.size
    assert_equal 'en', words[0][:lemma]
    assert_equal 'nn', words[1][:pos]
    assert_equal '.', words[2][:form]

    sent = sents[1]
    assert_not_nil sent
    assert_equal 1, sent[:index]
    words = sent[:words]
    assert_not_nil words
    assert_equal 3, words.size
    assert_equal 'vi', words[0][:lemma]
    assert_equal 'vb', words[1][:pos]
    assert_equal '.', words[2][:form]

    # reset and redo tests
    src.reset

    sents = src.to_a

    assert_not_nil sents
    assert_equal 2, sents.size

    sent = sents[0]
    assert_not_nil sent
    assert_equal 0, sent[:index]
    words = sent[:words]
    assert_not_nil words
    assert_equal 3, words.size
    assert_equal 'en', words[0][:lemma]
    assert_equal 'nn', words[1][:pos]
    assert_equal '.', words[2][:form]

    sent = sents[1]
    assert_not_nil sent
    assert_equal 1, sent[:index]
    words = sent[:words]
    assert_not_nil words
    assert_equal 3, words.size
    assert_equal 'vi', words[0][:lemma]
    assert_equal 'vb', words[1][:pos]
    assert_equal '.', words[2][:form]
  end
end
