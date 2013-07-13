require 'open3'

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

  def self.run_shell_command(cmd)
    oe, s = Open3.capture2e(cmd)

    puts oe
    puts s

    return s
  end
end
