require 'spreadsheet'
require 'net/smtp'
require 'net/http'
require 'net/https'
require 'json'


def get_top_mkts_by_vol(num_results = 5)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarkets/BTC"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data'].sort_by {|h| h['BaseVolume']}.reverse[0..num_results - 1] # sort currencies by amount traded in BTC
end

def get_market_orders(id, num = 100)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarketOrders/#{id}/#{num}"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data']
end

def get_market_state(id)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarket/#{id}"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data']
end

def get_market_history(id)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarketHistory/#{id}"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data']
end



# create empty doc up here
empty_doc = Spreadsheet::Workbook.new
history_data = []
completed_orders = []
completed_buys = []
completed_sells = []

# retrieve currency list
currencies = get_top_mkts_by_vol 10

# generate empty spreadsheet based on currencies retrieved

currencies.each do |c|
  empty_doc.create_worksheet :name => c['Label'].sub(/\/BTC/, '')
end

empty_doc.write '../output/empty_spreadsheet.xls'
doc = Spreadsheet.open '../output/empty_spreadsheet.xls'

# __ times, every __ minutes, retrieve and calculate relevant data and put it into the spreadsheet
for i in 0...240
  # retrieve/calculate all the data from cryptopia
  currencies.each_with_index do |c, j|
    id = currencies[j]['TradePairId']

    market_data = get_market_state id
    order_data = get_market_orders id
    new_history_data = get_market_history id
    history_data += [new_history_data]

    completed_orders = (history_data[j + (currencies.size * i)] - history_data[j + (currencies.size * (i - 1))]) unless i == 0

    completed_buys = completed_orders.select{|a| a['Type'] == 'Buy'}.size
    completed_sells = completed_orders.size - completed_buys

    total_orders = i == 0 ? 'N/A' : completed_orders.size

    buy_orders = order_data['Buy']
    sell_orders = order_data['Sell']

    price = market_data['LastPrice']

    buy_sum = buy_orders.inject(0) {|sum, hash| sum + hash['Total']}
    sell_sum = sell_orders.inject(0) {|sum, hash| sum + hash['Total']}

    buy_sell_ratio = (buy_sum / sell_sum).round(5)

  # write results to spreadsheet
    sheet = doc.worksheet j
    sheet.row(0).push 'Price', 'Open Buys Total', 'Open Sells Total', 'Open Order Buy/Sell Ratio', 'Completed Orders', 'Completed Buys', 'Completed Sells' if i == 0
    row = sheet.row(i + 1)
    row.push price, buy_sum, sell_sum, buy_sell_ratio, total_orders, completed_buys, completed_sells
  end

  puts "cycle #{i + 1} complete"

  doc.write '../output/updated_spreadsheet.xls'

  sleep 30
end