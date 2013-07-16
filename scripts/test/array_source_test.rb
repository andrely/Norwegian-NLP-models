require 'test/unit'

require_relative '../array_source'
require_relative 'data_repository'

class ArraySourceTest < Test::Unit::TestCase
  def test_array_source_with_index
    src = ArraySource.new DataRepository.sample3, nil

    result = src.to_a

    assert_not_nil result
    assert_equal 4, result.size

    4.times.each do |i|
      assert_equal i, result[i][:index]
    end

    # reset and redo test

    src.reset

    result = src.to_a

    assert_not_nil result
    assert_equal 4, result.size

    4.times.each do |i|
      assert_equal i, result[i][:index]
    end
  end

  def test_array_source_without_index
    sample = DataRepository.sample3
    sample.each { |s| s.delete :index }
    sample.each { |s| assert_nil s[:index] }

    src = ArraySource.new sample, nil

    result = src.to_a

    assert_not_nil result
    assert_equal 4, result.size

    4.times.each do |i|
      assert_equal i, result[i][:index]
    end
  end
end
