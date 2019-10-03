require 'axlsx'

module Summarize

  def axlsx(workbook, tablename, sheetname, options={})
    axlsxxx = Axlsxxx.new(workbook, sheetname, self.sheet[tablename], options)
  end



  class Axlsxxx
    def initialize(workbook, sheetname, cells, options)
      @wb = workbook
      @cells = cells
      @styles = options[:styles]
      @sheet = @wb.add_worksheet(name: sheetname)
      fill_cells
    end
    
    # al momento non in uso
    def read_styles(options_styles)
      @styles = {}
      if options_styles
        @wb.styles do |wb_style|
          options_styles.each_pair do |name, s|
            styles[name.to_sym] = wb_style.add_style s
          end
        end
      end
      workbook.add_worksheet(name: sheetname) do |sheet|
        fill_cells(sheet, self.sheet[tablename], 0, styles)
      end
    end



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


    def fill_cells(row_offset=0)
      
      max_row = @cells.map{|c| c.row}.max # 
      (0..max_row).each do |row_index| # [0, 1, 2, ..., max_row]
        row_cells = @cells.find_all{|c| c.row==row_index}
        max_col = row_cells.map{|c| c.col}.max

        row = Array.new(max_col+1)
        styles_row = Array.new(max_col+1)

        (0..max_col).each do |col_index|
          cell = row_cells.find{|c| c.col==col_index}
          if cell
            row[col_index] = cell.content

            if cell.header?
              if cell.h_span>1
                s = "#{cell_name(row_index+row_offset+1, col_index+1)}:#{cell_name(row_index+row_offset+1, col_index+cell.h_span)}"
                @sheet.merge_cells(s)
              elsif cell.v_span>1
                s = "#{cell_name(row_index+row_offset+1, col_index+1)}:#{cell_name(row_index+row_offset+cell.v_span, col_index+1)}"
                @sheet.merge_cells(s)
              end
            end

            # styles
            cell_style = {}

            if cell.header?
              if cell.fact_header?
                cell_style = @styles[:fact_header]

              elsif cell.column_header?
                if cell.header_header?
                  cell_style = @styles[:h_col_header]
                else
                  cell_style = @styles[:col_header]
                end
              elsif cell.row_header?
                if cell.header_header?
                  cell_style = @styles[:h_row_header]
                else
                  cell_style = @styles[:row_header]
                end  
              end
            else
              cell_style = @styles[:cell]
              if cell.style
                cell_style = cell_style.dup.merge(@styles[cell.style]) if @styles[cell.style]
                cell_style = cell_style.merge(@styles[:summary_cell]) if cell.last_and_summary
                # if row[col_index]
                #   puts "row[col_index]:      #{row[col_index].inspect}"
                #   puts "cell.style:          #{cell.style.inspect}"
                #   puts "cell_style:          #{cell_style.inspect}"
                #   puts "@styles[cell.style]: #{@styles[cell.style].inspect}"
                #   exit
                # end
              end
            end
            styles_row[col_index] = @wb.styles.add_style(cell_style)
          end
        end
        @sheet.add_row row, style: styles_row
      end
    end
    
  end
end