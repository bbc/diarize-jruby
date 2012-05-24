require 'helper'
require 'mocha'

class TestAudio < Test::Unit::TestCase

  def test_initialize_file_uri
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.uri, audio_uri
    assert_equal audio.path, File.join(File.dirname(__FILE__), 'data', 'foo.wav')
  end

  def test_initialize_http_uri
    Kernel.expects(:system).with("wget http://example.com/test.wav -O /tmp/http%3A%2F%2Fexample.com%2Ftest.wav").returns(true)
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
    audio_uri = URI('http://example.com/test.wav')
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).with('/tmp/http%3A%2F%2Fexample.com%2Ftest.wav')
    audio.clean!
  end

end
