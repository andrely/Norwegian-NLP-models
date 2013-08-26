require 'test/unit'
require_relative '../../test/helper'

require_relative '../concatenation_processor'
require_relative '../null_processor'
require_relative '../../sources/array_source'
require_relative '../fold_processor'

require_relative '../../test/data_repository'

class ConcatenationProcessorTest < Test::Unit::TestCase
  def test_concatenated_null_processors
    conc_proc = ConcatenationProcessor.new [ NullProcessor.new, NullProcessor.new, NullProcessor.new ]
    src = ArraySource.new(DataRepository.sample2, processor: conc_proc)

    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size

    result.each_with_index do |sent_set, i|
      assert_equal 3, sent_set.size

      sent_set.each do |sent|
        assert_equal i, sent[:index]
        assert_equal 2, sent.size

        sent[:words].each do |word|
          assert_not_nil word[:form]
        end
      end
    end
  end

  def test_concatenated_fold_generator
    conc_proc = ConcatenationProcessor.new [NullProcessor.new,
                                            FoldProcessor.new(num_folds: DataRepository.sample3_n_folds)]
    src= ArraySource.new(DataRepository.sample3, processor: conc_proc)

    result = src.to_a

    assert_not_nil result
    assert_equal 4, result.size

    result.each_with_index do |sent_set, i|
      assert_equal 2, sent_set.size
      assert_equal i, sent_set[0][:index]
      assert_equal i, sent_set[0][:index]
    end

    result.zip([0, 1, 2, 0]).each do |sent_set, fold|
      assert_equal fold, sent_set[1][:fold]
    end
  end
end
