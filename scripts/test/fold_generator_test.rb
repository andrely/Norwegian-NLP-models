require 'test/unit'

require_relative '../fold_generator'

class FoldGeneratorTest < Test::Unit::TestCase

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
    gen = FoldGenerator.new(@sample, @sample_n_folds)
    assert_not_nil gen

    gen = gen.to_a
    assert_not_nil gen
    assert_equal 4, gen.size

    assert_equal 0, gen[0][:index]
    assert_equal 0, gen[0][:fold]
    assert_equal 1, gen[1][:index]
    assert_equal 1, gen[1][:fold]
    assert_equal 2, gen[2][:index]
    assert_equal 2, gen[2][:fold]
    assert_equal 3, gen[3][:index]
    assert_equal 0, gen[3][:fold]
  end
end
