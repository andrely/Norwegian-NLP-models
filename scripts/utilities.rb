require 'open3'
require 'io/wait'

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

  # Runs an external shell command.
  #
  # @note Stderr output is written to STDERR. Stdout output is written to STDOUT if no stdout_file
  #   argument is given.
  #
  # @param cmd [String] The shell command string. Should not include pipes.
  # @param stdin_file [IO, NilClass] IO instance to read input to the shell process from.
  # @param stdout_file [IO, NilClass] IO instance to write shell process output to.
  # @return [Process::Status] Shell command exit status.
  def self.run_shell_command(cmd, stdin_file=nil, stdout_file=nil)
    if stdin_file
      stdin, stdout, stderr, thr = Open3.popen3 cmd

      oe = ""
      err = ""

      # read and write stdin/stdout/stderr to avoid deadlocking on processes that blocks on writing.
      # e.g. HunPos
      stdin_file.each_line do |line|
        stdin.puts line

        while stdout.ready?
          oe += stdout.readline
        end

        while stderr.ready?
          err += stderr.readline
        end
      end

      stdin.close

      # get the rest of the output
      oe += stdout.read
      stdout.close

      err += stderr.read
      stderr.close

      # wait and get get Process::Status
      s = thr.value
    else
      out, err, s = Open3.capture3(cmd)
    end

    # echo errors on STDERR
    STDERR.puts err

    if stdout_file
      stdout_file.write(oe)
    else
      puts out
    end

    return s
  end

  def self.get_script_path
    path = File.dirname __FILE__

    return path
  end
end
