require 'test/unit'
require_relative '../../test/helper'

require_relative '../array_source'
require_relative '../concatenated_source'
require_relative '../../test/data_repository'

class ConcatenatedSourceTest < Test::Unit::TestCase
  def test_concatenated_source
    src = ConcatenatedSource.new [ArraySource.new(DataRepository.sample3),
                                  ArraySource.new(DataRepository.sample3)]

    result = src.to_a

    assert_not_nil result
    assert_equal 8, result.size
    assert_equal 0, result[0][:index]
    assert_equal [0, 0], result[0][:inner_index]
    assert_equal 1, result[1][:index]
    assert_equal [0, 1], result[1][:inner_index]
    assert_equal 2, result[2][:index]
    assert_equal [0, 2], result[2][:inner_index]
    assert_equal 3, result[3][:index]
    assert_equal [0, 3], result[3][:inner_index]
    assert_equal 4, result[4][:index]
    assert_equal [1, 0], result[4][:inner_index]
    assert_equal 5, result[5][:index]
    assert_equal [1, 1], result[5][:inner_index]
    assert_equal 6, result[6][:index]
    assert_equal [1, 2], result[6][:inner_index]
    assert_equal 7, result[7][:index]
    assert_equal [1, 3], result[7][:inner_index]

    # reset and redo tests
    src.reset

    result = src.to_a

    assert_not_nil result
    assert_equal 8, result.size
    assert_equal 0, result[0][:index]
    assert_equal [0, 0], result[0][:inner_index]
    assert_equal 1, result[1][:index]
    assert_equal [0, 1], result[1][:inner_index]
    assert_equal 2, result[2][:index]
    assert_equal [0, 2], result[2][:inner_index]
    assert_equal 3, result[3][:index]
    assert_equal [0, 3], result[3][:inner_index]
    assert_equal 4, result[4][:index]
    assert_equal [1, 0], result[4][:inner_index]
    assert_equal 5, result[5][:index]
    assert_equal [1, 1], result[5][:inner_index]
    assert_equal 6, result[6][:index]
    assert_equal [1, 2], result[6][:inner_index]
    assert_equal 7, result[7][:index]
    assert_equal [1, 3], result[7][:inner_index]
  end

  def test_size
    src = ConcatenatedSource.new [ArraySource.new(DataRepository.sample3),
                                  ArraySource.new(DataRepository.sample3)]

    assert_equal(8, src.size)
  end
end