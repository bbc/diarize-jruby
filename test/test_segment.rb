require 'helper'

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

end
