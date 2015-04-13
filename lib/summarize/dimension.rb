require 'forwardable'

module Summarize
  
  class Dimension # Row or Column
    attr_reader :name, :label, :elements, :summary
    extend Forwardable
    def_delegators :@elements, :size, :each, :map
    DEFAULT_SUMMARY_LABEL = "Summary"

    # name is the attribute name to query
    def initialize(name, set, options={})
      # options = {summary: false, label: nil}.merge options
      @name = name # attribute name
      @summary = options[:summary] || false # summary label
      @summary = DEFAULT_SUMMARY_LABEL if @summary==true
      @label = options[:label] || name.to_s
      @elements = fill_elements(set) # values
    end

    def labels
      @elements.map(&:label)
    end

    def values
      @elements.map(&:value)
    end

    def fill_elements(set)
      elements = []
      set = Hash[set.map{|e| [e,e]}] if set.is_a? Array
      set.each do |v, l|
        element = Element.new(v, l)
        element.parent = self
        elements << element
      end
      if @summary
        element = Element.new(@summary)
        element.parent = self
        element.is_summary = true
        elements << element
      end
      elements
    end
  end

end