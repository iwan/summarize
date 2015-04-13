module Summarize
  
  class HCell < Cell
    attr_accessor :h_span, :v_span

    def initialize(row, col, content, options={})
      super(row, col, content)
      # span
      @h_span = options[:h_span] || 1
      @v_span = options[:v_span] || 1
    end

    def header?
      true
    end
  end

end