require 'test/unit'

require_relative '../flat_text_processor'
require_relative 'data_repository'
require_relative '../array_source'

class FlatTextProcessorTest < Test::Unit::TestCase
  def test_flat_text_processor
    flat = FlatTextProcessor.new
    src = ArraySource.new(DataRepository.sample4, processor: flat)

    src.process_all

    artifacts = src.pipeline_artifacts
    assert_equal(1, artifacts.count)

    artifact = artifacts[0]
    assert_not_nil artifact
    assert_equal("Verdensarv .\nReise til Kina :\n", artifact.file(:flat).string)
  end
end
