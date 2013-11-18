require 'test/unit'

require 'stringio'

require_relative '../pos_processor'
require_relative '../../sources/array_source'
require_relative '../../test/data_repository'

class PosProcessorTest < Test::Unit::TestCase
  def test_ob_lexicalization_processor
    proc = PosProcessor.ob_lexicalization_processor
    src = ArraySource.new(DataRepository.sample4, processor: proc)

    result = src.to_a

    assert_not_nil(result)
    assert_equal(2, result.count)
    assert_equal('subst_prop', result[0][:words][0][:pos])
    assert_equal('<punkt>', result[0][:words][1][:pos])

    assert_equal('subst_appell_fem_ub_ent', result[1][:words][0][:pos])
    assert_equal('prep_til', result[1][:words][1][:pos])
    assert_equal('subst_prop', result[1][:words][2][:pos])
    assert_equal('<kolon>', result[1][:words][3][:pos])
  end
end
