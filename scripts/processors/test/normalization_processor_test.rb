require 'test/unit'

require_relative '../normalization_processor'
require_relative '../../test/data_repository'
require_relative '../../sources/array_source'

class NormalizationProcessorTest < Test::Unit::TestCase
  def test_normalization_processor
    proc = NormalizationProcessor.new(proc_map: { :form => lambda { |form| form.reverse } })
    src = ArraySource.new(DataRepository.sample5, processor: proc)

    result = src.to_a

    assert_not_nil(result)
    assert_equal(1, result.size)
    assert_not_nil(result[0][:words])
    assert_equal(3, result[0][:words].size)
    assert_equal('ab', result[0][:words][0][:form])
    assert_equal('ab', result[0][:words][1][:form])
    assert_equal('.', result[0][:words][2][:form])
  end

  def test_ob_normalization_processor
    proc = NormalizationProcessor.ob_normalization_processor
    src = ArraySource.new(DataRepository.sample6, processor: proc)

    result = src.to_a

    assert_not_nil(result)
    assert_not_nil(result[0][:words])
    assert_equal(4, result[0][:words].size)
    assert_equal('"', result[0][:words][0][:form])
    assert_equal('anf', result[0][:words][0][:pos])
    assert_equal('"', result[0][:words][0][:lemma])

    assert_equal('ba', result[0][:words][1][:form])
    assert_equal('foo', result[0][:words][1][:pos])
    assert_equal('ba', result[0][:words][1][:lemma])

    assert_equal('ba', result[0][:words][2][:form])
    assert_equal('foo', result[0][:words][2][:pos])
    assert_equal('ba', result[0][:words][2][:lemma])

    assert_equal('"', result[0][:words][3][:form])
    assert_equal('anf', result[0][:words][3][:pos])
    assert_equal('"', result[0][:words][3][:lemma])
  end
end