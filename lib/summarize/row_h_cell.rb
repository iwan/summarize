module Summarize
  
  # Column header cell
  class RowHCell < HCell

    def column_header?
      false
    end
    def row_header?
      true
    end
  end

end