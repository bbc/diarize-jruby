require 'spec_helper'
require 'tempfile'

describe Diarize::Segmentation, '#from_seg_file' do

  audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
  audio = Diarize::Audio.new audio_uri

  it "returns empty list from empty LIUM seg file" do
    seg_file = Tempfile.new(['diarize-jruby', '.seg'])
    seg_file.write ''
    seg_file.close
    segmentation = Diarize::Segmentation.from_seg_file(audio, seg_file.path)
    segmentation.size.should eq(0)
  end

  it "returns list of segments from parsed LIUM seg file" do
    seg_file = Tempfile.new(['diarize-jruby', '.seg'])
    seg_file.write <<EOF
foo 1 0 1000 F S U S0
foo 1 1000 10000 M S U S1
EOF
    seg_file.close
    segmentation = Diarize::Segmentation.from_seg_file(audio, seg_file.path)
    segmentation.size.should eq(2)
    segmentation.first.class.should eq(Diarize::Segment)
    segmentation.first.start.should eq(0)
    segmentation.first.duration.should eq(10)
    segmentation.first.speaker.uri.should eq(URI(audio_uri.to_s + '#S0'))
    segmentation.first.speaker.gender.should eq('F')
    segmentation.last.class.should eq(Diarize::Segment)
    segmentation.last.start.should eq(10)
    segmentation.last.duration.should eq(100)
    segmentation.last.speaker.uri.should eq(URI(audio_uri.to_s + '#S1'))
    segmentation.last.speaker.gender.should eq('M')
  end

end
