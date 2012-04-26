module Diarize

  class Speaker

    # Some possible matching heuristics if using GDMAP:
    # - speaker mean_log_likelihood needs to be more than -33 to be considered for match
    # - distance between two speakers need to be less than distance between speaker and universal model + detection threshold to be considered

    @@log_likelihood_threshold = -33
    @@divergence_threshold = 0.2

    @@speakers = {}

    attr_accessor :model
    attr_reader :id, :gender

    def initialize(id = nil, gender = nil)
      unless id and gender
        # A generic speaker, associated with a universal background model
        @model = read_gmm(File.join(File.expand_path(File.dirname(__FILE__)), 'ubm.gmm'))
      else
        @id = id
        @gender = gender
      end
    end

    def self.find_or_create(id, gender)
      return @@speakers[id] if @@speakers[id]
      @@speakers[id] = Speaker.new(id, gender)
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

    protected

    def read_gmm(filename)
      gmmlist = java.util.ArrayList.new
      input = fr.lium.spkDiarization.lib.IOFile.new(filename, 'rb')
      input.open
      fr.lium.spkDiarization.libModel.ModelIO.readerGMMContainer(input, gmmlist)
      input.close
      gmmlist.to_a.first
    end


  end

end
