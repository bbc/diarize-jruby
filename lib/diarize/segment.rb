require File.join(File.expand_path(File.dirname(__FILE__)), 'audio_player')

module Diarize

  class Segment

    attr_reader :start, :duration, :gender, :speaker

    def initialize(audio, start, duration, gender, speaker_id)
      @audio = audio
      @start = start
      @duration = duration
      @gender = gender
      @speaker = Speaker.find_or_create speaker_id + '_' + audio.path
    end

    def play
      player = AudioPlayer.new
      player.play(@audio.file, start, duration)
    end

  end

end
