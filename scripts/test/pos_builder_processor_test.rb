require 'test/unit'

require 'stringio'

require_relative '../pos_builder_processor'
require_relative '../conll_source'
require_relative 'data_repository'

class POSBuilderProcessorTest < Test::Unit::TestCase
  def test_pos_builder_processor
    src = ConllSource.new(StringIO.new(DataRepository.sample_conll),
                          processor: POSBuilderProcessor.new)

    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size
    sent = result[0]
    words = sent[:words]
    assert_not_nil words
    assert_equal DataRepository.sample_conll_sent_sizes[0], words.size
    assert_equal 'det_kvant_fl', words[0][:pos]
    assert_equal 'det', words[0][:pos_bare]
    assert_equal 'subst_mask_appell_ub_fl', words[1][:pos]
    assert_equal 'subst', words[1][:pos_bare]
    assert_equal 'prep', words[2][:pos]
    assert_nil words[2][:pos_bare]
    assert_equal 'subst_mask_appell_eint_bu', words[3][:pos]
    assert_equal 'subst', words[3][:pos_bare]
    assert_equal '<komma>_<ikke-clb>', words[4][:pos]
    assert_equal '<komma>', words[4][:pos_bare]
    assert_equal 'prep', words[5][:pos]
    assert_nil words[5][:pos_bare]
    assert_equal 'subst_mask_prop', words[6][:pos]
    assert_equal 'subst', words[6][:pos_bare]
    assert_equal 'konj_<ikkje-clb>', words[7][:pos]
    assert_equal 'konj', words[7][:pos_bare]
    assert_equal '<anf>', words[8][:pos]
    assert_nil words[8][:pos_bare]
    assert_equal 'subst_appell_ub_fl_unorm', words[9][:pos]
    assert_equal 'subst', words[9][:pos_bare]
    assert_equal '<anf>', words[10][:pos]
    assert_nil words[10][:pos_bare]
    assert_equal 'clb_<overskrift>', words[11][:pos]
    assert_equal 'clb', words[11][:pos_bare]

    sent = result[1]
    words = sent[:words]
    assert_not_nil words
    assert_equal DataRepository.sample_conll_sent_sizes[1], words.size
    assert_equal 'pron_pers_1_eint_hum_nom', words[0][:pos]
    assert_equal 'pron', words[0][:pos_bare]
    assert_equal 'verb_pret_<aux1/perf_part>', words[1][:pos]
    assert_equal 'verb', words[1][:pos_bare]
    assert_equal 'prep', words[2][:pos]
    assert_nil words[2][:pos_bare]
    assert_equal 'subst_mask_appell_ub_eint', words[3][:pos]
    assert_equal 'subst', words[3][:pos_bare]
  end
end