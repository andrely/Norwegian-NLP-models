class Utilities
  def self.multiple_file_open(filenames, perm, &block)
    files = filenames.collect { |fn| File.open fn, perm }

    block.call files

    files.each { |file| file.close unless file.closed? }
  end

  def self.deep_copy(obj)
    # simple deep copy that works for our test fixtures
    return Marshal.load(Marshal.dump(obj))
  end
end
