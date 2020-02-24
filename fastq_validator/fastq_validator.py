import sys, xlwt

#Works in conjunction with fastq_validator.bash
#The path to the summary.tsv is piped into this program

#DO NOT CHANGE
summarypath = sys.stdin.readlines()
gentxtpath = summarypath[0:-11]
outfilepath = '{0}{1}'.format(summarypath[0:-11], 'summary.xlsx')
workbook = xlwt.Workbook()
worksheet1 = workbook.add_sheet('Summary')
errorsheet = workbook.add_sheet('Errors')

#I'm trying to make the summary into an excel file (human readable)
with open(summarypath, 'r') as infile:
	nameline = infile.readline()
	errorline = infile.readline()
	empty = infile.readline()
	i = 1
	errors = []
	x = 0
	y = 1
	
	#Enter the headers into the excel file
	worksheet1.write(0, 0, 'Filename')
	worksheet1.write(0, 1, 'Validation')
	worksheet1.write(0, 2, 'Link to Errors')
	
	while nameline != '':
		#Start cleaning up the nameline and errorline to show what we need
		#nameline shows only the .txt filename, errorline only shows 'FASTQ_SUCCESS' or 'FASTQ_INVALID'
		nameline = nameline[0:-4]
		nameline = nameline[nameline.rfind('/'):]
		errorline = errorline[-13:]
		
		#Open up the original .txt file if 'INVALID' in errorline and find the errors
		if 'INVALID' in errorline:
			txtpath = '{0}{1}'.format(gentxtpath, nameline)
			line = 'START'
			#Open the original txt file and find all lines with errors to add to the list "errors"
			with open(txtpath, 'r') as errortxt:
				for line in errortxt:
					if 'ERROR' in line:
						errors.append(line[9:])
			#Write the list "errors" into the sheet called "Errors", starting from A1
			errorsheet.write(x, 0, nameline)
			for error in errors:
				errorsheet.write(x, y, error)
				y += 1
			#Reset the row value (y), and move one column to the right (x+1)
			x += 1
			y = 0
		
		#Enter info into the excel file in the form .write(col, row, data)
		worksheet1.write(i, 0, nameline)
		worksheet1.write(i, 1, errorline)
		i += 1
		
		#Assign vars again, and move 3 lines down the summary.tsv file
		#We clear the errors list, and carry over i
		nameline = infile.readline()
		errorline = infile.readline()
		empty = infile.readline()
		errors = []
	
	#Save the excel file
	workbook.save('{0}{1}'.format(gentxtpath, 'summary.xlsx')