require File.join(File.expand_path(File.dirname(__FILE__)), 'audio_player')

module Diarize

  class Segment

    attr_reader :start, :duration, :gender, :bandwidth, :speaker

    def initialize(audio, start, duration, gender, bandwidth, speaker_id)
      @audio = audio
      @start = start
      @duration = duration
      @bandwidth = bandwidth
      @speaker = Speaker.find_or_create(speaker_id + '_' + audio.path, gender)
    end

    def play
      player = AudioPlayer.new
      player.play(@audio.file, start, duration)
    end

  end

end
