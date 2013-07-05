class FoldGenerator
  include Enumerable

  def initialize(reader, n_folds = 5)
    @reader = reader
    @n_folds = n_folds
  end

  def each
    @reader.each do |sent|
      if sent.has_key? :fold
        raise ArgumentError
      end

      index = sent[:index]
      fold = index % @n_folds
      sent[:fold] = fold

      yield sent
    end
  end

  def has_folds?
    return true
  end

  def num_folds
    return @n_folds
  end
end
