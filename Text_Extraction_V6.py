'''
This program will be able to extract all of the job information directly from word documents 
in a folder, by going through each files, and append the information into structured dataset.
'''

#Import modules
import pandas as pd
import glob
import textract


###########
#Functions#
###########
def DocToCorpus(indir):
    # =============================================================================
    #Function: Access each job description documents(worddocuments) in a folder and
    # extracts text information, and create a dataset containing the text 
    # information and corresponding document id.
    #Param:
     #@indir - Folder directory containing job descriptions. 
    # =============================================================================

    #Initialize empty dataframe.
    corpus = pd.DataFrame(columns=['DOC_ID', 'Text'])
    #Initialize count.
    count = 0
    #Iterate through all of the files and extract its text information as string.
    for file in glob.glob(indir): 
        # Passing docx file to process function
        text = textract.process(file)
        corpus = corpus.append({'DOC_ID':count + 1, 'Text':str(text)}, ignore_index=True)
        count = count + 1
    print('Total of ' + str(count) + ' documents extracted.')
    return corpus


def ParseDesc(text, parser):
    # =============================================================================
    #Function: Transforms a job description in text value into a dictionary, by parsing
    # subtitles and its corresponding contents.
    #Param:
     #@text - text (string) value to be parsed
     #@parser - list of subtitles to match within text.
    # =============================================================================
    
    #Split the text value with two new lines as parsing criteria.
    text_split = text.split('\\n\\n')
    #Initialize a document level dictionary of subtitles and contents.
    parse_dict={}
    #For loop to iterate on every single line within a document.
    for line in text_split:
        #Initialize a list to store order of subtitles for each of the document.
        subt_order = []
        #Iterate on every line in text_split list to create a ordered list of subtitles.
        for line in text_split:
            #Code to check whether line in text_split is in parse_list
            if line.lower().replace(' ', '') in parse_list:
                #Store the order of subtitles for that specific document.
                subt_order.append(line)
        #From now, use the ordered subtitles to ...
        #For every two consecutive subtitles in the ordered list, find the index of line where line mathces
        #the two list element, and return lines where its indexes are between indexes of two consecutive subtitles.
        for iterstart in range(0,len(subt_order)):
            #Add 1 to start index of ordered subtitle list which is the end subtitle.
            iterend=iterstart+1
            try:
                #return a values in the text_split list where its indexes are between the indexes of the start subtitle and end subtitle.
                #Join the string together to create a whole content.
                content=' '.join(text_split[text_split.index(subt_order[iterstart])+1:text_split.index(subt_order[iterend])])
                #Add the content to dictionary with its corresponding subtitle.
                parse_dict[subt_order[iterstart]] = content
            except:
                pass
    return parse_dict



###########
#Main Code#
###########

#Access each files in directory and create a corpus.
corpus=DocToCorpus(indir='C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Files and Job Descriptions for BAT4301 Skills Inventory Project/*.docx')
#Create a list of subtitles to match within a text values.
parse_list = ['position', 'department', 'paygrade', 'jobcode', 'classification', 'jobfamily', 'repordaytsto', 'prepareddate',
              'jobduties', 'additionalduties','experience', '\\t\\tsummary', 'education', 'numberofdirectreports',
              'numberofindirectreports', 'supervisionreceived','securitysensitive','attendancestandard','internalcontrols',
              'decisionmaking','budgetresponsibility', 'financialresponsibility', 'physicalrequirements','environmentalconditions'
              'knowledge,skills,andabilities','licesnses/certifications','otherrequirements',
              'supervisoryresponsibilities','interaction','computersoftware','equipment','chemicalexposure']
#Parse the text information in the corpus and create a dictionary.
doc_list = []
for row in range(0, corpus.shape[0]):
    #Split the text information by new line indicator.
    print(str(row/corpus.shape[0])+'% Completed')
    doc_list.append(ParseDesc(corpus.iloc[row,1], parse_list))
    
#For loop to concatenate all dictionary content into dataframe.
data = pd.DataFrame()
for dictionary in doc_list:
    data = pd.concat([data, pd.DataFrame.from_dict(dictionary, orient='index').T],             # Append two pandas DataFrames
                          ignore_index = True,
                          sort = False)


#Set output directory
outdir = 'C:\\Users\\taku0\\OneDrive\\Documents\\SP 2022\\Consulting\\Files\\Data\\Parse_data.xlsx'
#Export dataset to indicated directory
data.to_excel(outdir, index = False)