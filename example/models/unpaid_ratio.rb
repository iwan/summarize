require_relative '../config/connection'
include Connection

class UnpaidRatio < ActiveRecord::Base
  # t.string :operator  -- file di excel
  # t.string :market    -- foglio di excel
  # t.string :area      -- blocchi verticali (area urbana, non urbana ed entrambe)
  # t.string :scope     -- regione italiana o totale
  # t.string :use       -- cl. domestico o condominio
  # t.string :issuing_month  -- periodo di emissione
  # t.string :reference_month -- periodo di riferimento
  # t.decimal :revenue  -- fatturato
  # t.decimal :collected    -- incasso
  validates :operator, :market, :area, :scope, :use, :issuing_month, :reference_month, :revenue, :collected, presence: true

  # Get the list of distinct attributes values
  # Ex: UnpaidRatio.dist(:scope)
  def self.dist(attrib)
    self.select(attrib).distinct.map(&attrib)
  end
end
