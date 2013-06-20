class FoldGenerator
  def initialize(reader, n_folds = 5)
    @reader = reader
    @n_folds = n_folds
    @sentence_count = get_sentence_count @reader
    @folds = nil
  end

  def get_sentence_count(reader)
    return reader.size
  end

  def get_folds &block
    populate_folds unless @folds

    return @folds
  end

  def populate_folds
    @folds = @n_folds.times.collect { [] }

    @reader.each_with_index do |sent, sent_idx|
      excepted_fold = sent_idx % @n_folds

      @folds.each_with_index do |fold, fold_idx|
        unless fold_idx == excepted_fold
          fold << sent
        end
      end
    end

    return @folds
  end
end
