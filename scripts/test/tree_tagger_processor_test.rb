require 'test/unit'
require_relative 'helper'

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
    reader = ArraySource.new(DataRepository.sample1, processor: writer)
    reader.process_all
    artifact = reader.pipeline_artifacts[0]

    assert_equal("ba\tfoo\tsubst\ngneh\tknark\tverb\n.\t$.\tSENT\n",
                 artifact.file(:in).string)

    # TODO order shouldn't matter for the following tests
    assert_equal("ba\tsubst foo\ngneh\tverb knark\n.\tSENT $.\n",
                 artifact.file(:lexicon).string)
    assert_equal("subst verb\n", artifact.file(:open).string)
  end

  def test_create_files_with_folds
    writer = TreeTaggerProcessor.new
    fold_gen = FoldProcessor.new(processor: writer, num_folds: 2)

    assert_equal 2, writer.num_folds
    assert writer.has_folds?
    writer.artifact
    # assert_kind_of Enumerable, writer.descr[0]
    assert_equal 2, writer.artifact.num_folds

    reader = ArraySource.new(DataRepository.sample2, processor: fold_gen)
    reader.process_all

    assert_raise(RuntimeError) { fold_gen.num_folds = 3 }

    artifact = reader.pipeline_artifacts[0]

    assert_equal("ba\tfoo\tsubst\n.\t$.\tSENT\n",
                 artifact.file(:in, 1).string)
    assert_equal("gneh\tknark\tverb\n.\t$.\tSENT\n",
                 artifact.file(:in, 0).string)
    assert_equal("ba\tfoo\tsubst\n.\t$.\tSENT\n",
                 artifact.file(:true, 0).string)
    assert_equal("gneh\tknark\tverb\n.\t$.\tSENT\n",
                 artifact.file(:true, 1).string)

    # TODO again different order shouldn't fail tests
    assert_equal "ba\n.\n", artifact.file(:pred, 0).string
    assert_equal "gneh\n.\n", artifact.file(:pred, 1).string
    assert_equal "ba\tsubst foo\n.\tSENT $.\n", artifact.file(:lexicon, 1).string
    assert_equal "gneh\tverb knark\n.\tSENT $.\n", artifact.file(:lexicon, 0).string
    assert_equal "subst\n", artifact.file(:open, 1).string
    assert_equal "verb\n", artifact.file(:open, 0).string
  end

  def test_log_lemma_collision
    coll_log = StringIO.new
    writer = TreeTaggerProcessor.new(lemma_collision_log: coll_log)
    src = ArraySource.new(DataRepository.sample5, processor: writer)
    src.process_all

    assert_equal "ba\tfoo\tlemma1_lemma2\n", coll_log.string
  end
end
