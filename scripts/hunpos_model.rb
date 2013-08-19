require_relative 'logger_mixin'
require_relative 'utilities'
require_relative 'conll_source'
require_relative 'Utilities'

class HunposModel

  include Logging

  HUNPOS_TRAIN_BIN = '/Users/stinky/Documents/tekstlab/obt_stat/hunpos/hunpos-1.0-macosx/hunpos-train'
  HUNPOS_TAG_BIN = '/Users/stinky/Documents/tekstlab/obt_stat/hunpos/hunpos-1.0-macosx/hunpos-tag'

  DEFAULT_MODEL_FN_SUFFIX = 'hunpos_model'

  ##
  # @option opts [Artifact] :artifact Construct model(s) from this artifact instance.
  # @option opts [String] :model_fn Path to the stored HunPos model file.
  def initialize(opts={})
    @artifact = opts[:artifact] || nil
    @model_fn = opts[:model_fn] || nil

    if @artifact
      train(artifact: @artifact)
    end
  end

  ##
  # @note options :train_fn and :artifact can not be specified at the same time.
  #
  # @option opts [String] :train_fn Path to file with training data.
  # @option opts [Artifact] :artifact Artifact instance containing training data
  def train(opts={})
    train_fn = opts[:train_fn] || nil
    artifact = opts[:artifact] || nil

    if train_fn and artifact
      raise RuntimeError
    elsif train_fn
      train_with_file(train_fn, @model_fn)
    elsif artifact
      train_with_artifact(artifact)
    else
      raise RuntimeError
    end
  end
  
  ##
  # @private
  def model_fn(fold_id=nil)
    if @model_fn
      raise RuntimeError if fold_id
      @model_fn
    elsif @artifact and @artifact.has_folds?
      raise RuntimeError unless fold_id
      return "#{@artifact.basename(fold_id)}.#{DEFAULT_MODEL_FN_SUFFIX}"
    elsif @artifact
      raise RuntimeError if fold_id
      return "#{@artifact.basename}.#{DEFAULT_MODEL_FN_SUFFIX}"
    else
      raise RuntimeError
    end
  end

  ##
  # @private
  def train_with_file(train_fn, model_fn)
    train_internal(File.open(train_fn), model_fn)
  end

  ##
  # @private
  def train_internal(train_file, model_fn)
    Logging.logger.info "Training HunPos model #{model_fn}"
    cmd = "#{HUNPOS_TRAIN_BIN} #{model_fn}"
    Logging.logger.info "Training with command: #{cmd}"
    Utilities.run_shell_command cmd, train_file
  end

  ##
  # @private
  def train_with_artifact(artifact)
    if artifact.has_folds?
      artifact.fold_ids.each do |fold_id|
        logger.info "Training artifact #{artifact.id} fold #{fold_id}"
        train_internal(artifact.file(:in, fold_id), model_fn(fold_id))
      end
    else
      logger.info "Training artifact #{artifact.id}"
      train_internal(artifact.file(:in), model_fn)
    end
  end

  ##
  # @private
  def predict_with_file(model_fn, in_fn, out_fn)
    logger.info "Predicting #{in_fn} to #{out_fn}"
    predict_internal(model_fn, File.open(in_fn), File.open(out_fn, 'w'))
  end

  ##
  # @private
  def predict_internal(model_fn, in_file, out_file)
    logger.info "Predicting using #{model_fn}"
    cmd = "#{HUNPOS_TAG_BIN} #{model_fn}"
    logger.info "Predicting with command: #{cmd}"
    Utilities.run_shell_command(cmd, in_file, out_file)
  end

  ##
  # @note If predicting from a model based on an Artifact instance, the artifact input file will be used and the result
  #   will be written to a default location. :in_fn and :out_fn options are ignored
  #
  # @option opts [String] :in_fn Path to input file to be tagged.
  # @option opts [String] :out_fn Path to file which the tagged input will be written to.
  def predict(opts={})
    in_fn = opts[:in_fn] || nil
    out_fn = opts[:out_fn] || nil

    unless validate_model
      raise ArgumentError
    end

    if @model_fn
      unless in_fn and out_fn
        raise ArgumentError
      end

      predict_with_file(@model_fn, in_fn, out_fn)
    elsif @artifact and @artifact.has_folds?
      @artifact.fold_ids.each do |fold_id|
        logger.info "Predicting training data for artifact #{@artifact.id} fold #{fold_id}"
        out_fn = @artifact.path(:in_pred, fold_id) + '.out'
        predict_with_file(model_fn(fold_id), @artifact.path(:in_pred, fold_id), out_fn)

        logger.info "Predicting test data for artifact #{@artifact.id} fold #{fold_id}"
        out_fn = @artifact.path(:pred, fold_id) + '.out'
        predict_with_file(model_fn(fold_id), @artifact.path(:pred, fold_id), out_fn)
      end
    elsif @artifact
      if out_fn.nil?
        logger.info "Predicting training data for artifact #{@artifact.id}"
        out_fn = @artifact.path(:in_pred) + '.out'
      else
        logger.info "Predicting #{out_fn} with artifact #{@artifact.id}"
      end

      predict_with_file(model_fn, @artifact.path(:in_pred), out_fn)
    else
      raise RuntimeError
    end
  end

  def score(opts={})
    pred_fn = opts[:pred_fn] || nil
    true_fn = opts[:true_fn] || nil

    if @artifact and @artifact.has_folds?
      train_scores = []
      test_scores = []

      @artifact.fold_ids.each do |fold_id|
        train_scores += [score_with_files(@artifact.path(:in_pred, fold_id) + '.out',
                                       @artifact.path(:in, fold_id))]
        test_scores += [score_with_files(@artifact.path(:pred, fold_id) + '.out',
                                      @artifact.path(:true, fold_id))]
      end

      # remove scores where hunpos crashed
      train_scores.delete(nil)
      test_scores.delete(nil)

      { train_folds: train_scores,
        test_folds: test_scores,
        train: Utilities.mean(train_scores.collect { |score| score[2] }),
        test: Utilities.mean(test_scores.collect { |score| score[2] }) }
    elsif @artifact
      if (pred_fn and true_fn.nil?) or (true_fn and pred_fn.nil?)
        raise RuntimeError
      end

      if pred_fn and true_fn
        return score_with_files(pred_fn, true_fn)
      else
        return score_with_files(@artifact.path(:in_pred) + '.out', @artifact.path(:in))
      end
    else
      unless pred_fn and true_fn
        raise ArgumentError
      end

      score_with_files(pred_fn, true_fn)
    end
  end

  ##
  # @private
  def score_with_files(pred_fn, true_fn)
    unless File.exists?(pred_fn)
      logger.warn("Missing prediction file #{pred_fn} for scoring")

      return nil
    end

    Utilities.multiple_file_open [pred_fn, true_fn], 'r' do |files|
      pred_file, true_file = files

      score_internal(pred_file, true_file)
    end
  end

  ##
  # @private
  def score_internal(pred_file, true_file)
    correct_tag = 0
    total = 0

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

    return correct_tag, total, correct_tag/total.to_f
  end

  def validate_model
    if @model_fn
      File.exist?(@model_fn)
    elsif @artifact and @artifact.has_folds?
      @artifact.fold_ids.each do |fold_id|
        unless File.exists?(model_fn(fold_id))
          return false
        end
      end
    elsif @artifact
      return File.exists?(model_fn)
    else
      false
    end
  end
end
