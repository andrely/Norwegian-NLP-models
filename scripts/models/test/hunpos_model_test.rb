require 'test/unit'

require 'tmpdir'
require 'stringio'

require_relative '../hunpos_model'
require_relative '../../artifact'

class HunposModelTest < Test::Unit::TestCase
  TRAIN_STRING = "x\t1\ny\t0\nx\t0\nx\t1\n\nx\t1\nx\t1\ny\t0\nx\t1\n13\td\n"
  TEST_STRING = "x\ny\nx\nx\n\nx\nx\ny\nx\n13\n"
  PRED_STRING = "x\t1\t\ny\t0\t\nx\t1\t\nx\t1\t\n\nx\t1\t\nx\t1\t\ny\t0\t\nx\t1\t\n13\td\t\n\n"

  def test_train_with_file
    Dir.mktmpdir do |dir|
      model_fn = File.join(dir, "hunpos-model")
      model = HunposModel.new(model_fn: model_fn)
      artifact = Artifact.from_strings({ in: TRAIN_STRING,
                                         in_pred: TEST_STRING })

      model.train_with_artifact(artifact)
      assert(model.validate_model)

      pred = StringIO.new

      model.predict_internal(model.model_fn, artifact.file(:in_pred), pred)
      assert_equal(PRED_STRING, pred.string)
      pred.rewind

      correct, total, score = model.score_internal(pred, StringIO.new(TRAIN_STRING))
      assert_equal(8, correct)
      assert_equal(9, total)
      assert_in_delta(0.888, score, delta=0.001)
    end
  end

  def test_validate_binaries
    assert HunposModel.validate_binaries

    old_train_bin = HunposModel.train_bin
    old_tag_bin = HunposModel.tag_bin

    HunposModel.tag_bin = 'knark'
    assert !HunposModel.validate_binaries
    HunposModel.tag_bin = 'ls'
    assert !HunposModel.validate_binaries
    HunposModel.tag_bin = old_tag_bin

    HunposModel.train_bin = 'knark'
    assert !HunposModel.validate_binaries
    HunposModel.train_bin = 'ls'
    assert !HunposModel.validate_binaries
    HunposModel.train_bin = old_train_bin
  end
end