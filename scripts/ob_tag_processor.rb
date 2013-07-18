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
      if word.has_key? :pos
        pos = OBTagProcessor.normalize_pos word[:pos]

        short_pos = @map[pos]

        if not short_pos
          logger.warn "Unknown pos #{word[:pos]} in sentence #{sent[:index]}"
        else
          word[:pos] = short_pos
        end
      else
        logger.warn "Word #{word[:form]} not annotated in sentence #{sent[:index]}"
      end
    end

    return sent
  end

  def self.parse_obt_map(file, map)
    file.each_line do |line|
      long_pos, short_pos = line.split
      long_pos = OBTagProcessor.normalize_pos long_pos
      short_pos.downcase!

      if map.has_key? long_pos
        Logging.logger.warn "Duplicate pos in OBT map file: #{long_pos} #{short_pos}"
      else
        map[long_pos] = short_pos
      end
    end

    return map
  end

  def self.normalize_pos(pos)
    return pos.split('_').sort().join('_').downcase
  end
end
