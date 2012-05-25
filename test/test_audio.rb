require 'helper'
require 'mocha'
require 'ostruct'

class TestAudio < Test::Unit::TestCase

  def setup
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    @audio = Diarize::Audio.new audio_uri
  end

  def test_initialize_file_uri
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.uri, audio_uri
    assert_equal audio.path, File.join(File.dirname(__FILE__), 'data', 'foo.wav')
  end

  def test_initialize_http_uri
    Kernel.expects(:system).with("wget http://example.com/test.wav -O /tmp/http%3A%2F%2Fexample.com%2Ftest.wav").returns(true)
    File.expects(:new).with('/tmp/http%3A%2F%2Fexample.com%2Ftest.wav').returns(true)
    audio_uri = URI('http://example.com/test.wav')
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.path, '/tmp/http%3A%2F%2Fexample.com%2Ftest.wav'
  end

  def test_clean_local_file
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).never
    audio.clean!
  end

  def test_clean_http_file
    Kernel.expects(:system).with("wget http://example.com/test.wav -O /tmp/http%3A%2F%2Fexample.com%2Ftest.wav").returns(true)
    File.expects(:new).with('/tmp/http%3A%2F%2Fexample.com%2Ftest.wav').returns(true)
    audio_uri = URI('http://example.com/test.wav')
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).with('/tmp/http%3A%2F%2Fexample.com%2Ftest.wav').returns(true)
    audio.clean!
  end

  def test_segments_raises_exception_when_audio_is_not_analysed
    assert_raise Exception do
      @audio.segments
    end
  end

  def test_analyze
    # TODO - We don't test the full ESTER2 algorithm for now
  end

  def test_segments
    @audio.instance_variable_set('@segments', [1, 2, 3])    
    assert_equal @audio.segments, [1, 2, 3]
  end

  def test_speakers_is_cached
    @audio.instance_variable_set('@speakers', [1, 2, 3])
    assert_equal @audio.speakers, [1, 2, 3]
  end

  def test_speakers
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ]) 
    assert_equal @audio.speakers, ['s1', 's2']
  end

  def test_segments_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.segments_by_speaker('s1'), [ segment1, segment1 ]
    assert_equal @audio.segments_by_speaker('s2'), [ segment2 ]
  end

  def test_duration_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.duration_by_speaker('s1'), 4
    assert_equal @audio.duration_by_speaker('s2'), 3
  end

  def test_top_speakers
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.top_speakers, ['s1', 's2']
  end

  def test_set_uri_and_type_uri
    @audio.uri = 'foo'
    @audio.type_uri = 'bar'
    assert_equal @audio.uri, 'foo'
    assert_equal @audio.type_uri, 'bar'
  end

  def test_show
    assert_equal @audio.show, 'foo'
  end

end
