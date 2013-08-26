require 'fileutils'

require_relative 'logger_mixin'
require_relative 'sources/conll_source'
require_relative 'sources/sampled_source'
require_relative 'sources/concatenated_source'
require_relative 'processors/pos_builder_processor'
require_relative 'processors/frequency_statistics_processor'
require_relative 'processors/hunpos_processor'
require_relative 'processors/fold_processor'
require_relative 'models/hunpos_model'

def report(scores, columns)
  scores.each do |name, score|
    $stdout.write(name.to_s)
    columns.each do |col|
      $stdout.printf("\t%0.4f", score[col])
    end

    $stdout.puts
  end
end

def get_source(file, cols)
  if file.kind_of? IO
    return ConllSource.new(file, columns: cols)
  elsif file.kind_of? Enumerable
    sources = file.zip(cols).collect { |f, c| ConllSource.new(f, columns: c) }
    return ConcatenatedSource.new(sources)
  end
end

def training_curve(file, path, cols=nil)
  src = get_source(file, cols)

  steps = 4.times.collect { |i| (src.size.to_f / 4) * (i+1) }

  steps = steps.collect { |s| (s / 1000).round * 1000 }
  steps[-1] = src.size

  # puts steps

  scores = {}

  steps.each do |s|
    src.reset
    step_path = "../#{path}/#{s.to_s}/"
    FileUtils.mkpath(step_path) unless File.exists?(step_path)
    writer = HunposProcessor.new(base_name: File.join(step_path, "hunpos"))
    folds = FoldProcessor.new(num_folds: 5, processor: writer)
    stats = FrequencyStatisticsProcessor.new(columns: [:pos], processor: folds,
                                             base_name: File.join(step_path, "stats"))
    pos = POSBuilderProcessor.new(processor: stats)
    sampled = SampledSource.new(src, n: s, processor: pos)

    sampled.process_all

    artifact = sampled.pipeline_artifacts.first
    model = HunposModel.new(artifact: artifact)
    model.predict


    scores[s] = model.score
  end

  if file.kind_of? IO
    file.close
  elsif file.kind_of? Enumerable
    file.each { |f| f.close }
  end

  report(scores, [:train, :test])
end

Logging.logger.level = Logger::WARN
Utilities.external_command_silent = true

puts('Gull+OBT')
training_curve([File.open('../130606_bm_gullkorpus.conll'), File.open('../obt-bm-utf8.vrt')],
               'training_curve_gull_obt', [nil, [:form, :lemma, :pos]])
puts('Gull')
training_curve(File.open('../130606_bm_gullkorpus.conll'), 'training_curve_gull')
puts('OBT')
training_curve(File.open('../obt-bm-utf8.vrt'), 'training_curve_obt', [:form, :lemma, :pos])
