require File.join(File.expand_path(File.dirname(__FILE__)), 'audio_player')

module Diarize

  class Segment

    attr_accessor :start, :duration, :gender, :id

    def initialize(audio, start, duration, gender, id)
      @audio = audio
      @start = start
      @duration = duration
      @gender = gender
      @id = id
    end

    def play
      player = AudioPlayer.new
      player.play(@audio.file, start, duration)
    end

  end

end
