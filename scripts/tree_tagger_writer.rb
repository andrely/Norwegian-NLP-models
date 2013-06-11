require_relative 'logger_mixin'

class TreeTaggerWriter

  include Logging

  @@no_closed_class_pos = ['subst', 'verb', 'ufl', 'adj', 'adv', 'fork', 'interj', 'symb', 'ukjent']

  def initialize(reader)
    @reader = reader
  end

  def create_files(fn)
    lexicon = {}
    open_classes = []

    File.open("#{fn}.in", 'w') do |out|
      @reader.each do |sent|
        len = sent.count

        sent.each_with_index do |word, i|
          form = word[:form]
          pos = word[:pos]

          if word[:feat] != '_'
            pos = pos + '_' + word[:feat].split('|').join('_')
          end

          if i == len - 1 # last word, replace POS
            pos = 'SENT'
          end

          out.write "#{form}\t#{pos}\n"

          lex_form = form.downcase

          lemma = word[:lemma].downcase

          lookup = lexicon[lex_form]

          if not lookup
            lexicon[lex_form] = { pos => [lemma] }
          elsif not lookup.has_key? pos
            lookup[pos] = [lemma]
          elsif lookup.has_key? pos
            if not lookup[pos].detect { |l| l == lemma}
              lookup[pos] << lemma
              Logging.logger.info "Combining lemma #{lookup[pos].join('_')} for form #{form}, pos #{pos}"
            end
          end

          if @@no_closed_class_pos.find word[:pos] and not open_classes.find pos
            open_classes << pos
          end
        end
      end
    end

    File.open("#{fn}.lex", 'w') do |out|
      lexicon.each_pair do |k, v|
        out.write k

        v.each_pair do |pos, lemmas|
          out.write "\t#{pos} #{lemmas.join('_')}"
        end

        out.write "\n"
      end
    end

    File.open("#{fn}.open", 'w') do |out|
      out.write open_classes.join(" ")
      out.write "\n"
    end
  end
end
