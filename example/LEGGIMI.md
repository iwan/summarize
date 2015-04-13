# Esempio d'uso

## Migrazione del db

Crea il database SQLite; un eventuale database preesistente viene cancellato:

```bash
ruby migrations/create_unpaid_ratios.rb
```

## Caricamento di dati fittizzi

```bash
ruby load_fake_data.rb
```

## Esecuzione e generazione di un file Excel

```
ruby example_01.rb
```

## Interrogazione dei dati

```bash
irb
```

```ruby
require_relative 'config/required'
require_relative '../lib/summarize'
include Summarize

UnpaidRatio.all.size
UnpaidRatio.first
UnpaidRatio.where(operator: "Acme").sum(:revenue)
```
