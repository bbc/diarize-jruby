require 'rubygems'
require 'rdf_mapper'

module Diarize

  class Speaker

    # Some possible matching heuristics if using GDMAP:
    # - speaker mean_log_likelihood needs to be more than -33 to be considered for match
    # - distance between two speakers need to be less than distance between speaker and universal model + detection threshold to be considered

    @@log_likelihood_threshold = -33
    @@divergence_threshold = 0.2

    @@speakers = {}

    attr_accessor :model
    attr_reader :gender

    def initialize(uri = nil, gender = nil)
      unless uri and gender
        # A generic speaker, associated with a universal background model
        @model = read_gmm(File.join(File.expand_path(File.dirname(__FILE__)), 'ubm.gmm'))
      else
        @uri = uri
        @gender = gender
      end
    end

    def self.find_or_create(uri, gender)
      return @@speakers[uri] if @@speakers[uri]
      @@speakers[uri] = Speaker.new(uri, gender)
    end

    def self.divergence(speaker1, speaker2)
      # TODO bundle in mean_log_likelihood to weight down unlikely models? 
      return unless speaker1.model and speaker2.model
      # MAP Gaussian divergence
      fr.lium.spkDiarization.libModel.Distance.GDMAP(speaker1.model, speaker2.model)
      # Also consider Euclidian distance between GMMs and Mahalanobis distance (see 1 and 11 in Helen2010) ?
      # Also consider using Distance.getScore or other functions in the Distance class
      # Consider distance to generic model
    end

    def self.match(speakers)
      speakers = speakers.select { |s| s.model.mean_log_likelihood > @@log_likelihood_threshold }
      speakers.combination(2).select { |s1, s2| Speaker.divergence(s1, s2) < Speaker.divergence(s1, Speaker.new) - @@divergence_threshold }
    end

    include RdfMapper

    def namespaces
      super.merge 'ws' => 'http://wsarchive.prototype0.net/ontology/'
    end

    def uri
      @uri
    end

    def type_uri
      'ws:Speaker'
    end

    def rdf_mapping
      { 'ws:gender' => gender }
    end 

    protected

    def read_gmm(filename)
      gmmlist = java.util.ArrayList.new
      input = fr.lium.spkDiarization.lib.IOFile.new(filename, 'rb')
      input.open
      fr.lium.spkDiarization.libModel.ModelIO.readerGMMContainer(input, gmmlist)
      input.close
      gmmlist.to_a.first
    end

    def write_gmm(filename, model)
      gmmlist = java.util.ArrayList.new
      gmmlist << model
      output = fr.lium.spkDiarization.lib.IOFile.new(filename, 'wb')
      output.open
      fr.lium.spkDiarization.libModel.ModelIO.writerGMMContainer(output, gmmlist)
      output.close
    end

  end

end
