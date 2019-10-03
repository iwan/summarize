module Summarize
  
  class FactHCell < HCell

    def initialize(row, col, content)
      super(row, col, content)
    end

    # fact label?
    def fact_header?
      true
    end
  end

end