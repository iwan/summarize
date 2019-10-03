module Summarize
  
  class Element
    attr_reader :name, :label, :parent
    attr_accessor :parent, :is_summary, :last

    def initialize(name, label=nil)
      @name   = name
      @label  = label || name.to_s
      @is_summary = false
    end

    def value
      @name
    end
  end

end