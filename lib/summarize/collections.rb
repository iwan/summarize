require 'forwardable'

module Summarize
  
  class Collections
    extend Forwardable
    def_delegators :@arr, :size, :<<, :map, :each, :[]
    attr_reader :arr

    def initialize
      @arr = [] # array of Fact or Dimension objects
    end
  end

end