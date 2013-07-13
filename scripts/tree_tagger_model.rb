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

    cmd = "#{@tt_predict_bin} -token -lemma #{@par_fn} #{in_fn} #{out_fn}"
    Utilities.run_shell_command(cmd)
  end

  def self.score(opts={})
    pred_fn = opts[:pred_fn] || nil
    true_fn = opts[:true_fn] || nil

    unless pred_fn and true_fn
      raise ArgumentError
    end

    correct = 0
    total = 0

    Utilities.multiple_file_open [pred_fn, true_fn], 'r' do |files|
      pred_file, true_file = files

      begin
        pred_line = self.parse_tt_line
        true_line = self.parse_tt_line

        if pred_line == tt_line
          correct += 1
        end

        total += 1

      end while pred_line and true_line
    end

    return correct, total
  end

  def validate_model
    File.exist? @par_fn
  end
end
