require_relative 'logger_mixin'
require_relative 'utilities'
require_relative 'conll_source'

class HunposModel

  include Logging

  @@hunpos_train_bin = '/Users/stinky/Documents/tekstlab/obt_stat/hunpos/hunpos-1.0-macosx/hunpos-train'
  @@hunpos_tag_bin = '/Users/stinky/Documents/tekstlab/obt_stat/hunpos/hunpos-1.0-macosx/hunpos-tag'

  def initialize(model_fn)
    @model_fn = model_fn
  end

  def train(train_file)
    Logging.logger.info "Training HunPos model #{@model_fn}"
    cmd = "#{@@hunpos_train_bin} #{@model_fn}"
    Logging.logger.info "Training with command: #{cmd}"
    Utilities.run_shell_command cmd, File.open(train_file)
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

    logger.info "Predicting #{in_fn} to #{out_fn} using #{@model_fn}"
    cmd = "#{@@hunpos_tag_bin} #{@model_fn}"
    logger.info "Predicting with command: #{cmd}"
    Utilities.run_shell_command(cmd, File.open(in_fn), File.open(out_fn, 'w'))
  end

  def score(opts={})
    pred_fn = opts[:pred_fn] || nil
    true_fn = opts[:true_fn] || nil

    unless pred_fn and true_fn
      raise ArgumentError
    end

    correct_tag = 0
    total = 0

    Utilities.multiple_file_open [pred_fn, true_fn], 'r' do |files|
      pred_file, true_file = files

      pred_src = ConllSource.new pred_file, columns: [:form, :pos]
      true_src = ConllSource.new true_file, columns: [:form, :pos]

      pred_words = pred_src.to_a.collect { |s| s[:words] }.flatten
      true_words = true_src.to_a.collect { |s| s[:words] }.flatten

      if pred_words.count != true_words.count
        logger.info "Predicted (#{pred_words.count} and true #{true_words.count} token count does not agree."
      end

      pred_words.zip(true_words).each do |pred_word, true_word|
        if pred_word[:form] != true_word[:form]
          logger.warn "Predicted and true word forms does not agree (#{total+1}/#{pred_word[:form]}/#{true_word[:form]})"
        end

        if pred_word[:pos] == true_word[:pos]
          correct_tag += 1
        end

        total += 1
      end
    end

    return [[correct_tag, total, correct_tag/total.to_f]]
  end

  def validate_model
    File.exist?(@model_fn)
  end
end
