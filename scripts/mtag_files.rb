require 'logger'
require 'optparse'

require 'textlabnlp/oslo_bergen_tagger'
require 'textlabnlp/globals'

logger = Logger.new(STDERR)

options = {}

opt_parser = OptionParser.new() do |opt|
  opt.banner = "mtag_files.rb [OPTIONS] FILES"
  opt.on("-v", "--verbose LEVEL", Numeric, "Debug output (1 or 2)") do |level|
    if 1 <= level and level <= 2
      options[:verbose_level] = level
    else
      puts opt
      exit(1)
    end
  end
end

opt_parser.parse!

if options.has_key?(:verbose_level)
  logger.level = Logger::INFO
else
  logger.level = Logger::WARN
end

if options[:verbose_level] == 2
  TextlabNLP.echo_external_command_output = true
end

fn_list = ARGV

if fn_list.nil? or fn_list.empty?
  logger.error("no files to mtag")
  exit(1)
end

tagger = TextlabNLP::OsloBergenTagger.new(config: { path: "/Users/stinky/Work/tools/OBT" })

logger.info("mtagging #{fn_list.count} files")

fn_list.each do |fn|
  File.open(fn) do |f|
    if File.exists?("#{fn}.mtag")
      logger.warn("skipping ... mtag output already exists for #{fn}")
      next
    end

    logger.info("mtagging #{fn}")
    begin
      out = tagger.annotate(file: f, mtag_only: true, format: :raw)


      if out.length > 0
        File.open("#{fn}.mtag", 'w') do |mtag_fn|
          mtag_fn.write(out)
        end
      else
        logger.warn("zero length mtag result for #{fn}")
      end
    rescue TextlabNLP::RunawayProcessError
      logger.warn("mtag failed on #{fn}")
    end
  end
end