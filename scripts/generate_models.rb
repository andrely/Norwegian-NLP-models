require 'fileutils'

require_relative 'tree_tagger_model'
require_relative 'tree_tagger_processor'
require_relative 'fold_processor'
require_relative 'conll_source'
require_relative 'concatenation_processor'

def create_treetagger_files(base_fn)
  writer = TreeTaggerProcessor.new base_name: base_fn
  fold_writer = TreeTaggerProcessor.new(base_name: base_fn)

  src = ConllSource.new(File.open('130606_bm_gullkorpus.conll'),
                        processor: ConcatenationProcessor.new([writer,
                                                               FoldProcessor.new(num_folds: 10,
                                                                                 processor: fold_writer)]))

  src.process_all

  return writer.descr, fold_writer.descr
end

def create_treetagger_model descr
  model_fn = (descr[:in_file].path)[0..-3] + 'par'

  model = TreeTaggerModel.new model_fn
  model.train descr[:in_file].path, descr[:lex_file].path, descr[:open_class_file].path
end

def evaluate_treetagger_model model, in_fn, true_fn
  pred_fn = descr[:in_file][0..-3] + 'pred'

  model.predict :in_file => in_fn, :out_file => pred_fn
  score = TreeTaggerModel.score :pred_fn => pred_fn, :true_fn => true_fn

  print score
end

Dir.chdir '..'
puts Dir.getwd

path = 'integration_test'
fn = 'tt_test'

FileUtils.mkpath path unless File.exist? path

base_fn = File.join path, fn

descr, fold_descr = create_treetagger_files(base_fn)

create_treetagger_model descr

fold_descr.each do |d|
  create_treetagger_model d
end
