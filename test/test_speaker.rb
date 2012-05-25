require 'helper'
require 'tempfile'

class TestSpeaker < Test::Unit::TestCase

  def test_find_or_create_gives_same_object_if_called_with_same_id
    speaker1 = Diarize::Speaker.find_or_create('S0', 'M')
    speaker2 = Diarize::Speaker.find_or_create('S0', 'M')
    assert_equal speaker2.object_id, speaker1.object_id
  end

  def test_initialize
    speaker = Diarize::Speaker.new('uri', 'm')
    assert_equal speaker.uri, 'uri'
    assert_equal speaker.gender, 'm'
  end

  def test_initialize_default
    speaker = Diarize::Speaker.new
    assert_equal speaker.gender, nil
    assert_equal speaker.uri, nil
    assert_equal speaker.model.name, 'MSMTFSFT' # UBM GMM
  end

  def test_initialize_with_model
    model_file = File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm')
    speaker = Diarize::Speaker.new(nil, nil, model_file)
    assert_equal speaker.model.name, 'S0'
  end

  def test_mean_log_likelihood
    speaker = Diarize::Speaker.new
    assert speaker.mean_log_likelihood.nan?
    speaker.mean_log_likelihood = 1
    assert_equal speaker.mean_log_likelihood, 1
  end

  def test_save_and_load_model
    speaker = Diarize::Speaker.new
    tmp = Tempfile.new(['diarize-test', '.gmm'])
    speaker.save_model(tmp.path)
    model = Diarize::Speaker.load_model(tmp.path)
    assert_equal speaker.model.components[0].mean(0), model.components[0].mean(0)
    File.delete(tmp.path)
  end

  def test_divergence_returns_nil_if_one_model_is_empty
    speaker1 = Diarize::Speaker.new
    speaker2 = Diarize::Speaker.new
    speaker2.model = nil
    assert_equal Diarize::Speaker.divergence(speaker1, speaker2), nil
    assert_equal Diarize::Speaker.divergence(speaker2, speaker1), nil
  end

end
