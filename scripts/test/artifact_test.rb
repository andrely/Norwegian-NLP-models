require 'test/unit'
require_relative 'helper'

require_relative '../artifact'

class ArtifactTest < Test::Unit::TestCase
  def test_from_files
    file_ids_and_strings = { ba: "ba", foo: "foo" }

    artifact = Artifact.from_strings(file_ids_and_strings)

    # check that input is not changed
    assert_equal(file_ids_and_strings, file_ids_and_strings)
    assert_equal("ba", artifact.file(:ba).string)
    assert_equal("foo", artifact.file(:foo).string)
  end
end