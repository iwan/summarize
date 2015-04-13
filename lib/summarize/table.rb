module Summarize
  
  class Table
    include Summarize::Spreadsheet
    attr_reader :rows, :columns, :facts, :sheet

    def initialize(ar_relation)
      @ar_relation = ar_relation
      @rows        = Hash.new
      @columns     = Hash.new
      @facts       = Hash.new
      @col_counts  = Hash.new
      @row_counts  = Hash.new
      @sheet       = Hash.new
      @orientation = Hash.new
    end

    def summarize2(name, o)
      o.reverse_merge!(rows: {}, columns: {}, cells: {})
      read_options(name, o)
      @sheet[name] = Sheet.new

      # @rows[tname]    = Rows.new
      # @rows[tname]    << Dimension.new(...)
      # @columns[tname] = Columns.new
      # @columns[tname] << Dimension.new(...)
      # @facts[tname]   = Facts.new
      # @facts[tname]   << Fact.new(...)
      # @orientation[tname] = Orientation.new(...)

      # rows = @rows[name]
      hor = @orientation[name].horizontal?

      rows = []
      @rows[name].map(&:elements).each{|el| rows = combine(rows, el)} # el is a Dimension
      rows = [[]] if rows.empty?
      # rows is an array of array of Element objects (array of combination of Element objs)

      columns = []
      @columns[name].map(&:elements).each{|el| columns = combine(columns, el)} # el is a Dimension
      columns = [[]] if columns.empty?
      # columns is an array of array of Element objects (array of combination of Element objs)


      # Labels on the top left edge
      add_collections_label = true
      if add_collections_label
        # "A", "B"
        @columns[name].each.with_index do |dim, r|
          c = @rows[name].size - (hor ? 1 : 0)
          c = 0 if c<0
          @sheet[name].append HCell.new(r, c, dim.label)
        end

        # "C", "D"
        @rows[name].each.with_index do |dim, c|
          r = @columns[name].size - (hor ? 0 : 1)
          r = 0 if r<0
          @sheet[name].append HCell.new(r, c, dim.label)
        end
      end

      # Dimension 'values'
      # Rows headers
      fact_size = hor ? 1 : @facts[name].size
      r_offset = @columns[name].size + (hor ? 1 : 0)
      r_offset = 1 if r_offset.zero?
      rows.each_with_index do |r_arr, i|
        r_arr.each_with_index do |r_el, ii|
          fact_size.times do |k|
            @sheet[name].append RowHCell.new(r_offset+i*fact_size+k, ii, r_el.label)
          end
        end
        if !hor # write facts labels
          @facts[name].each.with_index do |fact, k|
            @sheet[name].append HCell.new(r_offset+i*fact_size+k, r_arr.size, fact.label)
          end
        end
      end

      # Columns headers
      fact_size = hor ? @facts[name].size : 1
      c_offset = @rows[name].size + (hor ? 0 : 1)
      c_offset = 1 if c_offset.zero?
      columns.each_with_index do |c_arr, i|
        c_arr.each_with_index do |c_el, ii|
          fact_size.times do |k|
            @sheet[name].append ColHCell.new(ii, c_offset+i*fact_size+k, c_el.label)
          end
        end
        if hor # write facts labels
          @facts[name].each.with_index do |fact, k|
            @sheet[name].append HCell.new(c_arr.size, c_offset+i*fact_size+k, fact.label)
          end
        end
      end




      # fact values
      rows.each_with_index do |r_arr, i| # r_arr is an array of Dimension obj
        r_size = r_arr.size
        r_conditions = {}
        r_arr.each_with_index do |r_el, ii|
          r_conditions[r_el.parent.name] = r_el.value if !r_el.is_summary
        end
        
        columns.each_with_index do |c_arr, j| # r_arr is an array of Dimension obj
          c_size = c_arr.size
          c_conditions = {}
          c_arr.each do |c_el|
            c_conditions[c_el.parent.name] = c_el.value if !c_el.is_summary
          end


          conditions = c_conditions.merge r_conditions
          res = @ar_relation.where(conditions)

          @facts[name].each.with_index do |fact, k|
            r = c_size + (hor ? 1 + i : @facts[name].size * i + k)
            c = r_size + (!hor ? 1 + j : @facts[name].size * j + k)
            c = c+1 if r_size.zero? && hor
            r = r+1 if c_size.zero? && !hor
            result = eval(fact.eval_string) # the relation must be 'res' !!!
            @sheet[name].append Cell.new(r, c, result)
          end
        end
      end
    end

    def summarize(name, o)
      o.reverse_merge!(rows: {}, columns: {}, cells: {})
      read_options(name, o)
      count_columns(name)
      count_rows(name)

      @sheet[name] = Sheet.new


      r_count = 0 # rows count
      c_count = -1 # columns count

      puts "-- @col_counts: #{@col_counts[name].inspect}"
      puts "-- @row_counts: #{@row_counts[name].inspect}"

      add_collections_label = true

      horiz = @orientation[name].horizontal?

      exit

      # Bunga.new()
      # HEADER
      # dimension values rows:
      columns_depth = @columns[name].size
      columns_depth_plus = columns_depth + (horiz ? 1 : 0) # take into account the fact cells
      rows_depth    = @rows[name].size
      rows_depth_plus = rows_depth + (horiz ? 0 : 1) # take into account the fact cells

      columns_depth.times do |row|
        puts "-- row: #{row}"
        if add_collections_label
          (rows_depth-1).times{ @sheet[name].append HCell.new(r_count, c_count+=1, nil) } # le celle vuote all'incrocio degli header
          @sheet[name].append HCell.new(r_count, c_count+=1, @columns[name][row].label)
        else
          rows_depth.times{ @sheet[name].append HCell.new(r_count, c_count+=1, nil) } # le celle vuote all'incrocio degli header
        end

        # --- inizio conteggio (metti in un metodo)
        # TODO: aggiungi summaryi
        set_repetitions = 1
        span            = 1 

        (0...row).each do |i|
          set_repetitions *= @col_counts[name][i]
        end

        ((row+1)...columns_depth).each do |i|
          span *= @col_counts[name][i]
        end
        span *= @facts[name].size if @orientation[name].horizontal?
        # --- fine conteggio

        puts "set_repetitions: #{set_repetitions.inspect}"
        puts "span: #{span.inspect}"
        puts "@columns: #{@columns[name].inspect}"

        set_repetitions.times do |i|
          @columns[name][row].each do |dim|
            span.times do |j|
              @sheet[name].append HCell.new(r_count, c_count+=1, dim.label, h_span: (j==0 ? span : 1))
            end
          end
        end
        r_count+=1
        c_count =-1
      end

      # facts label rows:
      if add_collections_label
        @rows[name].each{|dim| @sheet[name].append HCell.new(r_count, c_count+=1, dim.label)}
      else
        rows_depth.times{ @sheet[name].append HCell.new(r_count, c_count+=1, nil) } # le celle vuote all'incrocio degli header
      end
      set_repetitions    = 1
      (0...rows_depth).each do |i|
        set_repetitions *= @col_counts[name][i]
      end
      set_repetitions.times do |i|
        @facts[name].each do |fact|
          @sheet[name].append HCell.new(r_count, c_count+=1, fact.label)
        end
      end
      



      # Fine della scrittura delle intestazioni

      # Inzio scittura delle righe coi dati (e le relative intestazioni di riga)

      rows = []
      @rows[name].map(&:elements).each do |el| # el is a Dimension
        rows = combine(rows, el)
      end
      if rows.empty?
        rows = [[]]
      else
        r_count+=1
        c_count =-1
      end
      
      # rows is an array of array of Element objects

      columns = []
      @columns[name].map(&:elements).each do |el| # el is a Dimension
        columns = combine(columns, el)
      end
      columns = [[]] if columns.empty?


      rows.each_with_index do |r_arr, i| # r_arr is an array of Dimension obj
        r_conditions = {}
        r_arr.each_with_index do |r_el, j|
          # header di riga
          span = 1
          # gestione degli span verticali
          if i==0 || rows[i-1][j].name!=rows[i][j].name # cella diversa da quella immediatamente sopra
            ((i+1)...rows.size).each do |z|
              rows[z][j].name==rows[i][j].name ? span+=1 : break
            end
          end
          
          @sheet[name].append HCell.new(r_count, c_count+=1, r_el.label, v_span: span)
          r_conditions[r_el.parent.name] = r_el.value if !r_el.is_summary
        end
        
        columns.each do |c_arr| # c_arr is an array of Element
          c_conditions = {}
          c_arr.each do |c_el|
            c_conditions[c_el.parent.name] = c_el.value if !c_el.is_summary
          end
          conditions = c_conditions.merge r_conditions
          # puts "conditions: #{conditions.inspect}"
          res = @ar_relation.where(conditions)
          # @facts.each do |fact|
          #   @sheet.append Cell.new(r_count, c_count+=1, res.sum(fact.value))
          # end
          @facts[name].each do |fact|
            r = eval(fact.eval_string)
            @sheet[name].append Cell.new(r_count, c_count+=1, r) # res.send(:sum, )

            # res.sum(:revenue)
            # res.sum(:revenue) / res.sum(:collected)
          end
        end
        r_count+=1
        c_count =-1
      end
    end
    
    private


    def combine(arr, e)
      return e.map{|f| [f]} if arr.empty?
      arr2 = []
      arr.each do |g|
        e.each do |f|
          arr2 << (g+[f])
        end
      end
      arr2
    end

    
    def count_columns(name)
      counts = calculate_counts(name, @columns[name])
      counts << @facts[name].size if @orientation[name].horizontal?
      @col_counts[name] = counts
    end


    def count_rows(name)
      counts = calculate_counts(name, @rows[name])
      counts << @facts[name].size if @orientation[name].vertical?
      @row_counts[name] = counts
    end

    def calculate_counts(name, arr)
      counts = []
      arr.each{|dim| counts << dim.size}
      counts
      # counts => [3, 3, 2]
    end


    def read_options(tname, o)
      read_rows(tname, o[:rows])
      read_columns(tname, o[:columns])
      read_cells(tname, o[:cells])
    end

    def read_rows(tname, hash)
      @rows[tname] = Rows.new
      hash.each do |name, v|
        @rows[tname]    << Dimension.new(name, v[:set], summary: (v[:summary] || false), label: v[:label] || name)
      end
    end

    def read_columns(tname, hash)
      @columns[tname] = Columns.new
      hash.each do |name, v|
        @columns[tname] << Dimension.new(name, v[:set], summary: (v[:summary] || false), label: v[:label] || name)
      end
    end

    def read_cells(tname, hash)
      @facts[tname] = Facts.new
      @orientation[tname] = Orientation.new hash.delete(:orientation)

      hash.each_pair do |name, v|
        fact = Fact.new(name, v[:label] || name)
        fact.eval_string = v[:calc]
        @facts[tname] << fact
      end
    end
  end

end