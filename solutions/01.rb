def convert_to_bgn(amount, currency)
  exchange_rate = {usd: 1.7408, eur: 1.9557, gbp: 2.6415, bgn: 1.0000}
  (exchange_rate[currency] * amount).round(2)
end

def compare_prices(amount_a, currency_a, amount_b, currency_b)
  convert_to_bgn(amount_a, currency_a) <=>
    convert_to_bgn(amount_b, currency_b)
end
