module Diarize

  class Speaker

    @@speakers = {}

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def self.find_or_create(id)
      return @@speakers[id] if @@speakers[id]
      @@speakers[id] = Speaker.new id
    end

  end

end
