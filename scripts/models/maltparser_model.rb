require_relative 'base_model'
require_relative '../utilities'

##
# Wrapper for the Maltparser commaind line tools.
class MaltparserModel < BaseModel

  class << self
    attr_accessor :jar_fn
  end

  @jar_fn = "/Users/stinky/Work/tools/maltparser-1.7.2/maltparser-1.7.2.jar"

  def train(opts={})
    train_fn = opts[:train_fn] || nil
    artifact = opts[:artifact] || nil

    if train_fn and artifact
      raise RuntimeError
    elsif train_fn.nil? and artifact.nil? and @artifact
      train_with_artifact(@artifact)
    elsif train_fn
      train_with_file(train_fn)
    elsif artifact
      train_with_artifact(artifact)
    elsif @artifact
      train_with_artifact(@artifact)
    else
      raise RuntimeError
    end

    self
  end

  ##
  # @private
  def train_with_artifact(artifact)
    if artifact.has_folds?
      artifact.fold_ids.each do |fold_id|
        logger.info "Training artifact #{artifact.id} fold #{fold_id}"
        artifact.open(:in, 'r', fold_id) do |file|
          train_internal(file)
        end
      end
    else
      logger.info "Training artifact #{artifact.id}"
      artifact.open(:in, 'r') do |file|
        train_internal(file)
      end
    end
  end

  ##
  # @private
  def train_with_file(train_fn)
    File.open(train_fn) do |file|
      train_internal(file)
    end
  end

  ##
  # @private
  def train_internal(train_file)
    Logging.logger.info("Training maltparser model #{model_fn}.mco")
    cmd = "java -jar #{MaltparserModel.jar_fn} -c #{model_fn} -m learn"
    Logging.logger.info("Training with command #{cmd}")
    Utilities.run_shell_command(cmd, train_file)
  end

  def predict(opts={})

  end

  ##
  # @private
  def predict_internal(in_file, out_file)
    logger.info "Predicting using #{model_fn}"
    cmd = "java -jar #{MaltparserModel.jar_fn} -c #{model_fn} -m parse"
    logger.info "Predicting with command: #{cmd}"
    Utilities.run_shell_command(cmd, in_file, out_file)
  end

  def self.validate_binaries
    out = Utilities.runnable?("java -jar #{MaltparserModel.jar_fn} -h 2>&1")

    #noinspection RubyControlFlowConversionInspection
    if not out
      return false
    else
      out = out.strip.split("\n")

      unless out.count > 1 and out[1].strip == "MaltParser 1.7.2"
        return false
      end
    end

    return true
  end

  def validate_model
    if @model_fn
      File.exist?("#{@model_fn}.mco")
    elsif @artifact and @artifact.has_folds?
      @artifact.fold_ids.each do |fold_id|
        unless File.exists?("#{model_fn(fold_id)}.mco")
          return false
        end
      end
    elsif @artifact
      return File.exists?("#{model_fn}.mco")
    else
      false
    end
  end
end