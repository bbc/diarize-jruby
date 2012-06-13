require File.join(File.expand_path(File.dirname(__FILE__)), 'segment')

module Diarize

  class Segmentation

    def self.from_seg_file(audio, seg_file)
      segmentation = []
      File.open(seg_file).lines.each do |line|
        next if line.start_with? ';;'
        parts = line.split(' ')
        start = parts[2].to_i / 100.0
        duration = parts[3].to_i / 100.0
        gender = parts[4]
        bandwidth = parts[6]
        speaker_id = parts[7]
        segmentation << Segment.new(audio, start, duration, gender, bandwidth, speaker_id)
      end
      segmentation
    end

    def self.from_clusters(audio, clusters)
      segmentation = []
      clusters.each do |speaker_id|
        cluster = clusters.get_cluster(speaker_id)
        gender = cluster.gender
        bandwidth = cluster.bandwidth
        cluster.each do |segment|
          start = segment.start_in_second
          duration = segment.length_in_second
          segmentation << Segment.new(audio, start, duration, gender, bandwidth, speaker_id)
        end
      end
      segmentation
    end

  end

end
