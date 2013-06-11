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

require File.join(File.expand_path(File.dirname(__FILE__)), 'audio_player')

require 'rubygems'
require 'to_rdf'
require 'uri'

module Diarize

  class Segment

    attr_reader :start, :duration, :gender, :bandwidth

    def initialize(audio, start, duration, gender, bandwidth, speaker_id)
      @audio = audio
      @start = start
      @duration = duration
      @bandwidth = bandwidth
      @speaker_id = speaker_id
      @speaker_gender = gender
    end

    def speaker
      Speaker.find_or_create(URI("#{@audio.base_uri}##{@speaker_id}"), @speaker_gender)
    end

    def play
      player = AudioPlayer.new
      player.play(@audio.file, start, duration)
    end

    include ToRdf

    def namespaces
      super.merge 'ws' => 'http://wsarchive.prototype0.net/ontology/'
    end

    def uri
      # http://www.w3.org/TR/media-frags/
      URI("#{@audio.base_uri}#t=#{start},#{start+duration}")
    end

    def type_uri
      'ws:Segment'
    end

    def rdf_mapping
      {
        'ws:start' => start,
        'ws:duration' => duration,
        'ws:gender' => gender,
        'ws:bandwidth' => bandwidth,
        'ws:speaker' => speaker,
      }
    end

  end

end
