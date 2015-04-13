require 'spreadsheet'

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
        book = ::Spreadsheet::Workbook.new
        hash.each_pair do |sheetname, name|
          wsheet = book.create_worksheet name: sheetname

          # format = ::Spreadsheet::Format.new :color=> :blue, :pattern_fg_color => :xls_color_13, :pattern => 1
          # colors: see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/datatypes.rb
          fill_cells(wsheet, name)


        end
        book
      end
      alias to_spreadbook to_book
      alias to_workbook to_book

      def to_sheet(sheetname, tables)
        wsheet = ::Spreadsheet::Worksheet.new(name: sheetname)
        row_offset = 0
        tables.each do |name|
          fill_cells(wsheet, name, row_offset)
          row_offset = wsheet.row_count + 3
        end
        wsheet
      end
      alias to_spreadsheet to_sheet
      alias to_worksheet to_sheet

      private

      def fill_cells(wsheet, name, row_offset=0)
        puts "------ #{name}"
        @table.sheet[name].each do |cell|
          puts "#{cell.row+row_offset}/#{cell.col}: #{cell.content}" if (cell.row+row_offset)<0 or cell.col<0
          wsheet[cell.row+row_offset, cell.col] = cell.content
          if cell.header?
            if cell.h_span>1
              wsheet.merge_cells(cell.row+row_offset, cell.col, cell.row+row_offset, cell.col+cell.h_span-1)
            elsif cell.v_span>1
              wsheet.merge_cells(cell.row+row_offset, cell.col, cell.row+cell.v_span-1+row_offset, cell.col)    
            end
          end
          # wsheet.row(cell.row).set_format(cell.col, format)
        end
      end
    end


    # def to_spreadsheet(filename, sheetname="Sheet 1")
    #   book = ::Spreadsheet::Workbook.new
    #   wsheet = book.create_worksheet name: sheetname

    #   format = ::Spreadsheet::Format.new :color=> :blue, :pattern_fg_color => :xls_color_13, :pattern => 1
    #   # colors: see https://github.com/zdavatz/spreadsheet/blob/master/lib/spreadsheet/datatypes.rb

    #   sheet.each do |cell|
    #     wsheet[cell.row, cell.col] = cell.content
    #     if cell.header?
    #       if cell.h_span>1
    #         wsheet.merge_cells(cell.row, cell.col, cell.row, cell.col+cell.h_span-1)
    #       elsif cell.v_span>1
    #         wsheet.merge_cells(cell.row, cell.col, cell.row+cell.v_span-1, cell.col)    
    #       end
    #     end
    #     # wsheet.row(cell.row).set_format(cell.col, format)
    #   end
    #   book.write filename
    # end

  end
end
