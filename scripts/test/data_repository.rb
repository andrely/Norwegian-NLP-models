# encoding: utf-8

require_relative '../utilities'

class DataRepository
  @@sample1 = [{index: 0,
               words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                       {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample1
    return Utilities.deep_copy @@sample1
  end

  @@sample2 = [{index: 0,
                words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]},
               {index: 1,
                words: [{:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample2
    return Utilities.deep_copy @@sample2
  end

  @@sample3 = [{index: 0, words: []},
               {index: 1, words: []},
               {index: 2, words: []},
               {index: 3, words: []}]

  def self.sample3
    return Utilities.deep_copy @@sample3
  end

  @@sample3_n_folds = 3

  def self.sample3_n_folds
    return @@sample3_n_folds
  end

  @@sample4 = [{index: 0,
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
    return @@sample4
  end

  @@sample_conll = <<END
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

  def self.sample_conll
    return @@sample_conll
  end

  @@sample_conll_sent_sizes = [12, 4]

  def self.sample_conll_sent_sizes
    return @@sample_conll_sent_sizes
  end

  @@sample5 = [{ index: 0,
                 words: [{ form: 'ba', pos: 'foo', lemma: 'lemma1' },
                         { form: 'ba', pos: 'foo', lemma: 'lemma2' },
                         { form: '.', pos: '.', lemma: '$.' }]}]
  def self.sample5
    return @@sample5
  end

  def self.sample_10_empty_sent
    10.times.collect { |i| { index: i }}
  end
end
