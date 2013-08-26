require 'date'
require 'fileutils'

require_relative 'utilities'
require_relative 'sources/conll_source'
require_relative 'sources/concatenated_source'
require_relative 'processors/hunpos_processor'
require_relative 'processors/pos_builder_processor'
require_relative 'processors/frequency_statistics_processor'
require_relative 'processors/tree_tagger_processor'
require_relative 'models/hunpos_model'
require_relative 'models/tree_tagger_model'

BASE_PATH = "../models-#{Date.today.to_s}"

GULL_PATH = '../130606_bm_gullkorpus.conll'
OBT_PATH = '../obt-bm-utf8.vrt'

def create_hunpos_files(args)
  writer = HunposProcessor.new(args)
  stats = FrequencyStatisticsProcessor.new(processor: writer)
  pos = POSBuilderProcessor.new(processor: stats)

  Utilities.multiple_file_open([GULL_PATH, OBT_PATH], 'r') do |files|
    gull_file, obt_file = files

    gull_src = ConllSource.new(gull_file)
    obt_src = ConllSource.new(obt_file, columns: [:form, :lemma, :pos])
    src = ConcatenatedSource.new([gull_src, obt_src], processor: pos)

    src.process_all

    return src.pipeline_artifacts
  end
end

def create_tt_files(args)
  writer = TreeTaggerProcessor.new(args)
  stats = FrequencyStatisticsProcessor.new(processor: writer)
  pos = POSBuilderProcessor.new(processor: stats)

  Utilities.multiple_file_open([GULL_PATH, OBT_PATH], 'r') do |files|
    gull_file, obt_file = files

    gull_src = ConllSource.new(gull_file)
    obt_src = ConllSource.new(obt_file, columns: [:form, :lemma, :pos])
    src = ConcatenatedSource.new([gull_src, obt_src], processor: pos)

    src.process_all

    return src.pipeline_artifacts
  end
end

def create_maltparser_files(args)
  writer = MaltparserProcessor.new(args)
end

def create_hunpos_model(artifact)
  HunposModel.new(artifact: artifact)
end

def create_tt_model(artifact)
  TreeTaggerModel.new(artifact: artifact)
end

hunpos_path = File.join(BASE_PATH, 'hunpos')
FileUtils.mkpath(hunpos_path) unless File.exists?(hunpos_path)
artifacts = create_hunpos_files({ base_name: File.join(hunpos_path, "hunpos")})
create_hunpos_model(artifacts[0])

tt_path = File.join(BASE_PATH, 'treetagger')
FileUtils.mkpath(tt_path) unless File.exists?(tt_path)
artifacts = create_tt_files({ base_name: File.join(tt_path, 'treetagger') })
create_tt_model(artifacts[0])