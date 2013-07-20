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

    assert_equal "ba\tfoo\tsubst\ngneh\tknark\tverb\n.\t$.\tSENT\n", descr[:in_file].string

    # TODO order shouldn't matter for the following tests
    assert_equal "ba\tsubst foo\ngneh\tverb knark\n.\tSENT $.\n", descr[:lex_file].string
    assert_equal "subst verb\n", descr[:open_class_file].string
  end

  def test_create_files_with_folds
    writer = TreeTaggerProcessor.new
    fold_gen = FoldProcessor.new(processor: writer, num_folds: 2)

    assert_equal 2, writer.num_folds
    assert writer.has_folds?
    writer.create_descr
    assert_kind_of Enumerable, writer.descr
    assert_equal 2, writer.descr.size
    assert_equal 2, writer.descr.size

    reader = ArraySource.new(DataRepository.sample2, fold_gen)
    reader.process_all

    assert_raise(RuntimeError) { fold_gen.num_folds = 3 }

    descr = writer.descr

    assert_equal "ba\tfoo\tsubst\n.\t$.\tSENT\n", descr[1][:in_file].string
    assert_equal "gneh\tknark\tverb\n.\t$.\tSENT\n", descr[0][:in_file].string
    assert_equal "ba\tfoo\tsubst\n.\t$.\tSENT\n", descr[0][:true_file].string
    assert_equal "gneh\tknark\tverb\n.\t$.\tSENT\n", descr[1][:true_file].string

    # TODO again different order shouldn't fail tests
    assert_equal "ba\n.\n", descr[0][:pred_file].string
    assert_equal "gneh\n.\n", descr[1][:pred_file].string
    assert_equal "ba\tsubst foo\n.\tSENT $.\n", descr[1][:lex_file].string
    assert_equal "gneh\tverb knark\n.\tSENT $.\n", descr[0][:lex_file].string
    assert_equal "subst\n", descr[1][:open_class_file].string
    assert_equal "verb\n", descr[0][:open_class_file].string
  end
end
