require_relative 'base_processor'
require_relative 'utilities'

class OBTagProcessor < BaseProcessor
  @@map_file = 'obt-map.txt'

  def initialize(processor=nil)
    super(processor)

    File.open(File.join(Utilities.get_script_path, @@map_file)) do |f|
      @map = OBTagProcessor.parse_obt_map f, Hash.new
    end
  end


  def process(sent)
    sent[:words].each do |word|
      if word.has_key? :tag
        tag = OBTagProcessor.normalize_tag word[:tag]

        short_tag = @map[tag]

        if not short_tag
          logger.warn "Unknown tag #{word[:tag]} in sentence #{sent[:index]}"
        else
          word[:tag] = short_tag
        end
      else
        logger.warn "Word #{word[:form]} not annotated in sentence #{sent[:index]}"
      end
    end

    return sent
  end

  def self.parse_obt_map(file, map)
    file.each_line do |line|
      long_tag, short_tag = line.split
      long_tag = OBTagProcessor.normalize_tag long_tag
      short_tag.downcase!

      if map.has_key? long_tag
        Logging.logger.warn "Duplicate tag in OBT map file: #{long_tag} #{short_tag}"
      else
        map[long_tag] = short_tag
      end
    end

    return map
  end

  def self.normalize_tag(tag)
    return tag.split('_').sort().join('_').downcase
  end
end