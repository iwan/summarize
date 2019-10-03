module Summarize

  class Cell
    attr_accessor :row, :col, :content, :style, :last_and_summary

    def initialize(row, col, content, style=nil)
      @row     = row
      @col     = col
      @content = content
      @style   = style
    end

    def header?
      false
    end
  end
  
end