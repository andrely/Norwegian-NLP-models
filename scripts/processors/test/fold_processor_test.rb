require 'test/unit'

require_relative '../fold_processor'
require_relative '../../sources/array_source'

require_relative '../../test/data_repository'

class FoldProcessorTest < Test::Unit::TestCase
  def test_fold_generator
    gen = FoldProcessor.new(num_folds: DataRepository.sample3_n_folds)
    reader = ArraySource.new(DataRepository.sample3, processor: gen)
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

  def test_block_fold_processor
    gen = FoldProcessor.new(num_folds: 2, fold_type: :block)
    source = ArraySource.new(DataRepository.sample3, processor: gen)

    assert_not_nil(gen)
    assert_not_nil(source)

    assert_equal(source, gen.source)
    assert_equal(gen, source.processor)

    result = source.to_a
    assert_not_nil(result)
    assert_equal(4, result.size)
    assert_equal(2, gen.fold_size)

    assert_equal(0, result[0][:index])
    assert_equal(0, result[0][:fold])
    assert_equal(1, result[1][:index])
    assert_equal(0, result[1][:fold])
    assert_equal(2, result[2][:index])
    assert_equal(1, result[2][:fold])
    assert_equal(3, result[3][:index])
    assert_equal(1, result[3][:fold])

    gen = FoldProcessor.new(num_folds: 3, fold_type: :block)
    source = ArraySource.new(DataRepository.sample3, processor: gen)

    assert_not_nil(gen)
    assert_not_nil(source)

    assert_equal(source, gen.source)
    assert_equal(gen, source.processor)

    result = source.to_a
    assert_not_nil(result)
    assert_equal(4, result.size)
    assert_equal(1, gen.fold_size)

    assert_equal(0, result[0][:index])
    assert_equal(0, result[0][:fold])
    assert_equal(1, result[1][:index])
    assert_equal(1, result[1][:fold])
    assert_equal(2, result[2][:index])
    assert_equal(2, result[2][:fold])
    assert_equal(3, result[3][:index])
    assert_equal(2, result[3][:fold])
  end
end
