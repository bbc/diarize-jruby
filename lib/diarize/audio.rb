require 'tempfile'
require File.join(File.expand_path(File.dirname(__FILE__)), 'lium')
require File.join(File.expand_path(File.dirname(__FILE__)), 'segmentation')
require File.join(File.expand_path(File.dirname(__FILE__)), 'speaker')

module Diarize

  class Audio

    attr_reader :path, :file

    def initialize(path)
      @path = path
      @file = File.new path
    end

    def segments
      return @segmentation if @segmentation
      seg_file = Tempfile.new(['diarize-jruby', '.seg'])
      parameter = fr.lium.spkDiarization.parameter.Parameter.new
      parameter.show = File.expand_path(@path).split('/')[-1].split('.')[0]
      # 12 MFCC + Energy
      # 1: static coefficients are present in the file
      # 1: energy coefficient is present in the file
      # 0: delta coefficients are not present in the file
      # 0: delta energy coefficient is not present in the file
      # 0: delta delta coefficients are not present in the file
      # 0: delta delta energy coefficient is not present in the file
      # 13: total size of a feature vector in the mfcc file
      # 0:0:0: no feature normalization
      parameter.parameterInputFeature.setFeaturesDescription('audio2sphinx,1:1:0:0:0:0,13,0:0:0:0')
      parameter.parameterDiarization.cEClustering = true
      parameter.parameterInputFeature.setFeatureMask(@path)
      parameter.parameterSegmentationOutputFile.setMask(seg_file.path)
      diarization = fr.lium.spkDiarization.system.Diarization.new
      diarization.ester2Version(parameter)
      @segmentation = Segmentation.from_seg_file(self, seg_file.path)
    end

    def speakers
      return @speakers if @speakers
      @speakers = segments.map { |segment| segment.speaker }.uniq
    end

  end

end
