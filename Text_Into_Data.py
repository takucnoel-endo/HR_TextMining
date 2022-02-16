import os
import glob
import textract

count = 0
for file in glob.glob('C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project/*.docx'): 
    # Passing docx file to process function
    text = textract.process(file)
    print('')
    print('')
    print('')
    print('DOC #: ' + str(count))
    print(text)
    count = count + 1
    
    
#Test data set contruction with one file. 
file = 'C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project\\Chief Human Resources Officer (1).docx'
text = str(textract.process(file))
text_split = text.split('\\n')
text_split
for line in text_split:
    if (line.isupper() == True) and (line != 'X'):
        print(line)
        