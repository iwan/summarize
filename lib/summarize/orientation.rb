module Summarize
  
  class Orientation
    HORIZONTAL = "horizontal"
    VERTICAL   = "vertical"


    def initialize(name)
      name = HORIZONTAL if name.nil?
      name = name.to_s.downcase
      validate name
      @name = name
    end

    def horizontal?
      @name==HORIZONTAL
    end

    def vertical?
      @name==VERTICAL
    end

    private

    def validate(name)
      raise "Invalid orientation" if ![HORIZONTAL, VERTICAL].include?(name)
    end
  end
  
end