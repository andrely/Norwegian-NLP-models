require_relative 'base_processor'

# Processor class that generates fold annotations on each sentence.
class FoldProcessor < BaseProcessor

  attr_reader :num_folds, :fold_type, :fold_size

  # @option opts [Fixnum] num_folds Number of folds.
  # @option opts [Symbol] fold_type Fold selection type.
  #   :interleaved - puts each sentence in different folds sequentially.
  #   :block - folds are contiguous.
  def initialize(opts = {})
    super(opts)

    # TODO no way to call num_folds= here ?
    @num_folds = opts[:num_folds] || 5
    @fold_type = opts[:fold_type] || :interleaved

    @fold_size = nil

    if @processor
      @processor.num_folds = @num_folds
    end
  end

  # @see BaseSource
  def process(sent)
    if sent.has_key? :fold
      raise ArgumentError
    end

    index = sent[:index]

    if @fold_type == :interleaved
      fold = index % @num_folds
    elsif @fold_type == :block
      fold = index / @fold_size
      fold = @num_folds - 1 if fold >= @num_folds
    else
      raise ArgumentError
    end


    sent[:fold] = fold

    sent
  end


  # @see BaseSource
  def pre_process
    if @fold_type == :block
      @fold_size = self.size / @num_folds
    end
  end

  def has_folds?
    true
  end

  def num_folds=(n)
    @num_folds = n

    if @processor
      @processor.num_folds = @num_folds
    end
  end
end
