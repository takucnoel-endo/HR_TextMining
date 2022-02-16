'''
This program will be able to extract all of the job information directly from word documents 
in a folder, by going through each files, and append the information into structured dataset.
'''

#Import modules
import os
import glob
import textract

#Initialize count.
count = 0
#Iterate through all of the files and extract its text information as string.
for file in glob.glob('C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project/*.docx'): 
    # Passing docx file to process function
    text = str(textract.process(file))
    text_split = text.split('\\n')
    #Initlize title count.
    title_count = 0
    #For every document, go through each line and extract the titles (titles are all caps)
    for line in text_split:
        #If there is title, add count to the number of the titles. 
        if (line.isupper() == True) and (line != 'X') and (line !='N/A'):
            title_count = title_count + 1
    print('')
    print('')
    print('')
    print('DOC #: ' + str(count))
    print('Title Count: ' + str(title_count)
    count = count + 1
    
print('Total of ' + str(count) + ' documents extracted.')
    
#This code is a testing code to implement data extraction for just one file.
#This code will be joint into code above within the for loop. 
file = 'C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project\\Chief Human Resources Officer (1).docx'
text = str(textract.process(file))
text_split = text.split('\\n')
text_split
for line in text_split:
    if (line.isupper() == True) and (line != 'X'):
        print(line)


#Initialize count.
count = 0
#Iterate through all of the files and extract its text information as string.
for file in glob.glob('C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project/*.docx'): 
    # Passing docx file to process function
    text = textract.process(file)
    print('')
    print('')
    print('')
    print('DOC #: ' + str(count))
    print(text)
    count = count + 1
print('Total of ' + str(count) + ' documents extracted.')
