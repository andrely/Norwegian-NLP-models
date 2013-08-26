require 'fileutils'

require_relative 'sources/conll_source'
require_relative 'processors/flat_text_processor'

FileUtils.mkpath('../flat/') unless File.exists?('../flat/')

flat_gull = FlatTextProcessor.new(basename: '../flat/gull.flat')
src_gull = ConllSource.new(File.open('../130606_bm_gullkorpus.conll'), processor: flat_gull)

src_gull.process_all

flat_obt = FlatTextProcessor.new(basename: '../flat/obt.flat')
src_obt = ConllSource.new(File.open('../obt-bm-utf8.vrt'),
                          columns: [:form, :lemma, :pos],
                          processor: flat_obt)

src_obt.process_all
