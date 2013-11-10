# encoding: utf-8

require_relative '../utilities'

class DataRepository
  SAMPLE1 = [{index: 0,
               words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                       {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample1
    Utilities.deep_copy(SAMPLE1)
  end

  SAMPLE2 = [{index: 0,
                words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]},
               {index: 1,
                words: [{:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample2
    Utilities.deep_copy(SAMPLE2)
  end

  SAMPLE3 = [{index: 0, words: []},
               {index: 1, words: []},
               {index: 2, words: []},
               {index: 3, words: []}]

  def self.sample3
    Utilities.deep_copy(SAMPLE3)
  end

  SAMPLE_3_N_FOLDS = 3

  def self.sample3_n_folds
    SAMPLE_3_N_FOLDS
  end

  SAMPLE4 = [{index: 0,
              words: [{form: 'Verdensarv',
                       lemma: 'verdensarv',
                       pos: 'subst_prop'},
                      {form: '.',
                       lemma: '$.',
                       pos: '<punkt>'}]},
             {index: 1,
              words: [{form: 'Reise',
                       lemma: 'reise',
                       pos: 'subst_appell_fem_ub_ent'},
                      {form: 'til',
                       lemma: 'til',
                       pos: 'prep'},
                      {form: 'Kina',
                       lemma: 'kina',
                       pos: 'subst_prop'},
                      {form: ':',
                       lemma: '$:',
                       pos: '<kolon>'}]}]

  def self.sample4
    Utilities.deep_copy(SAMPLE4)
  end

  SAMPLE_CONLL_1 = <<END
1	Nokre	nokon	det	det	kvant|fl	2	DET	_	_
2	refleksjonar	refleksjon	subst	subst	mask|appell|ub|fl	0	FRAG	_	_
3	på	på	prep	prep	_	2	ATR	_	_
4	vegen	veg	subst	subst	mask|appell|eint|bu	3	PUTFYLL	_	_
5	,	$,	<komma>	<komma>	<ikke-clb>	2	IK	_	_
6	om	om	prep	prep	_	2	ATR	_	_
7	Paulus	Paulus	subst	subst	mask|prop	6	PUTFYLL	_	_
8	og	og	konj	konj	<ikke-clb>	10	KONJ	_	_
9	"	$"	<anf>	<anf>	_	10	IK	_	_
10	worldviews	worldview	subst	subst	appell|ub|fl|unorm	7	KOORD	_	_
11	"	$"	<anf>	<anf>	_	10	IK	_	_
12	|	$|	clb	clb	<overskrift>	2	IP	_	_

1	Eg	eg	pron	pron	pers|1|eint|hum|nom	2	SUBJ	_	_
2	var	vere	verb	verb	pret|<aux1/perf_part>	0	FINV	_	_
3	på	på	prep	prep	_	2	ADV	_	_
4	bibeltime	bibeltime	subst	subst	mask|appell|ub|eint	3	PUTFYLL	_	_
END

  def self.sample_conll_1
    Utilities.deep_copy(SAMPLE_CONLL_1)
  end

  SAMPLE_CONLL_1_SENT_SIZES = [12, 4]

  def self.sample_conll_1_sent_sizes
    SAMPLE_CONLL_1_SENT_SIZES
  end

  SAMPLE_CONLL_2 = <<END
Verdensarv	verdensarv	subst_prop
.	$.	<punkt>

END

  def self.sample_conll_2
    Utilities.deep_copy(SAMPLE_CONLL_2)
  end

  SAMPLE5 = [{ index: 0,
               words: [{ form: 'ba', pos: 'foo', lemma: 'lemma1' },
                       { form: 'ba', pos: 'foo', lemma: 'lemma2' },
                       { form: '.', pos: '.', lemma: '$.' }]}]
  def self.sample5
    Utilities.deep_copy(SAMPLE5)
  end

  def self.sample_10_empty_sent
    10.times.collect { |i| { index: i }}
  end

  SAMPLE6 = [{index: 0,
              words: [{ form: '«', pos: 'anf', lemma: '«' },
                      { form: 'ba', pos: 'foo', lemma: '*ba'},
                      { form: 'ba', pos: 'foo', lemma: 'ba'},
                      { form: '»', pos: 'anf', lemma: '»' }]}]

  def self.sample6
    Utilities.deep_copy(SAMPLE6)
  end
end
