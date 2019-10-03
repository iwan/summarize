module Summarize
  
  # Column header cell
  class HColHCell < ColHCell

    def header_header?
      true
    end

    def column_header?
      true
    end
    
    def row_header?
      false
    end
  end

end