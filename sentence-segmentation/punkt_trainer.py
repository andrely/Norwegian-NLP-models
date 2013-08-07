# coding=utf-8
import codecs
from glob import glob
import os
import cPickle
import re

import nltk
from nltk.tokenize.punkt import PunktWordTokenizer, PunktSentenceTokenizer, PunktTrainer, PunktLanguageVars
import sys

avis_path = ''
gull_fn = ''
opc_path = ''
obt_fn = ''

avis_pat = re.compile("^<s>(.*)</s>$")

def train_with_file(fn, trainer, preprocess=None):
    print "Training with %s" % fn
    count = 0
    lines = []
    outer = 1
    with codecs.open(fn, 'r', 'utf-8') as f:
        for line in f:
            if count >= 10000:
                sys.stdout.write('*')
                if outer % 40 == 0:
                    sys.stdout.write("\n")
                outer += 1
                trainer.train("\n".join(lines), finalize=False)
                count = 0
                lines = []
            count += 1

            if preprocess:
                line = preprocess(line)

            lines.append(line)


# open model
vars = PunktLanguageVars
vars.sent_end_chars = (u".", u"?", u"!", u")", u"\"", u"'", u":", u"|", u"»", u"]")
trainer = PunktTrainer(lang_vars=vars())

train_with_file(gull_fn, trainer)

for fn in glob(os.path.join(avis_path, '*.s')):
    train_with_file(fn, trainer, preprocess=lambda x: avis_pat.match(x.strip()).group(1))

params = trainer.get_params()
punkt = PunktSentenceTokenizer(params)
cPickle.dump(punkt, 'punkt-norwegian-open.pickle')

# full model
vars = PunktLanguageVars
vars.sent_end_chars = (u".", u"?", u"!", u")", u"\"", u"'", u":", u"|", u"»", u"]")
trainer = PunktTrainer(lang_vars=vars())

train_with_file(gull_fn, trainer)
train_with_file(obt_fn, trainer)

for fn in glob(os.path.join(avis_path, '*.s')):
    train_with_file(fn, trainer, preprocess=lambda x: avis_pat.match(x.strip()).group(1))

for fn in glob(os.path.join(opc_path, '*.sent')):
    train_with_file(fn, trainer)

params = trainer.get_params()
punkt = PunktSentenceTokenizer(params)
cPickle.dump(punkt, 'punkt-norwegian-full.pickle')
