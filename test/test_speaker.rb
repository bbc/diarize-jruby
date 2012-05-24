require 'helper'

class TestSpeaker < Test::Unit::TestCase

  def test_find_or_create_gives_same_object_if_called_with_same_id
    speaker1 = Diarize::Speaker.find_or_create('S0', 'M')
    speaker2 = Diarize::Speaker.find_or_create('S0', 'M')
    assert_equal speaker2, speaker1
  end

end
