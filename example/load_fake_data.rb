# will generate fake data
require_relative 'config/required'


class FakeData

  
  def self.destroy_up(operator=nil)
    if operator.nil?
      UnpaidRatio.delete_all
    else
      UnpaidRatio.where(operator: operator).delete_all
    end
  end

  def self.destroy_upo(operator=nil)
    if operator.nil?
      UnpaidRatioOther.delete_all
    else
      UnpaidRatioOther.where(operator: operator).delete_all
    end
  end

  # mandatory to pass options[:scopes]
  def self.generate(operator, options={})
    base_date = options[:base_date] || Date.new(2012,3,1)
    markets   = options[:markets] || [UR_CAPTIVE]
    scopes    = options[:scopes]

    s_count = 0 # successfull count
    f_count = 0 # failed count

    hash = {operator: operator}

    markets.each do |market|
      hash.merge!(market: market)

      areas.each do |area|
        hash.merge!(area: area)

        scopes.each do |scope|
          hash.merge!(scope: scope)

          uses_for_8_9.each do |use|
            hash.merge!(use: use)

            (0...12).each do |month|
              im = base_date.next_month(month).strftime("%Y-%m")
              rm = base_date.next_month(month).next_year(2).strftime("%Y-%m")
              tu = rand(2000)# fatturato
              ta = tu * rand
              hash.merge!(
                issuing_month: im,
                reference_month: rm,
                revenue: tu,
                collected:   ta
              )
              r = UnpaidRatio.new(hash)
              r.save ? s_count+=1 : f_count+=1 # true or false
            end
          end
        end
      end
    end
    puts "Failed saves:      #{f_count}"
    puts "Successfull saves: #{s_count}"
    s_count
  end
end



operators = %w( acme bastogni pera zikkri )
base_date = Date.new(2012,3,1)
markets   = [UR_CAPTIVE, UR_FREE]
scopes    = ["Lombardia", "Piemonte", "Lazio", "Toscana", "Basilicata", "Trentino Alto Adige", "Umbria", SCOPE_TOTALE]
options = {markets: markets, scopes: scopes, base_date: base_date}

operators.each do |operator|
  FakeData.destroy_up(operator)
  FakeData.generate(operator, options)
end





