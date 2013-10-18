require_relative '../sources/conll_source'
require_relative '../sources/concatenated_source'
require_relative '../processors/tree_tagger_processor'
require_relative '../models/tree_tagger_model'

input_fns = ARGV

# Setup source for each input file.
sources = input_fns.collect do |fn|
  f = File.open(fn)
  ConllSource.new(f, columns: [:form, :lemma, :pos])
end

# Setup combined source and treetagger input file generator
gen = TreeTaggerProcessor.new(base_name: 'tt_test')
src = ConcatenatedSource.new(sources, processor: gen)
model = TreeTaggerModel.new(model_fn: 'test.par')

# generate files
src.process_all

# close the input files
sources.each { |f| f.close if not f.closed? }

# create model
model.train(artifact: src.pipeline_artifacts[0])
