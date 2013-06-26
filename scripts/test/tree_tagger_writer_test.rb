require 'test/unit'

require 'stringio'

require_relative '../tree_tagger_writer'

class TreeTaggerWriterTest < Test::Unit::TestCase
  @@sample = [{index: 0,
               words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
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
    in_file = StringIO.new
    lex_file = StringIO.new
    open_class_file = StringIO.new

    writer = TreeTaggerWriter.new @@sample
    writer.create_files in_file, lex_file, open_class_file

    in_file.close
    lex_file.close
    open_class_file.close

    assert_equal "ba\tsubst_ent\ngneh\tverb_pres\n.\tSENT\n", in_file.string

    # TODO order shouldn't matter for the following tests
    assert_equal "ba\tsubst_ent foo\ngneh\tverb_pres knark\n.\tSENT $.\n", lex_file.string
    assert_equal "subst_ent verb_pres\n", open_class_file.string
  end
end