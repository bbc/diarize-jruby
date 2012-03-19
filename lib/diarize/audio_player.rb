require 'java'

class Diarize

  class AudioPlayer

    def play(file, start=0.0, duration=10.0)
      java_file = java.io.File.new(file.path)
      stream = javax.sound.sampled.AudioSystem.getAudioInputStream(java_file)
      clip = javax.sound.sampled.AudioSystem.clip
      clip.open(stream)
      clip.setMicrosecondPosition(start * 1000000)
      clip.start
      begin
        sleep(duration)
      rescue Exception
        $stderr.puts 'Stopping playback'
      end
      clip.stop
      clip.close
      stream.close
    end

  end

end
