class Utilities
  def self.multiple_file_open(filenames, perm, &block)
    files = filenames.collect { |fn| File.open fn, perm }

    block.call files

    files.each { |file| file.close unless file.closed? }
  end
end
