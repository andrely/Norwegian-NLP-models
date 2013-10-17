# encoding: utf-8

require 'test/unit'

require 'stringio'

require_relative '../conll_processor'
require_relative '../../sources/array_source'
require_relative '../../test/data_repository'
require_relative '../../sources/conll_source'

class ConllProcessorTest < Test::Unit::TestCase

  SAMPLE_CONLL_1_PRED = <<END
1	Nokre	nokon	det	det	kvant|fl
2	refleksjonar	refleksjon	subst	subst	mask|appell|ub|fl
3	på	på	prep	prep	_
4	vegen	veg	subst	subst	mask|appell|eint|bu
5	,	$,	<komma>	<komma>	<ikke-clb>
6	om	om	prep	prep	_
7	Paulus	Paulus	subst	subst	mask|prop
8	og	og	konj	konj	<ikke-clb>
9	"	$"	<anf>	<anf>	_
10	worldviews	worldview	subst	subst	appell|ub|fl|unorm
11	"	$"	<anf>	<anf>	_
12	|	$|	clb	clb	<overskrift>

1	Eg	eg	pron	pron	pers|1|eint|hum|nom
2	var	vere	verb	verb	pret|<aux1/perf_part>
3	på	på	prep	prep	_
4	bibeltime	bibeltime	subst	subst	mask|appell|ub|eint
END

  def test_conll_processor
    writer = ConllProcessor.new(columns: [:form, :pos, :feat, :u1], pred_columns: [:form])
    src = ArraySource.new(DataRepository.sample2, processor: writer)

    src.process_all
    artifacts = src.pipeline_artifacts
    assert artifacts.kind_of?(Enumerable)
    assert_equal(1, artifacts.count)

    artifact = artifacts[0]
    assert artifact.is_a?(Artifact)

    assert_not_nil(artifact.file(:in))
    assert_equal("ba\tsubst\tent\t_\n.\tclb\t_\t_\n\ngneh\tverb\tpres\t_\n.\tclb\t_\t_\n\n", artifact.file(:in).string)

    assert_not_nil(artifact.file(:in_pred))
    assert_equal("ba\n.\n\ngneh\n.\n\n", artifact.file(:in_pred).string)

    writer = ConllProcessor.new
    src = ConllSource.new(StringIO.new(DataRepository.sample_conll_1), processor: writer)

    src.process_all
    artifacts = src.pipeline_artifacts
    assert artifacts.kind_of?(Enumerable)
    assert_equal(1, artifacts.count)

    artifact = artifacts[0]
    assert artifact.is_a?(Artifact)

    assert_not_nil(artifact.file(:in))
    assert_equal(DataRepository.sample_conll_1.strip, artifact.file(:in).string.strip)

    assert_not_nil(artifact.file(:in_pred))
    assert_equal(SAMPLE_CONLL_1_PRED.strip, artifact.file(:in_pred).string.strip)
  end
end