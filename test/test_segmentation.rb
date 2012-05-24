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
