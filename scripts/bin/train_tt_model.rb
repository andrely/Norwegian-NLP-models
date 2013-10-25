#!/bin/env ruby

require 'optparse'
require 'fileutils'
require 'logger'
require 'date'
require 'ostruct'

require 'textlabnlp/tree_tagger_config'
require 'textlabnlp/tree_tagger'
require 'textlabnlp/multi_processing'

require_relative '../utilities'
require_relative '../sources/conll_source'
require_relative '../sources/concatenated_source'
require_relative '../sources/tree_tagger_source'
require_relative '../processors/tree_tagger_processor'
require_relative '../processors/fold_processor'

logger = Logger.new($stderr)

options = OpenStruct.new

today_str = Time.now.strftime('%Y-%m-%d')

options.tree_tagger_path = nil
options.model_out_path = "tt_#{today_str}"
options.model_fn = "tt_#{today_str}"
options.open_class_fn = nil
options.clean = nil
options.evaluate = nil
options.k_folds = 10

parser = OptionParser.new() do |opts|
  opts.banner = "Usage: train_tt_model.rb [options] FILES ..."

  opts.on("-p", "--treetagger-path PATH", "Path to TreeTagger installation.") do |path|
    options.tree_tagger_path = path
  end

  opts.on("-d", "--data-dir PATH", "Directory where the model and training data is stored.") do |path|
    options.model_out_path = path
  end

  opts.on("-m", "--model-file FILE", "Filename of created model.") do |fn|
    options.model_fn = fn
  end

  opts.on("-o", "--open-class-file FILE", "TreeTagger open class file.") do |fn|
    options.open_class_fn = fn
  end

  opts.on("-c", "--clean", "Remove all intermediate training files.") do |c|
    options.clean = c
  end

  opts.on("-e", "--evaluate [K]", Integer, "Evaluate model with K-fold cross validation (default: 10).") do |k|
    options.evaluate = true
    options.k_folds = k || 10
  end
end

parser.parse!

input_fns = ARGV

if input_fns.empty?
  puts parser
  exit(1)
end

logger.info("Writing training files to #{options.model_out_path}")
FileUtils.mkpath(options.model_out_path)

def setup_source(fns, processor=nil)
  # Setup source for each input file.
  sources = fns.collect do |fn|
    f = File.open(fn)
    ConllSource.new(f, columns: [:form, :lemma, :pos])
  end

  ConcatenatedSource.new(sources, processor: processor)
end

if options.evaluate
  gen = TreeTaggerProcessor.new(base_name: File.join(options.model_out_path, 'tt'))
  fold = FoldProcessor.new(num_folds: options.k_folds, fold_type: :block, processor: gen)

  src = setup_source(input_fns, fold)

  src.process_all

  a = src.pipeline_artifacts[0]

  src.sources.each { |f| f.close if not f.closed? }

  inputs = a.fold_ids.collect do |fold_id|
    { id: fold_id,
      in: a.path(:in, fold_id),
      lexicon: a.path(:lexicon, fold_id),
      open: options.open_class_fn || a.path(:open, fold_id),
      model: File.join(options.model_out_path,
                       "#{options.model_fn}_#{fold_id}.par"),
      config: {path: options.tree_tagger_path},
      pred: a.path(:pred, fold_id),
      true_fn: a.path(:true, fold_id) }
  end

  scores = TextlabNLP.mp_map(inputs) do |input, log_str|
    log_str.puts("Training model for fold #{input[:id]}")

    model = TextlabNLP::TreeTagger.new(
        config: TextlabNLP::TreeTaggerConfig.train(input[:in],
                                                   input[:open],
                                                   input[:lexicon],
                                                   input[:model],
                                                   config: input[:config]))

    log_str.puts("Predicting for fold #{input[:id]}")

    pred_words = nil
    true_words = nil

    File.open(input[:pred]) do |f|
      pred_words = model.annotate(file: f).collect { |s| s[:words] }.flatten
    end

    log_str.puts("Scoring for fold #{input[:id]}")
    File.open(input[:true_fn]) do |f|
      true_words = TreeTaggerSource.new(f, columns: [:form, :pos, :lemma]).to_a.collect { |s| s[:words] }.flatten
    end

    correct_tag = 0
    correct_lemma = 0
    total = 0

    unless pred_words.length == true_words.length
      log_str.puts("Predicted and true lengths are not equal (#{pred_words.length}/#{true_words.length})")
    end

    pred_words.zip(true_words).each do |pred_word, true_word|
      if pred_word[:word] != true_word[:form]
        log_str.puts("Predicted and true word forms does not agree (#{total+1}/#{pred_word[:word]}/#{true_word[:form]})")
      end

      if pred_word[:annotation][0][:lemma] == true_word[:lemma]
        correct_lemma += 1
      end

      if pred_word[:annotation][0][:tag] == true_word[:pos]
        correct_tag += 1
      end

      total += 1
    end

    [input[:id],
     correct_lemma, total, correct_lemma/total.to_f,
     correct_tag, total, correct_tag/total.to_f]
  end

  logger.info("Got results from #{scores.length} folds")

  tag_scores = scores.collect { |s| s[6] }
  tag_mean = Utilities.mean(tag_scores)
  tag_std = Utilities.stddev(tag_scores)
  lemma_scores = scores.collect { |s| s[3] }
  lemma_mean = Utilities.mean(lemma_scores)
  lemma_std = Utilities.stddev(lemma_scores)

  logger.info("#{options.k_folds}-fold evaluation: " +
                  "pos #{'%.4f' % tag_mean}\u00b1#{'%.4f' % tag_std}, " +
                  "lemma #{'%.4f' % lemma_mean}\u00b1#{'%.4f' % lemma_std}")
  logger.info("Writing evaluation results to #{options.model_fn}.evaluation")

  File.open("#{options.model_fn}.evaluation", 'w') do |f|
    f.puts("fold\tlemma_corr\tlemma_tot\tlemma_acc\tpos_corr\tpos_tot\tpos_acc")

    scores.each { |s| f.puts(s.join("\t")) }

    f.puts
    f.puts("Over #{options.k_folds}:")
    f.puts("pos   accuracy: #{tag_mean}\u00b1#{tag_std}")
    f.puts("lemma accuracy: #{lemma_mean}\u00b1#{lemma_std}")
  end
end

# Setup combined source and treetagger input file generator
gen = TreeTaggerProcessor.new(base_name: File.join(options.model_out_path, 'tt'))
src = setup_source(input_fns, gen)

# generate files
src.process_all

# close the input files
src.sources.each { |f| f.close if not f.closed? }

# create model
a = src.pipeline_artifacts[0]
TextlabNLP::TreeTagger.new(config: TextlabNLP::TreeTaggerConfig.train(a.path(:in),
                                                                      options.open_class_fn || a.path(:open),
                                                                      a.path(:lexicon),
                                                                      "#{options.model_fn}.par",
                                                                      config: {path: options.tree_tagger_path}))

if options.clean
  logger.warn("Deleting training files in #{options.model_out_path}")
  FileUtils.remove_entry_secure(options.model_out_path)
end