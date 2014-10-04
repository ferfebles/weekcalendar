# Sound effects for autotest
# http://fozworks.com/2007/7/28/autotest-sound-effects

# This plugin will trigger sounds. You will need a command-line
# sound player to do this. See the README file for more details.
#
# 1.2 - doc patch for bad path 2007-08-01
# 1.1 - updated for Windows 2007-07-31
# 1.0 - initial release 2007-07-28
module Autotest::Sonictest
  SOUND_PATH = '../tools/sonictest'
  SOUND_APP = 'afplay'
  PROCESS_DEVNULL = ''

  def self.playsound(file)
    cmd = "#{SOUND_APP} #{SOUND_PATH}/#{file} #{PROCESS_DEVNULL}"
    system cmd
  end

  [:red, :green, :quit, :run_command, :ran_command].each do |hook|
    Autotest.add_hook hook do |at|
      playsound "#{hook}.mp3" unless $TESTING
    end
  end
end
