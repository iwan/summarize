%w(
    version
    sheet
    cell
    h_cell
    col_h_cell
    row_h_cell
    element
    fact
    collections
    facts
    dimensions
    rows
    columns
    dimension
    spreadsheet
    orientation
    table
  ).each { |file| require File.join(File.dirname(__FILE__), 'summarize', file) }


module Summarize
  # Your code goes here...
end