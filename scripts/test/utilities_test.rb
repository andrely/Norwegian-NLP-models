require 'test/unit'

require_relative '../utilities'

class UtilitiesTest < Test::Unit::TestCase
  def test_run_shell_cmd
    # pretend we're in a unixy place
    assert_equal 0, Utilities.run_shell_command('ls')
  end
end