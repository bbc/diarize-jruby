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
require 'ostruct'
require 'uri'

class TestSegment < Test::Unit::TestCase

  def test_initialize
    segment = Diarize::Segment.new('audio', 'start', 'duration', 'gender', 'bandwidth', 'speaker_id')
    assert_equal segment.instance_variable_get('@audio'), 'audio'
    assert_equal segment.instance_variable_get('@start'), 'start'
    assert_equal segment.instance_variable_get('@duration'), 'duration'
    assert_equal segment.instance_variable_get('@speaker_gender'), 'gender'
    assert_equal segment.instance_variable_get('@bandwidth'), 'bandwidth'
    assert_equal segment.instance_variable_get('@speaker_id'), 'speaker_id'
  end

  def test_speaker
    segment = Diarize::Segment.new(OpenStruct.new({:base_uri => 'http://example.com'}), nil, nil, 'm', nil, 's1') 
    assert_equal segment.speaker.object_id, segment.speaker.object_id # same one should be generated twice
    assert_equal segment.speaker.uri, URI('http://example.com#s1')
    assert_equal segment.speaker.gender, 'm'
  end

  def test_uri
    segment = Diarize::Segment.new(OpenStruct.new({:base_uri => 'http://example.com'}), 2, 5, 'm', nil, 's1')
    assert_equal segment.uri, URI('http://example.com#t=2,7')
  end

end
