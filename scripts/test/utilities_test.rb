require 'test/unit'

require 'stringio'

require_relative '../utilities'

class UtilitiesTest < Test::Unit::TestCase
  def test_run_shell_cmd
    # pretend we're in a unixy place
    status = Utilities.run_shell_command('ls')
    assert_equal 0, status.exitstatus

    in_str = "ba\nfoo\nbork\nknark\n"
    in_file = StringIO.new(in_str)
    out_file = StringIO.new
    status = Utilities.run_shell_command('cat', stdin_file=in_file, stdout_file=out_file)
    assert_equal 0, status.exitstatus
    assert_equal in_file.string, out_file.string
  end
end