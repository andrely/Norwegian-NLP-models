require_relative 'logger_mixin'

##
# @abstract
class BaseModel

  include Logging

  ##
  # @option opts [String] :model_fn Path to model file, if it does not exist it can be created with
  #   @see TreeTaggerModel::train.
  # @option opts [Artifact] :artifact Construct model(s) from this artifact instance.
  def initialize(opts={})
    @artifact = opts[:artifact] || nil
    @model_fn = opts[:model_fn] || nil

    if @artifact
      train
    end
  end

  ##
  # @abstract
  def train(opts={})
    raise NotImplementedError
  end

  ##
  # @abstract
  def predict(opts={})
    raise NotImplementedError
  end

  ##
  # @abstract
  def score(opts={})
    raise NotImplementedError
  end

  ##
  # @private
  def model_fn(fold_id=nil)
    if @model_fn
      raise RuntimeError if fold_id
      @model_fn
    elsif @artifact and @artifact.has_folds?
      raise RuntimeError unless fold_id
      return "#{@artifact.basename(fold_id)}.#{self.class.default_model_fn_suffix}"
    elsif @artifact
      raise RuntimeError if fold_id
      return "#{@artifact.basename}.#{self.class.default_model_fn_suffix}"
    else
      raise RuntimeError
    end
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

  ##
  # @abstract
  def validate_binaries
    raise NotImplementedError
  end
end