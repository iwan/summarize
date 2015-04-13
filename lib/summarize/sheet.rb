require 'forwardable'

module Summarize
  
  class Sheet
    extend Forwardable
    def_delegators :@cells, :size, :<<, :map, :each, :[], :find_all
    attr_reader :cells
    def initialize
      @cells = []
    end
    
    def append(cell)
      @cells << cell
      if cell.is_a? ColHCell
        i = cell.col - 1
        prev_side_cell = cell
        count = 1
        while i>=0
          side_cell = @cells.detect{|c| c.row==cell.row && c.col==i}
          if side_cell && side_cell.content==cell.content
            count += 1
            # side_cell.h_span = count
            prev_side_cell = side_cell
          else
            prev_side_cell.h_span = count
            i=0
          end
          i -= 1
        end
      end

      if cell.is_a? RowHCell
        i = cell.row - 1
        prev_side_cell = cell
        count = 1
        while i>=0
          side_cell = @cells.detect{|c| c.row==i && c.col==cell.col}
          if side_cell && side_cell.content==cell.content
            count += 1
            prev_side_cell = side_cell

            # side_cell.v_span = count
          else
            prev_side_cell.v_span = count
            i=0
          end
          i -= 1
        end
      end

    end
  end

end