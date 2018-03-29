require 'spreadsheet'
require 'net/smtp'
require 'net/http'
require 'net/https'
require 'json'


def get_top_mkts_by_vol
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarkets/BTC"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data'].sort_by {|h| h['BaseVolume']}.reverse[0..4] # sort currencies by amount traded in BTC
end

def get_market_orders_by_id(id, num = 100)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarketOrders/#{id}/#{num}"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data']
end

def get_market_state_by_id(id)
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarket/#{id}"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  response['Data']
end



# create empty doc up here
empty_doc = Spreadsheet::Workbook.new

# retrieve currency list
currencies = get_top_mkts_by_vol

# generate empty spreadsheet based on currencies retrieved

currencies.each do |c|
  empty_doc.create_worksheet :name => c['Label'].sub(/\/BTC/, '')
end

empty_doc.write '../output/empty_spreadsheet.xls'
doc = Spreadsheet.open '../output/empty_spreadsheet.xls'

# __ times, every __ minutes, retrieve and calculate relevant data and put it into the spreadsheet
for i in 0...1
  # retrieve/calculate all the data from cryptopia
  # trade_pair_ids.each do |id|
  currencies.each_with_index do |c, j|
    id = currencies[j]['TradePairId']

    market_data = currencies[j]
    order_data = get_market_orders_by_id id

    buy_orders = order_data['Buy']
    sell_orders = order_data['Sell']

    buy_sum = buy_orders.inject(0) {|sum, hash| sum + hash['Total']}
    sell_sum = sell_orders.inject(0) {|sum, hash| sum + hash['Total']}

  # write results to spreadsheet
    sheet = doc.worksheet j
    sheet.row(0).push 'Price', 'Buy Total', 'Sell Total'
    row = sheet.row(i + 1)
    row.push market_data['LastPrice'], buy_sum, sell_sum
  end

  doc.write '../output/updated_spreadsheet.xls'
end