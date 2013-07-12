require_relative '../utilities'

class DataRepository
  @@sample1 = [{index: 0,
               words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                       {:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                       {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample1
    return Utilities.deep_copy @@sample1
  end

  @@sample2 = [{index: 0,
                words: [{:form => 'ba', :pos => 'subst', :feat => 'ent', :lemma => 'foo'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]},
               {index: 1,
                words: [{:form => 'gneh', :pos => 'verb', :feat => 'pres', :lemma => 'knark'},
                        {:form => '.', :pos => 'clb', :feat => '_', :lemma => '$.'}]}]

  def self.sample2
    return Utilities.deep_copy @@sample2
  end

  @@sample3 = [{index: 0, words: []},
               {index: 1, words: []},
               {index: 2, words: []},
               {index: 3, words: []}]

  def self.sample3
    return Utilities.deep_copy @@sample3
  end

  @@sample3_n_folds = 3

  def self.sample3_n_folds
    return @@sample3_n_folds
  end
end
