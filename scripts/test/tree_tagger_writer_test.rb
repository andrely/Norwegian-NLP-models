require 'test/unit'

require 'stringio'

require_relative '../tree_tagger_writer'
require_relative '../array_reader'
require_relative '../fold_generator'

class TreeTaggerWriterTest < Test::Unit::TestCase
  @@sample = [{index: 0,
               words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                       {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  @@sample2 = [{index: 0,
                words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]},
               {index: 1,
                words: [{:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

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
    writer = TreeTaggerWriter.new(ArrayReader.new(@@sample))
    descr = writer.create_files

    assert_equal "ba\tsubst_ent\ngneh\tverb_pres\n.\tSENT\n", descr[:in_file].string

    # TODO order shouldn't matter for the following tests
    assert_equal "ba\tsubst_ent foo\ngneh\tverb_pres knark\n.\tSENT $.\n", descr[:lex_file].string
    assert_equal "subst_ent verb_pres\n", descr[:open_class_file].string
  end

  def test_create_files_with_folds
    reader = ArrayReader.new(@@sample2)
    fold_gen = FoldGenerator.new(reader, 2)
    writer = TreeTaggerWriter.new(fold_gen)
    descr = writer.create_files

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