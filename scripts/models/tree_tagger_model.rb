require 'tmpdir'
require 'stringio'

require_relative 'base_model'
require_relative '../sources/tree_tagger_source'
require_relative '../utilities'

class TreeTaggerModel < BaseModel

  class << self
    attr_accessor :train_bin, :predict_bin, :default_model_fn_suffix
  end

  @train_bin = '/Users/stinky/Work/tools/treetagger/bin/train-tree-tagger'
  @predict_bin = '/Users/stinky/Work/tools/treetagger/bin/tree-tagger'

  @default_model_fn_suffix = "tt_model"

  def train(opts={})
    train_fn = opts[:train_fn] || nil
    lexicon_fn = opts[:lexicon_fn] || nil
    open_fn = opts[:open_fn] || nil
    artifact = opts[:artifact] || nil

    if train_fn and lexicon_fn and open_fn
      if artifact
        raise ArgumentError
      else
        train_internal(train_fn, lexicon_fn, open_fn)
      end
    elsif artifact
      train_with_artifact(artifact)
    elsif @artifact
      train_with_artifact(@artifact)
    end
  end

  ##
  # @private
  def train_with_io(in_file, lex_file, open_file)
    Dir.mktmpdir do |dir|
      in_path, lex_path, open_path = nil

      File.open(File.join(dir, 'in'), 'w') do |in_f|
        in_f.write(in_file.read)
        in_path = in_f.path
      end
      
      File.open(File.join(dir, 'lex'), 'w') do |lex_f|
        lex_f.write(lex_file.read)
        lex_path = lex_f.path
      end
      
      File.open(File.join(dir, 'open'), 'w') do |open_f|
        open_f.write(open_file.read)
        open_path = open_f.path
      end
      
      train_internal(in_path, lex_path, open_path)
    end

    self
  end
  
  ##
  # @private
  def train_with_artifact(artifact)
    if artifact.file_type == :mixed
      raise RuntimeError
    elsif artifact.file_type == StringIO
      artifact.file_ids { |file_id| artifact.file(file_id).rewind }
      train_with_io(artifact.file(:in), artifact.file(:lexicon), artifact.file(:open))
    elsif artifact.file_type == File
      artifact.file_ids { |file_id| artifact.file(file_id).rewind }
      train_internal(artifact.file(:in).path, artifact.file(:lexicon).path, artifact.file(:open).path)
    else
      raise RuntimeError
    end

    self
  end

  ##
  # @private
  def train_internal(in_fn, lex_fn, open_fn)
    logger.info "Training TreeTagger model #{model_fn}"
    cmd = "#{TreeTaggerModel.train_bin} #{lex_fn} #{open_fn} #{in_fn} #{model_fn}"
    logger.info "Training with command: #{cmd}"
    Utilities.run_shell_command(cmd)

    self
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

    logger.info "Predicting #{in_fn} to #{out_fn}"

    Utilities.multiple_file_open([in_fn, out_fn], 'w') do |files|
      in_file, out_file = files
      predict_internal(model_fn, in_file, out_file)
    end
  end

  def predict_internal(model_fn, in_file, out_file)
    logger.info "Predicting using #{model_fn}"
    cmd = "#{TreeTaggerModel.predict_bin} -token -lemma #{model_fn}"
    logger.info "Predicting with command: #{cmd}"
    Utilities.run_shell_command(cmd, in_file, out_file)
  end

  def score(opts={})
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

      pred_src = TreeTaggerSource.new pred_file, columns: [:form, :pos, :lemma]
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

        if pred_word[:pos] == true_word[:pos]
          correct_tag += 1
        end

        total += 1
      end
    end

    return [correct_lemma, total, correct_lemma/total.to_f], [correct_tag, total, correct_tag/total.to_f]
  end

  ##
  # Validates that the Treetagger 3rdparty binaries are present and runnable.
  # @return [TrueClass, FalseClass]
  def self.validate_binaries
    # Treetagger puts its help output on stderr
    out_train = Utilities.runnable?("#{TreeTaggerModel.train_bin} 2>&1")

    if not out_train
      Logging.logger.error("Could not run Treetagger train binary #{TreeTaggerModel.train_bin}")
      return false
    else
      out_train = out_train.strip.split("\n")

      unless out_train.count > 0 and out_train[0] == "USAGE: train-tree-tagger [options] <lexicon> <open class file> <input file> <output file>"
        Logging.logger.error("Could not run Treetagger train binary #{TreeTaggerModel.train_bin}")
        return false
      end
    end

    out_predict = Utilities.runnable?("#{TreeTaggerModel.predict_bin} 2>&1")

    if not out_predict
      Logging.logger.error("Could not run Treetagger predict binary #{TreeTaggerModel.predict_bin}")
      return false
    else
      out_predict = out_predict.strip.split("\n")

      unless out_predict.count > 0 and out_predict[0] == "USAGE:  tree-tagger {-options-} <parameter file> {<input file> {<output file>}}"
        Logging.logger.error("Could not run Treetagger predict binary #{TreeTaggerModel.predict_bin}")
        return false
      end
    end

    return true
  end
end
