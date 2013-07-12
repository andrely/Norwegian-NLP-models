require 'test/unit'

require_relative '../fold_processor'
require_relative '../array_source'

require_relative 'data_repository'

class FoldProcessorTest < Test::Unit::TestCase
  def test_fold_generator
    gen = FoldProcessor.new(num_folds: DataRepository.sample3_n_folds)
    reader = ArraySource.new DataRepository.sample3, gen
    assert_not_nil gen

    result = reader.to_a
    assert_not_nil result
    assert_equal 4, result.size

    assert_equal 0, result[0][:index]
    assert_equal 0, result[0][:fold]
    assert_equal 1, result[1][:index]
    assert_equal 1, result[1][:fold]
    assert_equal 2, result[2][:index]
    assert_equal 2, result[2][:fold]
    assert_equal 3, result[3][:index]
    assert_equal 0, result[3][:fold]
  end
end
