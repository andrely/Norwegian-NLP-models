require 'test/unit'

require 'minitest/reporters'
MiniTest::Reporters.use!

require 'stringio'

require_relative '../conll_source'
require_relative 'data_repository'

class ConllSourceTest < Test::Unit::TestCase
  def get_in_file
    return StringIO.new(DataRepository.sample_conll)
  end

  def test_read_conll
    reader = ConllSource.new get_in_file

    reader.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end

    reader = ConllSource.new get_in_file

    sents = reader.to_a

    assert_not_nil sents
    assert_equal(2, sents.count)

    sents.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end

    # reset and redo tests
    reader.reset

    sents = reader.to_a

    assert_not_nil sents
    assert_equal(2, sents.count)

    sents.each_with_index do |sent, i|
      assert_equal(DataRepository.sample_conll_sent_sizes[i], sent[:words].count)
      assert_equal(i, sent[:index])
    end
  end

  def test_size
    reader = ConllSource.new get_in_file

    sent = reader.process
    assert_not_nil sent
    assert_equal 12, sent[:words].length
    assert_equal 0, sent[:index]

    assert_equal 2, reader.size

    sent = reader.shift
    assert_not_nil sent
    assert_equal 4, sent[:words].length
    assert_equal 1, sent[:index]
  end
end