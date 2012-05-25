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
