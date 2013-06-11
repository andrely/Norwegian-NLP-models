require 'logger'

require_relative 'scripts/conll_reader'
require_relative 'scripts/tree_tagger_writer'
require_relative 'scripts/tree_tagger_trainer'

logger = Logger.new STDOUT

nn_corpus_fn = '130606_bm_gullkorpus.conll'
nn_tt_fn = 'nn_gullkorpus.tt'

task :generate_tt_input => [nn_corpus_fn] do
  File.open(nn_corpus_fn) do |file|
    reader = ConllReader.new file

    writer = TreeTaggerWriter.new reader
    writer.create_files nn_tt_fn
  end
end

task :generate_tt_model => [:generate_tt_input] do
  TreeTaggerTrainer.create_model("#{nn_tt_fn}.in", "#{nn_tt_fn}.lex", "#{nn_tt_fn}.open", "#{nn_tt_fn}.par")
end
