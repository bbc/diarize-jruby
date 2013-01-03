Gem::Specification.new do |s|
  s.name = "diarize-jruby"
  s.version = "0.1.0"
  s.date = "2013-01-03"
  s.summary = "Speaker Diarization for JRuby"
  s.email = "yves.raimond@bbc.co.uk"
  s.homepage = "http://github.com/bbcrd/diarize"
  s.description = "A library for JRuby wrapping the LIUM Speaker Diarization and including a few extra tools"
  s.has_rdoc = false
  s.authors = ['Yves Raimond']
  s.files = ["README.md", "diarize-jruby.gemspec", "lib", "lib/diarize.rb", "lib/diarize/LIUM_SpkDiarization-4.2.jar", "lib/diarize/lium.rb", "lib/diarize/audio.rb", "lib/diarize/audio_player.rb", "lib/diarize/segmentation.rb", "lib/diarize/segment.rb", "lib/diarize/ubm.gmm", "lib/diarize/speaker.rb", "lib/diarize/super_vector.rb"]
end

