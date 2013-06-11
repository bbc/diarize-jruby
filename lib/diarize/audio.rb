# diarize-jruby
# 
# Copyright (c) 2013 British Broadcasting Corporation
# 
# Licensed under the GNU Affero General Public License version 3 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.gnu.org/licenses/agpl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), 'lium')
require File.join(File.expand_path(File.dirname(__FILE__)), 'segmentation')
require File.join(File.expand_path(File.dirname(__FILE__)), 'speaker')

require 'rubygems'
require 'to_rdf'
require 'uri'

module Diarize

  class Audio

    attr_reader :path, :file

    def initialize(uri)
      @uri = uri
      if uri.scheme == 'file'
        # Local file
        @path = uri.path
      else
        # Remote file, we get it locally
        @path = '/tmp/' + URI.escape(uri.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        Kernel.system("wget #{uri} -O #{@path}")
      end
      @file = File.new @path
    end

    def analyze!(train_speaker_models = true)
      parameter = fr.lium.spkDiarization.parameter.Parameter.new
      parameter.show = show
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
      parameter.parameterDiarization.cEClustering = true # We use CE clustering by default
      parameter.parameterInputFeature.setFeatureMask(@path)
      @clusters = ester2(parameter)
      @segments = Segmentation.from_clusters(self, @clusters)
      train_speaker_gmms if train_speaker_models
    end

    def clean!
      return if @uri.scheme == 'file' # Don't delete local file if initialised from local URI
      File.delete(@path)
    end

    def segments
      raise Exception.new('You need to run analyze! before being able to access the analysis results') unless @segments
      @segments
    end

    def speakers
      return @speakers if @speakers
      @speakers = segments.map { |segment| segment.speaker }.uniq
    end

    def segments_by_speaker(speaker)
      segments.select { |segment| segment.speaker == speaker }
    end

    def duration_by_speaker(speaker)
      return unless speaker
      segments = segments_by_speaker(speaker)
      duration = 0.0
      segments.each { |segment| duration += segment.duration }
      duration
    end

    def top_speakers
      speakers.sort {|s1, s2| duration_by_speaker(s1) <=> duration_by_speaker(s2)}.reverse
    end

    include ToRdf

    def namespaces
      super.merge 'ws' => 'http://wsarchive.prototype0.net/ontology/', 'mo' => 'http://purl.org/ontology/mo/'
    end

    def uri
      @uri
    end

    def uri=(uri)
      @uri = uri
    end

    def base_uri
      # Remove the fragment if there is one
      base = uri.clone
      base.fragment = nil
      base
    end

    def type_uri
      @type_uri || 'mo:AudioFile'
    end

    def type_uri=(type_uri)
      @type_uri = type_uri
    end

    def rdf_mapping
      { 'ws:segment' => segments }
    end

    def show
      # The LIUM show name will be the file name, without extension or directory
      File.expand_path(@path).split('/')[-1].split('.')[0]
    end

    protected

    def train_speaker_gmms
      segments # Making sure we have pre-computed segments and clusters
      # Would be nice to reuse GMMs computed as part of the segmentation process
      # but not sure how to access them without changing the Java API

      # Start by copying models from the universal background model, one per speaker, using MTrainInit
      parameter = fr.lium.spkDiarization.parameter.Parameter.new
      parameter.parameterInputFeature.setFeaturesDescription('audio2sphinx,1:3:2:0:0:0,13,1:1:300:4')
      parameter.parameterInputFeature.setFeatureMask(@path)
      parameter.parameterInitializationEM.setModelInitMethod('copy')
      parameter.parameterModelSetInputFile.setMask(File.join(File.expand_path(File.dirname(__FILE__)), 'ubm.gmm'))
      features = fr.lium.spkDiarization.lib.MainTools.readFeatureSet(parameter, @clusters)
      init_vect = java.util.ArrayList.new(@clusters.cluster_get_size)
      fr.lium.spkDiarization.programs.MTrainInit.make(features, @clusters, init_vect, parameter)

      # Adapt models to individual speakers detected in the audio, using MTrainMap
      parameter = fr.lium.spkDiarization.parameter.Parameter.new
      parameter.parameterInputFeature.setFeaturesDescription('audio2sphinx,1:3:2:0:0:0,13,1:1:300:4')
      parameter.parameterInputFeature.setFeatureMask(@path)
      parameter.parameterEM.setEMControl('1,5,0.01')
      parameter.parameterVarianceControl.setVarianceControl('0.01,10.0')
      parameter.show = show
      features.setCurrentShow(parameter.show)
      gmm_vect = java.util.ArrayList.new
      fr.lium.spkDiarization.programs.MTrainMAP.make(features, @clusters, init_vect, gmm_vect, parameter)

      # Populating the speakers with their GMMs
      gmm_vect.each_with_index do |speaker_model, i|
        speakers[i].model = speaker_model
      end
    end

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
