require 'test/unit'

require_relative '../fold_processor'
require_relative '../array_source'
require_relative '../null_processor'

class FoldProcessorTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @sample = [{index: 0, words: []},
               {index: 1, words: []},
               {index: 2, words: []},
               {index: 3, words: []}]
    @sample_n_folds = 3
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_fold_generator
    writer = NullProcessor.new
    gen = FoldProcessor.new(writer, @sample_n_folds)
    reader = ArraySource.new @sample, gen
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
