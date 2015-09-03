# encoding: UTF-8
require 'trello'

PUBLIC_KEY = ''
MEMBER_TOKEN = ''
FILE_NAME = './5A.txt'
CARD_ID = ''

Trello.configure do |config|
	config.developer_public_key = PUBLIC_KEY
	config.member_token = MEMBER_TOKEN
end

def readFile(filename) 
	data = []
	counter = 0
	isInProvince = false
	provinceData = {}
	File.open(filename, 'r').each_line do |line|
		splited = line.split(' ')
		#puts "#{line}: splited: #{splited}"

		if isInProvince and splited.empty? then
			data.push(Marshal.load(Marshal.dump(provinceData)))
			provinceData.clear
			isInProvince = false
			next
		end

		if not isInProvince then
			provinceData['province'] = splited[0]
			provinceData['spot'] = []
			isInProvince = true
			next
		end

		array = provinceData['spot']
		array.push(splited[0])

		puts "#{counter}: #{provinceData['province']}-#{splited[0]}"
		counter = counter + 1
	end

	puts "data: #{data}"
	return data
end


def main() 
	fileData = readFile(FILE_NAME)
	card = Trello::Card.find(CARD_ID)

	if not card then
		puts "Error: Can't find the card"
		return
	end

	puts card.name

	# isContinue = false
	for data in fileData do
		puts "Begin to add the data=#{data}"
		province = data['province']

		# for the break in middle
		#if province == "贵州" then
		#	isContinue = true
		#end

		#if not isContinue then
		#	next
		#end

		check_list = nil
		#puts "Old checklist=#{card.checklists}"
		if (card.checklists.length == 0) || card.checklists.index{ |item| item.name == province } == nil then
			card.create_new_checklist(province)
			puts "Create new checklist, name=#{province}"
		end

		check_list = card.checklists[card.checklists.index{ |item| item.name == province }]

		spots = data['spot']
		if spots == nil then
			puts "Warning: Empoty spot, province=#{province}"
			next
		end

		for spot in spots do
		puts "Begin to add the spot=#{spot}"
			if check_list.items.length != 0 && check_list.items.index { |item| item.name == spot } != nil then
				puts "Pass a old item, province=#{province}, item=#{spot}"
				next
			end

			check_list.add_item(spot)
			puts "create new item, province=#{province}, item=#{spot}"
		end
	end
end

main()
