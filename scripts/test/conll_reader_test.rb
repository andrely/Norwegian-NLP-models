# encoding: utf-8

require 'test/unit'

require 'minitest/reporters'
MiniTest::Reporters.use!

require 'stringio'

require_relative '../conll_reader'

class ConllReaderTest < Test::Unit::TestCase
  @@sample_input = <<END
1	Nokre	nokon	det	det	kvant|fl	2	DET	_	_
2	refleksjonar	refleksjon	subst	subst	mask|appell|ub|fl	0	FRAG	_	_
3	på	på	prep	prep	_	2	ATR	_	_
4	vegen	veg	subst	subst	mask|appell|eint|bu	3	PUTFYLL	_	_
5	,	$,	<komma>	<komma>	<ikke-clb>	2	IK	_	_
6	om	om	prep	prep	_	2	ATR	_	_
7	Paulus	Paulus	subst	subst	mask|prop	6	PUTFYLL	_	_
8	og	og	konj	konj	<ikkje-clb>	10	KONJ	_	_
9	"	$"	<anf>	<anf>	_	10	IK	_	_
10	worldviews	worldview	subst	subst	appell|ub|fl|unorm	7	KOORD	_	_
11	"	$"	<anf>	<anf>	_	10	IK	_	_
12	|	$|	clb	clb	<overskrift>	2	IP	_	_

1	Eg	eg	pron	pron	pers|1|eint|hum|nom	2	SUBJ	_	_
2	var	vere	verb	verb	pret|<aux1/perf_part>	0	FINV	_	_
3	på	på	prep	prep	_	2	ADV	_	_
4	bibeltime	bibeltime	subst	subst	mask|appell|ub|eint	3	PUTFYLL	_	_
END

  @@sample_sent_sizes = [12, 4]

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @infile = StringIO.new(@@sample_input)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_read_conll
    reader = ConllReader.new @infile

    reader.each_with_index do |sent, i|
      assert_equal(@@sample_sent_sizes[i], sent.count)
    end
  end
end