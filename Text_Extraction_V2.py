'''
This program will be able to extract all of the job information directly from word documents 
in a folder, by going through each files, and append the information into structured dataset.
'''

#Import modules
import pandas as pd
import glob
import textract

#Initialize empty dataframe.
corpus = pd.DataFrame(columns=['DOC_ID', 'Text'])
#Initialize count.
count = 0
#Iterate through all of the files and extract its text information as string.
for file in glob.glob('C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project/*.docx'): 
    # Passing docx file to process function
    text = textract.process(file)
    corpus = corpus.append({'DOC_ID':count + 1, 'Text':str(text)}, ignore_index=True)
    count = count + 1
print('Total of ' + str(count) + ' documents extracted.')

