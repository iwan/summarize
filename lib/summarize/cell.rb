module Summarize

  class Cell
    # attr_reader :attr_names
    attr_accessor :row, :col, :content
    def initialize(row, col, content)
      @row     = row
      @col     = col
      @content = content
    end

    def header?
      false
    end
  end
  
end