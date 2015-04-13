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

options1 = {
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

options2 = {
  rows: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }
  }, 
  cells: {
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    }
  }
}

options3 = {
  columns: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }
  }, 
  cells: {
    orientation: "horizontal",
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    },
    collected: {
      calc: "res.sum(:collected)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Incasso"
    },
  }
}

options4 = {
  columns: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }
  }, 
  cells: {
    orientation: "vertical",
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    },
    collected: {
      calc: "res.sum(:collected)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Incasso"
    },
  }
}



options5 = {
  rows: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }
  }, 
  cells: {
    orientation: "horizontal",
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    },
    collected: {
      calc: "res.sum(:collected)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Incasso"
    },
  }
}

options6 = {
  rows: {
    scope: {
      label: "Ambito",
      set: scopes, 
      summary: false
    }
  }, 
  cells: {
    orientation: "vertical",
    revenue: {
      calc: "res.sum(:revenue)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Fatturato"
    },
    collected: {
      calc: "res.sum(:collected)", # se non c'è la chiave :calc, verrà usato il nome (:revenue)
      label: "Incasso"
    },
  }
}


ar_relation = UnpaidRatio.where(market: UR_CAPTIVE)
s = Table.new(ar_relation)
s.summarize2 :table1, options1
s.summarize2 :table2, options2
s.summarize2 :table3, options3
s.summarize2 :table4, options4
s.summarize2 :table5, options5
s.summarize2 :table6, options6


# To workbook
# book = s.spreadsheet.to_book("Foglio 2" => :table2)
# book = s.spreadsheet.to_book("Foglio 1" => :table1, "Foglio 2" => :table2)
book = s.spreadsheet.to_book("Foglio 1" => :table1, "Foglio 2" => :table2, "Foglio 3" => :table3, "Foglio 4" => :table4, "Foglio 5" => :table5, "Foglio 6" => :table6)
book.write "workbook10.xls"

exit

# To worksheet
book = ::Spreadsheet::Workbook.new
book.add_worksheet s.spreadsheet.to_sheet("Foglio 1", [:table1, :table2])
book.write "workbook2.xls"







