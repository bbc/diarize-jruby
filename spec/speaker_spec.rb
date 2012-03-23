require 'spec_helper'
require 'tempfile'

describe Diarize::Speaker, '#find_or_create' do

  it "returns the same object if called with same id" do
    speaker1 = Diarize::Speaker.find_or_create('S0', 'M')
    speaker2 = Diarize::Speaker.find_or_create('S0', 'M')
    speaker2.should be(speaker1)
  end

end
