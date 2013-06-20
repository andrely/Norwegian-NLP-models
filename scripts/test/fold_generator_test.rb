require 'test/unit'

require_relative '../fold_generator'

class FoldGeneratorTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @sample = [[{:form => 1}],
               [{:form => 2}],
               [{:form => 3}]]
    @sample_n_folds = 3
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_fold_generator
    gen = FoldGenerator.new @sample, @sample_n_folds

    gen.get_folds.each_with_index do |fold, fold_idx|
      assert_equal 2, fold.size

      fold_sample = @sample.select.with_index { |_, i| i % @sample_n_folds != fold_idx }
      assert_equal fold_sample, fold
    end
  end
end
