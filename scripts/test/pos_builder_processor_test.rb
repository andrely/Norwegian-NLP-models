require 'test/unit'
require_relative 'helper'

require 'stringio'

require_relative '../pos_builder_processor'
require_relative '../conll_source'
require_relative 'data_repository'

class POSBuilderProcessorTest < Test::Unit::TestCase
  def test_pos_builder_processor
    src = ConllSource.new(StringIO.new(DataRepository.sample_conll_1),
                          processor: POSBuilderProcessor.new)

    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size
    sent = result[0]
    words = sent[:words]
    assert_not_nil words
    assert_equal DataRepository.sample_conll_1_sent_sizes[0], words.size
    assert_equal 'det_kvant', words[0][:pos]
    assert_equal ['fl'], words[0][:feat]
    assert_equal 'subst_appell', words[1][:pos]
    assert_equal ['fl', 'mask', 'ub'], words[1][:feat]
    assert_equal 'prep', words[2][:pos]
    assert_equal [], words[2][:feat]
    assert_equal 'subst_appell', words[3][:pos]
    assert_equal ['bu', 'eint', 'mask'], words[3][:feat]
    assert_equal '<komma>', words[4][:pos]
    assert_equal [], words[4][:feat]
    assert_equal 'prep', words[5][:pos]
    assert_equal [], words[5][:feat]
    assert_equal 'subst', words[6][:pos]
    assert_equal ['mask', 'prop'], words[6][:feat]
    assert_equal 'konj', words[7][:pos]
    assert_equal [], words[7][:feat]
    assert_equal '<anf>', words[8][:pos]
    assert_equal [], words[8][:feat]
    assert_equal 'subst_appell', words[9][:pos]
    assert_equal ['fl', 'ub', 'unorm'], words[9][:feat]
    assert_equal '<anf>', words[10][:pos]
    assert_equal [], words[10][:feat]
    assert_equal '<overskrift>', words[11][:pos]
    assert_equal [], words[11][:feat]

    sent = result[1]
    words = sent[:words]
    assert_not_nil words
    assert_equal DataRepository.sample_conll_1_sent_sizes[1], words.size
    assert_equal 'pron_pers', words[0][:pos]
    assert_equal ['1', 'eint', 'hum', 'nom'], words[0][:feat]
    assert_equal 'verb_pret', words[1][:pos]
    assert_equal ['<aux1/perf_part>'], words[1][:feat]
    assert_equal 'prep', words[2][:pos]
    assert_equal [], words[2][:feat]
    assert_equal 'subst_appell', words[3][:pos]
    assert_equal ['eint', 'mask', 'ub'], words[3][:feat]
  end
end