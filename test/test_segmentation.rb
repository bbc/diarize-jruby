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

require 'helper'
require 'tempfile'

class TestSegmentation < Test::Unit::TestCase

  def test_segmentation_from_empty_seg_file
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    seg_file = Tempfile.new(['diarize-jruby', '.seg'])
    seg_file.write ''
    seg_file.close
    segmentation = Diarize::Segmentation.from_seg_file(audio, seg_file.path)
    assert_equal segmentation.size, 0
  end

  def test_segmentation_from_sef_file
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    seg_file = Tempfile.new(['diarize-jruby', '.seg'])
    seg_file.write <<EOF
foo 1 0 1000 F S U S0
foo 1 1000 10000 M S U S1
EOF
    seg_file.close
    segmentation = Diarize::Segmentation.from_seg_file(audio, seg_file.path)
    assert_equal segmentation.size, 2
    assert_equal segmentation.first.class, Diarize::Segment
    assert_equal segmentation.first.start, 0
    assert_equal segmentation.first.duration, 10
    assert_equal segmentation.first.speaker.uri, URI(audio_uri.to_s + '#S0')
    assert_equal segmentation.first.speaker.gender, 'F'
    assert_equal segmentation.last.class, Diarize::Segment
    assert_equal segmentation.last.start, 10
    assert_equal segmentation.last.duration, 100
    assert_equal segmentation.last.speaker.uri, URI(audio_uri.to_s + '#S1')
    assert_equal segmentation.last.speaker.gender, 'M'
  end

end
