require 'helper'

class TestSuperVector < Test::Unit::TestCase

  def test_generate_from_model
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal 512 * 24, sv.dim
    # Checking all elements are OK
    model.nb_of_components.times do |i|
      gaussian = model.components.get(i)
      gaussian.dim.times do |j|
        assert_equal gaussian.mean(j), sv.vector[i * gaussian.dim + j]
      end
    end
  end

  def test_hash
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal sv.vector.hash, sv.hash
  end

end
