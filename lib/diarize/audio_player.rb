# diarize-jruby
# 
# Copyright (c) 2013 British Broadcasting Corporation
# 
# Licensed under the GNU Affero General Public License version 3 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.gnu.org/licenses/agpl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java'

module Diarize

  class AudioPlayer

    def play(file, start=0.0, duration=10.0)
      java_file = java.io.File.new(file.path)
      stream = javax.sound.sampled.AudioSystem.getAudioInputStream(java_file)
      clip = javax.sound.sampled.AudioSystem.clip
      clip.open(stream)
      clip.setMicrosecondPosition(start * 1000000)
      clip.start
      begin
        sleep(duration)
      rescue Exception
        $stderr.puts 'Stopping playback'
      end
      clip.stop
      clip.close
      stream.close
    end

  end

end
