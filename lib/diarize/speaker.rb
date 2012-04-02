module Diarize

  class Speaker

    @@speakers = {}

    attr_accessor :model
    attr_reader :id, :gender

    def initialize(id, gender)
      @id = id
      @gender = gender
    end

    def self.find_or_create(id, gender)
      return @@speakers[id] if @@speakers[id]
      @@speakers[id] = Speaker.new(id, gender)
    end

  end

end
