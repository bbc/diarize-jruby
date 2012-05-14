require 'rubygems'
require 'rdf_mapper'

module Diarize

  class Speaker

    # Some possible matching heuristics if using GDMAP:
    # - speaker mean_log_likelihood needs to be more than -33 to be considered for match
    # - distance between two speakers need to be less than distance between speaker and universal model + detection threshold to be considered

    @@log_likelihood_threshold = -33

    @@speakers = {}

    attr_accessor :model, :model_uri
    attr_reader :gender

    def initialize(uri = nil, gender = nil, model_file = nil)
      unless model_file
        # A generic speaker, associated with a universal background model
        @model = Speaker.load_model(File.join(File.expand_path(File.dirname(__FILE__)), 'ubm.gmm'))
      else
        @model = Speaker.load_model(model_file)
      end
      @uri = uri
      @gender = gender
    end

    def mean_log_likelihood
      @mean_log_likelihood ? @mean_log_likelihood : model.mean_log_likelihood # Will be NaN if model was loaded from somewhere
    end

    def mean_log_likelihood=(mll)
      @mean_log_likelihood = mll
    end

    def save_model(filename)
      write_gmm(filename, @model)
    end

    def self.load_model(filename)
      read_gmm(filename)
    end

    def self.find_or_create(uri, gender)
      return @@speakers[uri] if @@speakers[uri]
      @@speakers[uri] = Speaker.new(uri, gender)
    end

    def self.divergence(speaker1, speaker2)
      # TODO bundle in mean_log_likelihood to weight down unlikely models? 
      return unless speaker1.model and speaker2.model
      # MAP Gaussian divergence
      # See "A model space framework for efficient speaker detection", Interspeech'05
      fr.lium.spkDiarization.libModel.Distance.GDMAP(speaker1.model, speaker2.model)
    end

    def self.match(speakers)
      speakers = speakers.select { |s| s.mean_log_likelihood > @@log_likelihood_threshold }
      speakers.combination(2).select { |s1, s2| s1.same_speaker_as(s2) }
    end

    def same_speaker_as(other)
      # Detection score defined in Ben2005
      # detection_score = Speaker.divergence(other, Speaker.new) - Speaker.divergence(other, self)
      Speaker.divergence(self, other) < [ Speaker.divergence(self, Speaker.new), Speaker.divergence(other, Speaker.new) ].min
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
      { 'ws:gender' => gender, 'ws:model' => model_uri, 'ws:mean_log_likelihood' => model.mean_log_likelihood }
    end 

    protected

    def self.read_gmm(filename)
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
