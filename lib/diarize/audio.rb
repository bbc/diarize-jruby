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
      clusters = ester2(parameter)
      @segmentation = Segmentation.from_clusters(self, clusters)
    end

    def speakers
      return @speakers if @speakers
      @speakers = segments.map { |segment| segment.speaker }.uniq
    end

    def segments_by_speaker(speaker)
      segments.select { |segment| segment.speaker == speaker }
    end

    protected

    def ester2(parameter)
      diarization = fr.lium.spkDiarization.system.Diarization.new
      parameterDiarization = parameter.parameterDiarization
      clusterSet = diarization.initialize__method(parameter)
      featureSet = fr.lium.spkDiarization.system.Diarization.load_feature(parameter, clusterSet, parameter.parameterInputFeature.getFeaturesDescString())
      featureSet.setCurrentShow(parameter.show)
      nbFeatures = featureSet.getNumberOfFeatures
      clusterSet.getFirstCluster().firstSegment().setLength(nbFeatures) unless parameter.parameterDiarization.isLoadInputSegmentation
      clustersSegInit = diarization.sanityCheck(clusterSet, featureSet, parameter)
      clustersSeg = diarization.segmentation("GLR", "FULL", clustersSegInit, featureSet, parameter)
      clustersLClust = diarization.clusteringLinear(parameterDiarization.getThreshold("l"), clustersSeg, featureSet, parameter)
      clustersHClust = diarization.clustering(parameterDiarization.getThreshold("h"), clustersLClust, featureSet, parameter)
      clustersDClust = diarization.decode(8, parameterDiarization.getThreshold("d"), clustersHClust, featureSet, parameter)
      clustersSplitClust = diarization.speech("10,10,50", clusterSet, clustersSegInit, clustersDClust, featureSet, parameter)
      clusters = diarization.gender(clusterSet, clustersSplitClust, featureSet, parameter)
      if parameter.parameterDiarization.isCEClustering
        # If true, the program computes the NCLR/CE clustering at the end. 
        # The diarization error rate is minimized. 
        # If this option is not set, the program stops right after the detection of the gender 
        # and the resulting segmentation is sufficient for a transcription system.
        clusters = diarization.speakerClustering(parameterDiarization.getThreshold("c"), "ce", clusterSet, clusters, featureSet, parameter)
      end
      clusters
    end

  end

end
