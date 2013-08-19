require 'test/unit'
require_relative 'helper'

require 'stringio'

require_relative '../conll_source'
require_relative 'data_repository'

class ConllSourceTest < Test::Unit::TestCase
  def test_read_conll
    reader = ConllSource.new(StringIO.new(DataRepository.sample_conll_1))

    reader.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_1_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end

    reader = ConllSource.new(StringIO.new(DataRepository.sample_conll_1))

    sents = reader.to_a

    assert_not_nil sents
    assert_equal(2, sents.count)

    sents.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_1_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end

    # reset and redo tests
    reader.reset

    sents = reader.to_a

    assert_not_nil sents
    assert_equal(2, sents.count)

    sents.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_1_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end
  end

  def test_size
    reader = ConllSource.new(StringIO.new(DataRepository.sample_conll_1))

    sent = reader.process
    assert_not_nil sent
    assert_equal 12, sent[:words].length
    assert_equal 0, sent[:index]

    assert_equal 2, reader.size
    # test once more from cache
    assert_equal 2, reader.size

    sent = reader.shift
    assert_not_nil sent
    assert_equal 4, sent[:words].length
    assert_equal 1, sent[:index]

    # test with non-default columns
    src = ConllSource.new(StringIO.new(DataRepository.sample_conll_2), columns: [:form, :lemma, :pos])

    assert_equal 1, src.size
    # test once more from cache
    assert_equal 1, src.size
  end
end