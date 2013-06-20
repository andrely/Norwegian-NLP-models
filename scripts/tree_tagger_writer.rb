require_relative 'logger_mixin'

class TreeTaggerWriter

  include Logging

  @@nn_closed_class_pos = %w(subst verb ufl adj adv fork interj symb ukjent)

  def initialize(reader)
    @reader = reader
  end

  def create_files(in_file, lex_file, open_class_file)
    lexicon = {}
    open_classes = []

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

        in_file.write "#{form}\t#{pos}\n"

        lex_form = form.downcase

        lemma = word[:lemma].downcase

        lookup = lexicon[lex_form]

        if not lookup
          lexicon[lex_form] = { pos => [lemma] }
        elsif not lookup.has_key? pos
          lookup[pos] = [lemma]
        elsif lookup.has_key? pos
          unless lookup[pos].detect { |l| l == lemma}
            lookup[pos] << lemma
            Logging.logger.info "Combining lemma #{lookup[pos].join('_')} for form #{form}, pos #{pos}"
          end
        end

        if @@nn_closed_class_pos.find { |p| p == word[:pos] } and not open_classes.find { |p| p == pos}
          open_classes << pos
        end
      end
    end

    lexicon.each_pair do |k, v|
      lex_file.write k

      v.each_pair do |pos, lemmas|
        lex_file.write "\t#{pos} #{lemmas.join('_')}"
      end

      lex_file.write "\n"
    end

    open_class_file.write open_classes.join(' ')
    open_class_file.write "\n"
  end
end
