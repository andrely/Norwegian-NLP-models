require 'tmpdir'
require 'stringio'

require_relative 'tree_tagger_source'
require_relative 'utilities'
require_relative 'logger_mixin'

class TreeTaggerModel

  include Logging

  class << self
    attr_accessor :train_bin, :predict_bin, :default_model_fn_suffix
  end

  @train_bin = '/Users/stinky/Work/tools/treetagger/bin/train-tree-tagger'
  @predict_bin = '/Users/stinky/Work/tools/treetagger/bin/tree-tagger'

  @default_model_fn_suffix = "tt_model"

  ##
  # @option opts [String] :model_fn Path to model file, if it does not exist it can be created with
  #   @see TreeTaggerModel::train.
  # @option opts [Artifact] :artifact Fully constructed artifact.
  def initialize(opts={})

    @model_fn = opts[:model_fn] || nil
    @artifact = opts[:artifact] || nil

    if @artifact
      train
    end
  end

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

  def validate_model
    File.exist? model_fn
  end

  ##
  # @private
  def model_fn(fold_id=nil)
    if @model_fn
      raise RuntimeError if fold_id
      @model_fn
    elsif @artifact and @artifact.has_folds?
      raise RuntimeError unless fold_id
      return "#{@artifact.basename(fold_id)}.#{TreeTaggerModel.default_model_fn_suffix}"
    elsif @artifact
      raise RuntimeError if fold_id
      return "#{@artifact.basename}.#{TreeTaggerModel.default_model_fn_suffix}"
    else
      raise RuntimeError
    end
  end
end
