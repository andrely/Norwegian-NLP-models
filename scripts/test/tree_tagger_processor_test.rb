require 'test/unit'

require 'stringio'

require_relative '../tree_tagger_processor'
require_relative '../array_source'
require_relative '../fold_processor'
require_relative 'data_repository'

class TreeTaggerProcessorTest < Test::Unit::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_create_files
    writer = TreeTaggerProcessor.new
    reader = ArraySource.new DataRepository.sample1, writer
    reader.process_all
    descr = writer.descr

    assert_equal "ba\tsubst_ent\ngneh\tverb_pres\n.\tSENT\n", descr[:in_file].string

    # TODO order shouldn't matter for the following tests
    assert_equal "ba\tsubst_ent foo\ngneh\tverb_pres knark\n.\tSENT $.\n", descr[:lex_file].string
    assert_equal "subst_ent verb_pres\n", descr[:open_class_file].string
  end

  def test_create_files_with_folds
    writer = TreeTaggerProcessor.new
    fold_gen = FoldProcessor.new(processor: writer, num_folds: 2)

    assert_equal 2, writer.num_folds
    writer.create_descr
    assert_kind_of Enumerable, writer.descr
    assert_equal 2, writer.descr.size
    assert_equal 2, writer.descr.size

    reader = ArraySource.new(DataRepository.sample2, fold_gen)
    reader.process_all

    assert_raise(RuntimeError) { fold_gen.num_folds = 3 }

    descr = writer.descr

    assert_equal "ba\tsubst_ent\n.\tSENT\n", descr[1][:in_file].string
    assert_equal "gneh\tverb_pres\n.\tSENT\n", descr[0][:in_file].string
    assert_equal "ba\tsubst_ent\n.\tSENT\n", descr[0][:true_file].string
    assert_equal "gneh\tverb_pres\n.\tSENT\n", descr[1][:true_file].string

    # TODO again different order shouldn't fail tests
    assert_equal "ba\n.\n", descr[0][:pred_file].string
    assert_equal "gneh\n.\n", descr[1][:pred_file].string
    assert_equal "ba\tsubst_ent foo\n.\tSENT $.\n", descr[1][:lex_file].string
    assert_equal "gneh\tverb_pres knark\n.\tSENT $.\n", descr[0][:lex_file].string
    assert_equal "subst_ent\n", descr[1][:open_class_file].string
    assert_equal "verb_pres\n", descr[0][:open_class_file].string
  end
end
