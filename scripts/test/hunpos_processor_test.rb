require 'test/unit'

require_relative '../hunpos_processor'
require_relative 'data_repository'
require_relative '../array_source'

class HunposProcessorTest < Test::Unit::TestCase
  def test_hunpos_processor
    writer = HunposProcessor.new
    src = ArraySource.new(DataRepository.sample4, processor: writer)

    result = src.to_a
    artifacts = src.pipeline_artifacts
    assert_equal 1, artifacts.count
    artifact = artifacts[0]

    assert_not_nil artifact
    assert_not_nil artifact.file :in
    exp_str = "Verdensarv\tsubst_prop\n" +
        ".\t<punkt>\n\n" +
        "Reise\tsubst_appell_fem_ub_ent\n" +
        "til\tprep\n" +
        "Kina\tsubst_prop\n" +
        ":\t<kolon>\n\n"
    assert_equal exp_str, artifact.file(:in).string
  end

  def test_hunpos_with_folds
    writer = HunposProcessor.new
    fold_gen = FoldProcessor.new(processor: writer, num_folds: 2)

    assert_equal 2, writer.num_folds
    assert writer.has_folds?
    writer.artifact
    #assert_kind_of Enumerable, writer.descr[0]
    assert_equal 2, writer.artifact.num_folds

    src = ArraySource.new(DataRepository.sample2, processor: fold_gen)
    src.process_all

    assert_raise(RuntimeError) { fold_gen.num_folds = 3 }

    artifact = src.pipeline_artifacts[0]

    assert_equal "ba\tsubst\n.\tclb\n\n", artifact.file(:in, 1).string
    assert_equal "gneh\tverb\n.\tclb\n\n", artifact.file(:in, 0).string
    assert_equal "ba\tsubst\n.\tclb\n\n", artifact.file(:true, 0).string
    assert_equal "gneh\tverb\n.\tclb\n\n", artifact.file(:true, 1).string

    # TODO again different order shouldn't fail tests
    assert_equal "ba\n.\n\n", artifact.file(:pred, 0).string
    assert_equal "gneh\n.\n\n", artifact.file(:pred, 1).string
  end
end
