module Diarize

  class Segmentation

    attr_reader :segmentation

    def initialize()
        @segmentation = []
    end

    def self.from_seg_file(seg_file)
      segmentation = Segmentation.new
      File.open(seg_file).lines.each do |line|
        next if line.start_with? ';;'
        parts = line.split(' ')
        start = parts[2].to_i / 100.0
        duration = parts[3].to_i / 100.0
        gender = parts[4]
        speaker_id = parts[7]
        segmentation.add_segment(start, duration, gender, speaker_id)
      end
      segmentation
    end

    def add_segment(start, duration, gender, speaker_id)
      @segmentation << [ start, duration, gender, speaker_id ]
    end

  end

end
