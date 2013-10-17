require 'test/unit'

require_relative '../sampled_source'
require_relative '../../test/data_repository'
require_relative '../../utilities'
require_relative '../array_source'

class SampledSourceTest < Test::Unit::TestCase
  def test_sampled_source
    Utilities.srand(19751220)

    src = SampledSource.new(ArraySource.new(DataRepository.sample_10_empty_sent),
                            n: 3)
    result = src.to_a

    assert_not_nil result
    assert_equal 3, result.size
    assert_equal 9, result[0][:index]
    assert_equal 8, result[1][:index]
    assert_equal 4, result[2][:index]
  end
end
