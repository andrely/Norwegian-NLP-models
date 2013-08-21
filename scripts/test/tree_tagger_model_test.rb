require 'test/unit'

require 'tmpdir'
require 'stringio'

require_relative '../tree_tagger_model'

class TreeTaggerModelTest < Test::Unit::TestCase
  LEX_DATA = "x\t0 X\t1 X\ny\t0 Y\n13\td D\n.\tSENT ."
  OPEN_DATA = "1 0 d"
  TRAIN_DATA = "x\t1\ny\t0\nx\t0\nx\t1\n.\tSENT\nx\t1\nx\t1\ny\t0\nx\t1\n13\td\n.\tSENT"
  IN_DATA = "x\ny\nx\nx\n.\nx\nx\ny\nx\n13\n."
  EXPECTED_DATA = "x\t1\tX\ny\t0\tY\nx\t1\tX\nx\t1\tX\n.\tSENT\t.\nx\t1\tX\nx\t1\tX\ny\t0\tY\nx\t1\tX\n13\td\tD\n.\tSENT\t.\n"

  def test_tree_tagger_model
    Dir.mktmpdir do |dir|
      model_fn = File.join(dir, 'tt_model')

      model = TreeTaggerModel.new(model_fn)
      model.train_with_io(StringIO.new(TRAIN_DATA), StringIO.new(LEX_DATA), StringIO.new(OPEN_DATA))

      assert(model.validate_model)

      out_file = StringIO.new
      model.predict_internal(model_fn, StringIO.new(IN_DATA), out_file)
      assert_equal EXPECTED_DATA, out_file.string
    end

  end
end