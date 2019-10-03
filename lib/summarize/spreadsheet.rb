require 'axlsx'

module Summarize
  module Spreadsheet
    def spreadsheet
      Spreadsheet.new(self) # Table is the caller (self)
    end


    class Spreadsheet
      def initialize(table)
        @table = table
      end
      
      def to_book(hash)
        p = Axlsx::Package.new
        book = p.workbook

        hash.each_pair do |sheetname, name|
          book.add_worksheet(name: sheetname)do |wsheet|
            # format = ::Spreadsheet::Format.new :color=> :blue, :pattern_fg_color => :xls_color_13, :pattern => 1
            # colors: see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/datatypes.rb
            fill_cells(wsheet, name)
          end
        end
        book
      end
      alias to_spreadbook to_book
      alias to_workbook to_book

      # def to_sheet(sheetname, tables)
      #   tables = [tables] if !tables.is_a? Array
      #   wsheet = ::Spreadsheet::Worksheet.new(name: sheetname)
      #   row_offset = 0
      #   tables.each do |name|
      #     fill_cells(wsheet, name, row_offset)
      #     row_offset = wsheet.row_count + 3
      #   end
      #   wsheet
      # end
      # alias to_spreadsheet to_sheet
      # alias to_worksheet to_sheet

      private

      def col_name(col_idx)
        name = ""
        while col_idx>0
          mod     = (col_idx-1)%26
          name    = (65+mod).chr + name
          col_idx = ((col_idx-mod)/26).to_i
         end
        name
      end

      def col_num(col_name)
        col_name.split(//).inject(0) { |n, c| n * 26 + c.upcase.ord - "A".ord + 1 }
      end

      def cell_name(row_idx, col_idx)
        "#{col_name(col_idx)}#{row_idx}"
      end


      def fill_cells(sheet, name, row_offset=0)
        max_row = @table.sheet[name].map{|c| c.row}.max
        (0..max_row).each do |row_index|
          row_cells = @table.sheet[name].find_all{|c| c.row==row_index}
          max_col = row_cells.map{|c| c.row}.max
          row = Array.new(max_col+1)
          (0..max_col).each do |col_index|
            cell = row_cells.find{|c| c.col==col_index}
            if cell
              row[col_index] = cell.content
              if cell.header?
                if cell.h_span>1
                  sheet.merge_cells("#{cell_name(row_index+row_offset+1, col_index+1)}:#{cell_name(row_index+row_offset+1, col_index+cell.h_span)}")
                elsif cell.v_span>1
                  sheet.merge_cells("#{cell_name(row_index+row_offset+1, col_index+1)}:#{cell_name(row_index+row_offset+cell.v_span, col_index+1)}")
                end
              end
            end
          end
          sheet.add_row row
        end
      end

    end
  end
end
