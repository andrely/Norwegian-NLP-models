require_relative 'tree_tagger_source'
require_relative 'utilities'
require_relative 'logger_mixin'

class TreeTaggerModel

  include Logging

  def initialize(model_fn)
    @tt_train_bin = '/Users/stinky/Work/tools/treetagger/bin/train-tree-tagger'
    @tt_predict_bin = '/Users/stinky/Work/tools/treetagger/bin/tree-tagger'

    @par_fn = model_fn
  end

  def train(in_fn, lex_fn, open_fn)
    logger.info "Training TreeTagger model #{@par_fn}"
    cmd = "#{@tt_train_bin} #{lex_fn} #{open_fn} #{in_fn} #{@par_fn}"
    logger.info "Training with command: #{cmd}"
    Utilities.run_shell_command(cmd)
  end

  def predict(opts={})
    in_fn = opts[:in_fn] || nil
    out_fn = opts[:out_fn] || nil

    unless in_fn and out_fn
      raise ArgumentError
    end

    unless validate_model
      raise ArgumentError
    end

    logger.info "Predicting #{in_fn} to #{out_fn} using #{@par_fn}"
    cmd = "#{@tt_predict_bin} -token -lemma #{@par_fn} #{in_fn} #{out_fn}"
    logger.info "Predicting with command: #{cmd}"
    Utilities.run_shell_command(cmd)
  end

  def self.score(opts={})
    pred_fn = opts[:pred_fn] || nil
    true_fn = opts[:true_fn] || nil

    unless pred_fn and true_fn
      raise ArgumentError
    end

    correct_tag = 0
    correct_lemma = 0
    total = 0

    Utilities.multiple_file_open [pred_fn, true_fn], 'r' do |files|
      pred_file, true_file = files

      pred_src = TreeTaggerSource.new pred_file, columns: [:form, :tag, :lemma]
      true_src = TreeTaggerSource.new true_file

      pred_words = pred_src.to_a.collect { |s| s[:words] }.flatten
      true_words = true_src.to_a.collect { |s| s[:words] }.flatten

      if pred_words.count != true_words.count
        logger.info "Predicted (#{pred_words.count} and true #{true_words.count} token count does not agree."
      end

      pred_words.zip(true_words).each do |pred_word, true_word|
        if pred_word[:form] != true_word[:form]
          logger.warn "Predicted and true word forms does not agree (#{total+1}/#{pred_word[:form]}/#{true_word[:form]})"
        end

        if pred_word[:lemma] == true_word[:lemma]
          correct_lemma += 1
        end

        if pred_word[:tag] == true_word[:tag]
          correct_tag += 1
        end

        total += 1
      end
    end

    return [correct_lemma, total, correct_lemma/total.to_f], [correct_tag, total, correct_tag/total.to_f]
  end

  def validate_model
    File.exist? @par_fn
  end
end
