require 'fileutils'

require_relative 'tree_tagger_model'
require_relative 'tree_tagger_processor'
require_relative 'hunpos_processor'
require_relative 'fold_processor'
require_relative 'pos_builder_processor'
require_relative 'conll_source'
require_relative 'obt_source'
require_relative 'concatenation_processor'
require_relative 'concatenated_source'

def create_files(base_path, tt_fn, hunpos_fn)
  tt_full_path = File.join(base_path, tt_fn)
  hunpos_full_path = File.join(base_path, hunpos_fn)
  coll_log = File.new('lemma_collision_log', 'w')

  puts File.absolute_path coll_log.path

  tt_writer = TreeTaggerProcessor.new(base_name: tt_full_path,
                                      id: :tt_writer,
                                      lemma_collision_log: coll_log)
  hunpos_writer = HunposProcessor.new base_name: hunpos_full_path,
                                      id: :hunpos_writer

  fold_tt_writer = FoldProcessor.new num_folds: 10,
                                     processor: TreeTaggerProcessor.new(base_name: tt_full_path,
                                                                        id: :tt_fold_writer)
  fold_hunpos_writer = FoldProcessor.new num_folds: 10,
                                         processor: HunposProcessor.new(base_name: hunpos_full_path,
                                                                        id: :hunpos_fold_writer)

  all_writers = ConcatenationProcessor.new [hunpos_writer, tt_writer,
                                            fold_hunpos_writer, fold_tt_writer]

  pos_proc = POSBuilderProcessor.new processor: all_writers

  gull_src = ConllSource.new(File.open('130606_bm_gullkorpus.conll'))
  ob_src1 = ConllSource.new(File.open('trening-utf8.vrt'),
                            columns: [:form, :lemma, :pos])
  ob_src2 = ConllSource.new(File.open('test-utf8.vrt'),
                            columns: [:form, :lemma, :pos])
  all_src = ConcatenatedSource.new [gull_src, ob_src1, ob_src2],
                                   processor: pos_proc

  all_src.process_all

  return all_src.pipeline_artifacts
end

def create_treetagger_model(artifact, fold_id=nil)
  model_fn = artifact.basename(fold_id) + '.par'

  model = TreeTaggerModel.new model_fn
  model.train(artifact.path(:in, fold_id),
              artifact.path(:lexicon, fold_id),
              artifact.path(:open, fold_id))

  return model
end

def evaluate_treetagger_model artifact, fold_id = nil, model
  pred_fn = artifact.path(:pred, fold_id)
  true_fn = artifact.path(:true, fold_id)
  out_fn = artifact.basename(fold_id) + '.out'


  model.predict :in_fn => pred_fn, :out_fn => out_fn
  lemma_score, tag_score = TreeTaggerModel.score :pred_fn => out_fn, :true_fn => true_fn

  puts "Lemma score: " + lemma_score.join('/')
  puts "Tag score  : " + tag_score.join('/')
end

Dir.chdir '..'
puts Dir.getwd

base_path = 'integration_test'
tt_fn = 'tt_test'
hunpos_fn = 'hunpos_test'

FileUtils.mkpath base_path unless File.exist? base_path

artifacts = create_files(base_path, tt_fn, hunpos_fn)

tt_art = artifacts.detect { |d| d.id == :tt_writer }

create_treetagger_model tt_art

fold_tt_art = artifacts.detect { |d| d.id == :tt_fold_writer}

fold_tt_art.fold_ids.each do |i|
  m = create_treetagger_model fold_tt_art, i
  evaluate_treetagger_model fold_tt_art, i, m
end
