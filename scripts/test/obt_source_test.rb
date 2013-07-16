require 'test/unit'

require_relative '../obt_source'
require 'stringio'

class OBTSourceTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @sample = <<END
<word>Verdensarv</word>
"<verdensarv>"
	"Verdensarv" subst prop	<Correct!>
<word>.</word>
"<.>"
	"$." clb <<< <punkt>	<Correct!>
<word>Reise</word>
"<reise>"
	"reise" verb inf i1 a3 pa5
	"reise" verb inf tr1 pa1 rl4 pa2
	"reise" subst appell fem ub ent	<Correct!>
	"reise" subst appell mask ub ent
<word>til</word>
"<til>"
	"til" sbu
	"til" prep	<Correct!>
<word>Kina</word>
"<kina>"
	"Kina" subst prop <*>	<Correct!>
<word>:</word>
"<:>"
	"$:" clb <kolon> <<<	<Correct!>
END
  end

  def test_obt_source
    sample = StringIO.new @sample

    src = OBTSource.new sample
    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size

    sent = result[0]
    assert_equal 0, sent[:index]
    words = sent[:words]
    assert_equal 2, words.count
    assert_equal 'Verdensarv', words[0][:form]
    assert_equal 'verdensarv', words[0][:lemma]
    assert_equal 'subst_prop', words[0][:tag]
    assert_equal '.', words[1][:form]
    assert_equal '$.', words[1][:lemma]
    assert_equal '<punkt>', words[1][:tag]

    sent = result[1]
    assert_equal 1, sent[:index]
    words = sent[:words]
    assert_equal 4, words.count
    assert_equal 'Reise', words[0][:form]
    assert_equal 'reise', words[0][:lemma]
    assert_equal 'subst_appell_fem_ub_ent', words[0][:tag]
    assert_equal 'til', words[1][:form]
    assert_equal 'til', words[1][:lemma]
    assert_equal 'prep', words[1][:tag]
    assert_equal 'Kina', words[2][:form]
    assert_equal 'kina', words[2][:lemma]
    assert_equal 'subst_prop', words[2][:tag]
    assert_equal ':', words[3][:form]
    assert_equal '$:', words[3][:lemma]
    assert_equal '<kolon>', words[3][:tag]

    # reset and redo tests
    src.reset

    result = src.to_a

    assert_not_nil result
    assert_equal 2, result.size

    sent = result[0]
    assert_equal 0, sent[:index]
    words = sent[:words]
    assert_equal 2, words.count
    assert_equal 'Verdensarv', words[0][:form]
    assert_equal 'verdensarv', words[0][:lemma]
    assert_equal 'subst_prop', words[0][:tag]
    assert_equal '.', words[1][:form]
    assert_equal '$.', words[1][:lemma]
    assert_equal '<punkt>', words[1][:tag]

    sent = result[1]
    assert_equal 1, sent[:index]
    words = sent[:words]
    assert_equal 4, words.count
    assert_equal 'Reise', words[0][:form]
    assert_equal 'reise', words[0][:lemma]
    assert_equal 'subst_appell_fem_ub_ent', words[0][:tag]
    assert_equal 'til', words[1][:form]
    assert_equal 'til', words[1][:lemma]
    assert_equal 'prep', words[1][:tag]
    assert_equal 'Kina', words[2][:form]
    assert_equal 'kina', words[2][:lemma]
    assert_equal 'subst_prop', words[2][:tag]
    assert_equal ':', words[3][:form]
    assert_equal '$:', words[3][:lemma]
    assert_equal '<kolon>', words[3][:tag]
  end
end
