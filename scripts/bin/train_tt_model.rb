#!/bin/env ruby

require 'optparse'
require 'fileutils'
require 'logger'
require 'date'

require 'textlabnlp/tree_tagger_config'
require 'textlabnlp/tree_tagger'

require_relative '../sources/conll_source'
require_relative '../sources/concatenated_source'
require_relative '../processors/tree_tagger_processor'

logger = Logger.new($stderr)

today_str = Time.now.strftime('%Y-%m-%d')
tree_tagger_path = nil
model_out_path = "tt_#{today_str}"
model_fn = "tt_#{today_str}.par"
open_class_fn = nil

parser = OptionParser.new() do |opts|
  opts.banner = "Usage: train_tt_model.rb [options] FILES ..."

  opts.on("-p", "--treetagger-path PATH", "Path to TreeTagger installation.") do |path|
    tree_tagger_path = path
  end

  opts.on("-d", "--data-dir PATH", "Directory where the model and training data is stored.") do |path|
    model_out_path = path
  end

  opts.on("-m", "--model-file FILE", "Filename of created model.") do |fn|
    model_fn = fn
  end

  opts.on("-o", "--open-class-file FILE", "TreeTagger open class file.") do |fn|
    open_class_fn = fn
  end
end

parser.parse!

input_fns = ARGV

if input_fns.empty?
  print parser
  exit(1)
end

logger.info("Writing training files to #{model_out_path}")
FileUtils.mkpath(model_out_path)

# Setup source for each input file.
sources = input_fns.collect do |fn|
  f = File.open(fn)
  ConllSource.new(f, columns: [:form, :lemma, :pos])
end

# Setup combined source and treetagger input file generator
gen = TreeTaggerProcessor.new(base_name: File.join(model_out_path, 'tt'))
src = ConcatenatedSource.new(sources, processor: gen)

# generate files
src.process_all

# close the input files
sources.each { |f| f.close if not f.closed? }

# create model
a = src.pipeline_artifacts[0]
model = TextlabNLP::TreeTagger.new(config: TextlabNLP::TreeTaggerConfig.train(a.path(:in),
                                                                              open_class_fn || a.path(:open),
                                                                              a.path(:lexicon),
                                                                              model_fn,
                                                                              config: { path: tree_tagger_path }))
