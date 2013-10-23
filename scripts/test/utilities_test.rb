require 'test/unit'

require 'stringio'

require_relative '../utilities'

class UtilitiesTest < Test::Unit::TestCase
  def test_random
    assert_kind_of Float, Utilities.random.rand
    assert_kind_of Integer, Utilities.random.rand(10)

    Utilities.srand(123)
    assert_in_epsilon 0.69646918, Utilities.random.rand
    assert_equal 2, Utilities.random.rand(10)
  end

  def test_mean
    m = Utilities.mean([1, 2, 3, 4, 5, '6'])
    assert_kind_of Float, m
    assert_equal 3.5, m
  end
end