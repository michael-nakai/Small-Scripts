import sys, pathlib
data = sys.stdin.readlines()
data = data[0]
data = data.rstrip()
data = data.split(' ')

newdata = []
IDlist = []

#Create a list of the full filenames
for element in data:
	a = element.rfind('/')
	newdata.append(element[a+1:])

#Create a list of only IDs (only take the string until the first '_')
for element in newdata:
	a = element.find('_')
	IDlist.append(element[0:a])

#Remove duplicate IDs from IDlist
IDlist = list(dict.fromkeys(IDlist))

#Set pth to the path to the script directory
pth = pathlib.Path(__file__).parent.absolute()

#Make the tsv. The for loop makes the individual rows for each ID
with open('{0}/manifest.tsv'.format(pth), 'w') as file:
	file.write('#SampleID\tforward-absolute-filepath\treverse-absolute-filepath')
	i = 0
	for element in IDlist:
		a = element
		b = '{0}/{1}'.format(pth, newdata[i])
		i += 1
		c = '{0}/{1}'.format(pth, newdata[i])
		i += 1
		file.write('\n{0}\t{1}\t{2}'.format(a, b, c))
		
print('Ran without errors')