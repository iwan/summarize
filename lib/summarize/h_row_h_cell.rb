module Summarize
  
  # Row header cell
  class HRowHCell < RowHCell

    def header_header?
      true
    end

    def column_header?
      false
    end

    def row_header?
      true
    end
  end

end