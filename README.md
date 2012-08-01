diarize-jruby
=============

A JRuby wrapper around the LIUM Speaker Diarization tools. 
See http://lium3.univ-lemans.fr/diarization/doku.php/welcome

Example use
-----------

  $ jruby -S gem install rdf-mapper
  $ jruby -S gem install diarize-jruby
  $ jruby -S irb
  > require 'diarize'
  > audio = Diarize::Audio.new URI('http://bbcdbmsw023.national.core.bbc.co.uk/MediaLibrary/Live/2011/05/X0909378.wav')
  > audio.analyze!
  > audio.segments
  > audio.speakers
  > speakers = audio.speakers
  > speakers[5].gender
  > speakers[5].model.mean\_log\_likelihood
  > speakers[5].model.components.size
  > audio.segments\_by\_speaker(speakers[5])[0].play
  > audio.segments\_by\_speaker(speakers[5])[1].play
  > ...
  > speakers |= other\_speakers
  > Diarize::Speaker.match(speakers)
