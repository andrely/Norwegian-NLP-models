require 'test/unit'
require_relative 'helper'

require 'stringio'

require_relative '../ob_tag_processor'
require_relative '../array_source'
require_relative 'data_repository'

class OBTagProcessorTest < Test::Unit::TestCase
  def test_parse_obt_map
    map_str = <<END
adj_pos_be_ent JJ-DS
<PUNKT> .
END
    file = StringIO.new map_str
    map = OBTagProcessor.parse_obt_map file, Hash.new

    assert_not_nil map
    assert_equal 2, map.size
    assert_equal 'jj-ds', map[OBTagProcessor.normalize_pos('adj_pos_be_ent')]
    assert_equal '.', map[OBTagProcessor.normalize_pos('<PUNKT>')]
  end

  def test_normalize_tag
    assert_equal 'adj_be_ent_pos', OBTagProcessor.normalize_pos('adj_pos_be_ent')
  end

  def test_ob_tag_processor
    src = ArraySource.new(DataRepository.sample4, processor: OBTagProcessor.new)

    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size

    sent = result[0]
    assert_not_nil sent[:words]
    words = sent[:words]
    assert_equal 2, words.size
    assert_equal 'nnp', words[0][:pos]
    assert_equal '.', words[1][:pos]

    sent = result[1]
    assert_not_nil sent[:words]
    words = sent[:words]
    assert_equal 4, words.size
    assert_equal 'nn-ifs', words[0][:pos]
    assert_equal 'prp', words[1][:pos]
    assert_equal 'nnp', words[2][:pos]
    assert_equal 'pnct', words[3][:pos]
  end
end
