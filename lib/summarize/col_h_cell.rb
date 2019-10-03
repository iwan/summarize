module Summarize
  
  # Column header cell
  class ColHCell < HCell

    def header_header?
      false
    end

    def column_header?
      true
    end
    
    def row_header?
      false
    end
  end

end