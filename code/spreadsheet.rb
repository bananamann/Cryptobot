require 'spreadsheet'

# create empty doc up here
empty_doc = Spreadsheet::Workbook.new

# retrieve currency list
# blah blah code for that

# generate empty spreadsheet based on currencies retrieved

currencies = "ETN", "XVG", "LTC", "XRP"

currencies.each do |c|
  s = empty_doc.create_worksheet :name => c
end

empty_doc.write './empty_spreadsheet.xls'

doc = Spreadsheet.open './empty_spreadsheet.xls'

# __ times, every __ minutes, retrieve and calculate relevant data and put it into the spreadsheet

for i in 0...3
  # retrieve/calculate all the data from cryptopia
  # blah blah code placeholder
  # more code

  # write results to spreadsheet
  currencies.each_with_index do |c, j|
    sheet = doc.worksheet j
    sheet.row(0).concat %w{data stuff} if i == 0
    row = sheet.row(i + 1)
    row.push "result1", "result2"
  end

  doc.write './updated_spreadsheet.xls'
end