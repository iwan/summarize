require_relative 'config/required'
require_relative '../lib/summarize'
include Summarize

scopes    = UnpaidRatio.dist(:scope)
operators = UnpaidRatio.dist(:operator)
areas     = UnpaidRatio.dist(:area)

puts "scopes size: #{scopes.size}"
puts "operators size: #{operators.size}"
puts "uses_for_8_9 size: #{uses_for_8_9.size}"
puts "areas size: #{areas.size}"

puts "scopes      : #{scopes.inspect}"
puts "operators   : #{operators.inspect}"
puts "uses_for_8_9: #{uses_for_8_9.inspect}"  # uses_for_8_9: ["clienti_domestici", "condominio_uso_dom"]
puts "areas       : #{areas.inspect}"

uses = { clienti_domestici: "Clienti domestici" , condominio_uso_dom: "Condominio uso domestico" }
areas = { aree_urbane: "Aree urbane", aree_non_urbane: "Aree non urbane", aree_totali: "Aree totali" }

options = {
  rows: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }, 
    operator: {
      label: "Operatori",
      set: operators, 
      summary: "Sommario operatori"
    }
  }, 
  columns: {
    use: {
      label: "Uso",
      set: uses, 
      summary: "Totale tutela" # metti anche label
    }, 
    area: {
      label: "Area",
      set: areas
    }
  },
  cells: {
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    },
    collected: {
      calc: "res.sum(:collected)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Incasso"
    },
    ratio: {
      calc: "1 - (res.sum(:collected) / res.sum(:revenue))", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Tasso di mancato incasso"
    }
  }
}

ar_relation = UnpaidRatio.where(market: UR_CAPTIVE)
s = Summary.new(ar_relation, options)
s.to_spreadsheet "excel-file.xls", "Pippo"



