require 'test/unit'

require 'tmpdir'

require_relative '../maltparser_model'
require_relative '../../artifact'

class MaltparserModelTest < Test::Unit::TestCase
  TRAIN_STRING = "1\tx\t_\t0\t0\t_\t2\tX\t_\t_\n2\ty\t_\t1\t1\t_\t0\tROOT\t_\t_\n3\tx\t_\t0\t0\t_\t2\tX\t_\t_\n\n1\ty\t_\t1\t1\t_\t0\tROOT\t_\t_\n2\ty\t_\t1\t1\t_\t1\tY\t_\t_\n3\tx\t_\t0\t0\t_\t2\tX\t_\t_\n"
  TEST_STRING = "1\tx\t_\t0\t0\t_\n2\ty\t_\t1\t1\t_\n3\tx\t_\t0\t0\t_\n\n1\ty\t_\t1\t1\t_\n2\ty\t_\t1\t1\t_\n3\tx\t_\t0\t0\t_\n"

  def test_maltparser_model
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do |_|
        model_fn = 'maltparser'

        model = MaltparserModel.new(model_fn: model_fn)

        artifact = Artifact.from_strings({ in: TRAIN_STRING,
                                           in_pred: TEST_STRING})

        model.train_with_artifact(artifact)
        assert(model.validate_model)

        pred = StringIO.new
        model.predict_internal(artifact.file(:in_pred), pred)
        assert_equal(TRAIN_STRING.strip, pred.string.strip)
      end

    end
  end

  def test_validate_binaries
    assert MaltparserModel.validate_binaries

    old_jar_fn = MaltparserModel.jar_fn
    MaltparserModel.jar_fn = 'knark.jar'
    assert !MaltparserModel.validate_binaries
    MaltparserModel.jar_fn = old_jar_fn
  end
end