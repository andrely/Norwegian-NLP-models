# Default behaviour for reader classes
class BaseReader
  include Enumerable

  def has_folds?
    return false
  end

  def num_folds
    return 1
  end
end