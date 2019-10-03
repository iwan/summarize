module Summarize
  
  class Table
    include Summarize::Spreadsheet
    attr_reader :rows, :columns, :facts, :sheet

    def initialize(ar_relation, options={})
      @ar_relation = ar_relation
      @rows        = Hash.new
      @columns     = Hash.new
      @facts       = Hash.new
      @col_counts  = Hash.new
      @row_counts  = Hash.new
      @sheet       = Hash.new
      @orientation = Hash.new

      @options = options.reverse_merge!(nan: :to_nil)
    end

    def summarize(name, o)
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
      # @rows[name] is a Rows object and keep an array of Dimension objects
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
          @sheet[name].append HColHCell.new(r, c, dim.label)
        end

        # "C", "D"
        @rows[name].each.with_index do |dim, c|
          r = @columns[name].size - (hor ? 0 : 1)
          r = 0 if r<0
          @sheet[name].append HRowHCell.new(r, c, dim.label)
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
            @sheet[name].append FactHCell.new(r_offset+i*fact_size+k, r_arr.size, fact.label)
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
            @sheet[name].append FactHCell.new(c_arr.size, c_offset+i*fact_size+k, fact.label)
          end
        end
      end




      # fact values
      rows.each_with_index do |r_arr, i| # r_arr is an array of Dimension obj
        # puts "--> #{r_arr.inspect}"
        last_and_summary_row = false
        r_size = r_arr.size
        r_conditions = {}
        r_arr.each do |r_el|
          r_conditions[r_el.parent.name] = r_el.value if !r_el.is_summary
          last_and_summary_row = last_and_summary_row || (r_el.last && r_el.is_summary)
        end

        columns.each_with_index do |c_arr, j| # r_arr is an array of Dimension obj
        # puts "---> #{c_arr.inspect}"
          last_and_summary_col = false
          c_size = c_arr.size
          c_conditions = {}
          c_arr.each do |c_el|
            c_conditions[c_el.parent.name] = c_el.value if !c_el.is_summary
            last_and_summary_col = last_and_summary_col || (c_el.last && c_el.is_summary)
         end

          conditions = c_conditions.merge r_conditions
          res = @ar_relation.where(conditions)

          @facts[name].each.with_index do |fact, k|
            r = c_size + (hor ? 1 + i : @facts[name].size * i + k)
            c = r_size + (!hor ? 1 + j : @facts[name].size * j + k)
            c = c+1 if r_size.zero? && hor
            r = r+1 if c_size.zero? && !hor
            result = eval(fact.eval_string) # the relation must be 'res' !!!
            if @options[:nan]==:to_nil
              result = result.nan? ? nil : result
            end
            cell = Cell.new(r, c, result, fact.style)
            cell.last_and_summary = last_and_summary_row || last_and_summary_col
            @sheet[name].append cell
          end
        end
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
      last_key = hash.keys.last
      hash.each_pair do |name, v|
        @rows[tname]    << Dimension.new(name, v[:set], summary: (v[:summary] || false), label: v[:label] || name, last: name==last_key)
      end
    end

    def read_columns(tname, hash)
      @columns[tname] = Columns.new
      last_key = hash.keys.last
      hash.each_pair do |name, v|
        @columns[tname] << Dimension.new(name, v[:set], summary: (v[:summary] || false), label: v[:label] || name, last: name==last_key)
      end
    end

    def read_cells(tname, hash)
      @facts[tname] = Facts.new
      @orientation[tname] = Orientation.new hash.delete(:orientation)

      hash.each_pair do |name, v|
        fact = Fact.new(name, v[:label] || name)
        fact.eval_string = v[:calc]
        fact.style       = v[:style]
        @facts[tname] << fact
      end
    end
  end
end