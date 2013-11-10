require 'date'
require 'fileutils'
require 'optparse'
require 'logger'

require_relative 'utilities'
require_relative 'sources/conll_source'
require_relative 'sources/concatenated_source'
require_relative 'processors/hunpos_processor'
require_relative 'processors/pos_builder_processor'
require_relative 'processors/frequency_statistics_processor'
require_relative 'processors/tree_tagger_processor'
require_relative 'processors/conll_processor'
require_relative 'processors/normalization_processor'
require_relative 'processors/fold_processor'
require_relative 'processors/concatenation_processor'
require_relative 'models/hunpos_model'
require_relative 'models/tree_tagger_model'
require_relative 'models/maltparser_model'

DATE_STR = DateTime.now.strftime("%Y-%m-%d")
BASE_PATH = "../models-#{DATE_STR}"

GULL_PATH = '../130606_bm_gullkorpus.conll'
OBT_PATH = '../obt-bm-utf8.vrt'

ALL_MODELS = [:hunpos, :tree_tagger]
NUM_FOLDS = 10
WRITERS = { hunpos: HunposProcessor, tree_tagger: TreeTaggerProcessor }
MODELS = { hunpos: HunposModel, tree_tagger: TreeTaggerModel }

ROUNDING_ACCURACY = 4

def evaluate_model(artifact, model_class, report_fn)
  File.open(report_fn, 'w') do |f|
    f.puts("Fold\ttokens\taccuracy")

    scores = []

    artifact.fold_ids.each do |fold_id|
      model_fn = artifact.basename(fold_id) + '.model'
      model = model_class.new(model_fn: model_fn)
      model.train(train_fn: artifact.path(:in, fold_id),
                  open_fn: artifact.path(:open, fold_id),
                  lexicon_fn: artifact.path(:lexicon, fold_id))

      pred_fn = artifact.path(:pred, fold_id)
      true_fn = artifact.path(:true, fold_id)
      out_fn = artifact.basename(fold_id) + '.out'


      model.predict :in_fn => pred_fn, :out_fn => out_fn
      _, total, accuracy  = model.score(:pred_fn => out_fn, :true_fn => true_fn)
      scores << accuracy
      f.puts("#{fold_id}\t#{total}\t#{accuracy.round(ROUNDING_ACCURACY)}")
    end

    f.puts
    f.puts("Mean accuracy: #{Utilities.mean(scores).round(ROUNDING_ACCURACY)}" +
               "\u00B1#{Utilities.stddev(scores).round(ROUNDING_ACCURACY)}")

    scores
  end
end

def create_files(path, models, corpus_files, folds=nil)
  FileUtils.mkpath(path) unless File.exists?(path)
  writers = []

  models.each do |model|
    base_name = File.join(path, "#{model}_#{DATE_STR}")
    writers << WRITERS[model].new(base_name: base_name, id: "#{model}_writer".to_sym)

    if folds
      writer = WRITERS[model].new(base_name: base_name, id: "#{model}_folds_writer".to_sym)
      writers << FoldProcessor.new(num_folds: folds, type: :block, processor: writer)
    end
  end

  writers_proc = ConcatenationProcessor.new(writers)
  stats = FrequencyStatisticsProcessor.new(processor: writers_proc)
  norm = NormalizationProcessor.ob_normalization_processor(processor: stats)
  pos = PosBuilderProcessor.new(processor: norm)

  sources = []

  corpus_files.each do |fn|
    f = File.open(fn, 'r')
    fn_id = "file_src_#{fn}".to_sym

    proc = case File.extname(fn)
             when '.vrt'
               ConllSource.new(f, columns: [:form, :lemma, :pos], id: fn_id)
             when '.conll'
               ConllSource.new(f, id: fn_id)
             else
               raise ArgumentError
           end

    sources << proc
  end

  src = ConcatenatedSource.new(sources, processor: pos)

  src.process_all

  src.sources.each { |s| s.close unless s.closed? }

  src.pipeline_artifacts
end

def create_maltparser_files(args)
  writer = ConllProcessor.new(args)
  stats = FrequencyStatisticsProcessor.new(processor: writer)
  pos = PosBuilderProcessor.new(processor: stats)

  File.open(GULL_PATH, 'r') do |file|
    src = ConllSource.new(file, processor: pos)

    src.process_all

    return src.pipeline_artifacts
  end
end

def create_hunpos_model(artifact)
  HunposModel.new(artifact: artifact)
end

def create_tt_model(artifact)
  TreeTaggerModel.new(artifact: artifact)
end

def create_mp_model(artifact)
  MaltparserModel.new(artifact: artifact)
end

if __FILE__ == $0
  logger = Logger.new(STDOUT)

  options = {}

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: create_models.rb [options]"

    opts.on("--tree-tagger", "Create TreeTagger model") do
      options[:models] = options.fetch(:models, []) << :tree_tagger
    end

    opts.on("--hunpos", "Create Hunpos model.") do
      options[:models] = options.fetch(:models, []) << :hunpos
    end

    opts.on("-e", "--evaluate [FOLDS]", Integer, "Evaluate model with FOLDS folds (defualt 10).") do |folds|
      options[:evaluate] = true
      options[:num_folds] = folds || NUM_FOLDS
    end

    opts.on("-o", "--output-dir DIR",
            "Write all training/evaluation data and models to DIR (default is current directory).") do |dir|
      options[:out_dir] = dir
    end
  end

  parser.parse!

  options[:models] = ALL_MODELS unless options[:models]
  options[:out_dir] = Dir.getwd unless options[:out_dir]
  corpus_files = ARGV

  options[:models].each { |m| logger.info("Creating #{m} model") }
  corpus_files.each { |fn| logger.info("Training with #{fn}") }
  logger.info("Writing data and models to #{options[:out_dir]}")
  logger.info("Evaluating with #{options[:num_folds]} folds") if options[:evaluate]

  folds = options[:num_folds] if options[:evaluate]
  artifacts = create_files(options[:out_dir], options[:models], corpus_files, folds)

  if options[:models].member?(:hunpos)
    create_hunpos_model(artifacts.find { |artifact| artifact.id == :hunpos_writer })

    if options[:evaluate]
      evaluate_model(artifacts.find { |artifact| artifact.id == :hunpos_folds_writer },
                     HunposModel, File.join(options[:out_dir], 'hunpos_evaluation'))
    end
  end

  if options[:models].member?(:tree_tagger)
    create_tt_model(artifacts.find { |artifact| artifact.id == :tree_tagger_writer })

    if options[:evaluate]
      evaluate_model(artifacts.find { |artifact| artifact.id == :tree_tagger_folds_writer },
                     TreeTaggerModel, File.join(options[:out_dir], 'treetagger_evaluation'))
    end
  end

  #mp_path = File.join(BASE_PATH, 'maltparser')
  #FileUtils.mkpath(mp_path) unless File.exists?(mp_path)
  #artifacts = create_maltparser_files({ base_name: File.join(mp_path, 'maltparser'),
  #                                      columns: [:id, :form, :lemma, :pos, :pos, :feat, :head, :deprel, :u1, :u2],
  #                                      pred_columns: [:id, :form, :lemma, :pos, :pos, :feat]})
  # create_mp_model(artifacts[0])
end
