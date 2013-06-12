diarize-jruby
=============

This library provides an easy-to-use toolkit for speaker
segmentation (diarization) and identification from audio.

This library is being used within the BBC R&D World Service archive prototype.
See http://worldservice.prototyping.bbc.co.uk/programmes/X0403940 for
an example.

Speaker diarization
-------------------

This library gives acccess to the algorithm developed by the LIUM 
for the ESTER 2 evaluation campaign and described in [Meigner2010].

It wraps a binary JAR file compiled from 
http://lium3.univ-lemans.fr/diarization/doku.php/welcome.


Speaker identification
----------------------

This library also implements an algorithm for speaker identification
based on the comparison of normalised speaker models, which can be 
accessed through the Speaker#match method.

This algorithm builds on top of the LIUM toolkit and uses the following techniques:

 * "M-Norm" normalisation of speaker models [Ben2003]
 * The symmetric Kullback-Leibler divergence approximation described in [Do2003]
 * The detection score specified in [Ben2005] 

It also includes support for speaker supervectors [Campbell2006], which can be used
in combination with our ruby-lsh library for fast speaker identification.

Example use
-----------

This gem has been tested with jruby 1.7.2 onwards.

  $ jruby -S gem install diarize-jruby
  $ jruby -S irb
  > require 'diarize'
  > audio = Diarize::Audio.new URI('http://example.com/file.wav')
  > audio.analyze!
  > audio.segments
  > audio.speakers
  > speakers = audio.speakers
  > speakers.first.gender
  > speakers.first.model.mean\_log\_likelihood
  > speakers.first.model.components.size
  > audio.segments\_by\_speaker(speakers.first)[0].play
  > audio.segments\_by\_speaker(speakers.first)[1].play
  > ...
  > speakers |= other\_speakers
  > Diarize::Speaker.match(speakers)


References
----------

[Meigner2010] S. Meignier and T. Merlin, "LIUM SpkDiarization: An Open Source Toolkit For Diarization" in Proc. CMU SPUD Workshop, March 2010, Dallas (Texas, USA)
[Ben2003] M. Ben and F. Bimbot, "D-MAP: A Distance-Normalized Map Estimation of SPeaker Models for Automatic Speaker Verification", Proceedings of ICASSP, 2003
[Do2003] M. N. Do, "Fast Approximation of Kullback-Leibler Distance for Dependence Trees and Hidden Markov Models", IEEE Signal Processing Letters, April 2003
[Ben2005] M. Ben and G. Gravier and F. Bimbot. "A model space framework for efficient speaker detection", Proceedings of INTERSPEECH, 2005
[Campbell2006] W. M. Campbell, D. E. Sturim and D. A. Reynolds, "Support vector machines using GMM supervectors for speaker verification", IEEE Signal Processing Letters, 2006, 13, 308-311

Licensing terms and authorship
------------------------------

See 'COPYING' and 'AUTHORS' files.
