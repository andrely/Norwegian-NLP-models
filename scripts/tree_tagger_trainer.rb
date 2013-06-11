require 'open3'

class TreeTaggerTrainer
  @@tt_train_bin = '/Users/stinky/Work/tools/treetagger/bin/train-tree-tagger'

  def self.create_model(in_fn, lex_fn, open_fn, model_fn)
    oe, s = Open3.capture2e("#{@@tt_train_bin} #{lex_fn} #{open_fn} #{in_fn} #{model_fn}")

    print oe
    print s
  end
end