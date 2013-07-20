require 'test/unit'

require_relative '../hunpos_processor'
require_relative 'data_repository'
require_relative '../array_source'

class HunposProcessorTest < Test::Unit::TestCase
  def test_hunpos_processor
    writer = HunposProcessor.new
    src = ArraySource.new DataRepository.sample4, writer

    result = src.to_a
    descr = writer.descr

    assert_not_nil descr
    assert_not_nil descr[:in_file]
    exp_str = "Verdensarv\tsubst_prop\n" +
        ".\t<punkt>\n\n" +
        "Reise\tsubst_appell_fem_ub_ent\n" +
        "til\tprep\n" +
        "Kina\tsubst_prop\n" +
        ":\t<kolon>\n\n"
    assert_equal exp_str, descr[:in_file].string
  end

  def test_hunpos_with_folds
    writer = HunposProcessor.new
    fold_gen = FoldProcessor.new(processor: writer, num_folds: 2)

    assert_equal 2, writer.num_folds
    assert writer.has_folds?
    writer.create_descr
    assert_kind_of Enumerable, writer.descr
    assert_equal 2, writer.descr.size
    assert_equal 2, writer.descr.size

    src = ArraySource.new(DataRepository.sample2, fold_gen)
    src.process_all

    assert_raise(RuntimeError) { fold_gen.num_folds = 3 }

    descr = writer.descr

    assert_equal "ba\tsubst\n.\tclb\n\n", descr[1][:in_file].string
    assert_equal "gneh\tverb\n.\tclb\n\n", descr[0][:in_file].string
    assert_equal "ba\tsubst\n.\tclb\n\n", descr[0][:true_file].string
    assert_equal "gneh\tverb\n.\tclb\n\n", descr[1][:true_file].string

    # TODO again different order shouldn't fail tests
    assert_equal "ba\n.\n\n", descr[0][:pred_file].string
    assert_equal "gneh\n.\n\n", descr[1][:pred_file].string
      end
end