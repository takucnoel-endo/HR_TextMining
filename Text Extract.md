## Overview
This program will be able to extract all of the job information directly from word documents in a folder, by going through each files, and append the information into structured dataset. In addition, it will enable the user to parse any job descriptions by sub headers, as long as those subheaders to be parsed are specified. 

## Module Import
* pandas: This module is a very useful data science module for dealing with dataframes. I used this module to build a dataframe to store all raw text extracted from a document.
* glob: This module is a useful took to access files within a certain dorectory. In this program, I used this module to create a list of word files within my local directory that can be accessed utilizing for loop method. 
* textract: This module creates an easy method for extracting text information as raw text. I used thi module to extract all text information from a word documend.
```python
#Import modules
import pandas as pd #Dealing with dataframes.
import glob #For accessing files within a folder.
import textract #For extracting raw text from word document.
```
##  Function - Text Extraction
#### Description: 
This function was built to extract text information from each word documents stored within a single local folder as raw text, and return a data frame of raw text data with its corresponding unique document identification.
#### Parameters: 
`indir`: The input folder directory where all job descriptions in `.docx` format are located.
#### Procedures:
1. First step is to initialize an empty dataframe with two columns `Doc_ID` and `Text`.
2. Initialize counter by setting it as zero. The counter will keep track of how many word documents have been extracted and also work to assign a unique identification for each raw text that is extracted.
3. Using `glob` method and for-loop, iterate all of the document paths. For every iteration, perform the following.
    * Use `texttract.process()` method to extract document content as raw text.
    * Append the raw text into `Text` column and append the counter to the `DOC_ID` column in the dataframe.
    * Add one to the current counter.
4. Return a resulting dataframe.

#### Result: 
Here is the quick overview of what above step does in a diagram.
![Text Extraction](https://github.com/takucnoel-endo/Images/blob/main/Screen%20Shot%202022-04-14%20at%201.17.22%20PM.png)

#### Code: 
```python
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
```



## Function - Text Parsing
#### Description: 
This function was built to parse the extracted raw text into subcategories, consisting of columns as its sub headers and its content as values.
#### Parameters: 
* `text`: The raw text to parse.
* `parser`: User defined list of subheaders within the job description to parse the raw text.
#### Procedures:
1. Use `text.split()` method to split by two new line indicators, which will return a list of all lines within a document. By the structure of the document, every subheaders are on its own line, followed by its content on after two new line indicators. Assign the result to `text_split` variable.
2. Initialize an empty python dictionary `parse_dict` to store parsed contents and their associated subheaders. 
3. Initialize an empty list called `sub_order` to store the order of subheders within a document. This list is nessesary, because not all documents have the same order of subheaders.
4. Use for-loop to iterate elements in `text_split` (all lines in the document) and do the following.
    * If the current line is included in the user defined list of subheaders, then add the line into `sub_order`.
5. Use for-loop to iterate elements in `text_split` again and do the following.
    * Use another for-loop to iterate on from 0 to length of the `sub_order`(number of elements) and do the following. (This will defined `iterstart` variable which is current index of subheader that is needed to be extracted.)
        * Add one to `iterstart` and assign to `iterend` [Note: `iterend` variable is index number of next subheader after the current subheader. Defining `iterend` will allow for program to identify where the break between a content and the next subheader is].
        * Join the lines in `text_split` between where the line is the string that is the same as the string that has the index value of one plus `iterstart` and `iterend` (This is the all of the content strings that are under the current subheader). Assgin this string value to `content` variable.
        * Append the `content` value to along with its associated subheader name to `parse_dict` dictionary.
6. Finally return `parse_dict`

#### Result:
The result is the python dictionary of length `n` that has represent a single document which consists of `n` subheaders. The dictionary consists of subheader names and its associated content. Here is a diagram of resulting dictionary.
![Dictionary](https://github.com/takucnoel-endo/Images/blob/main/Screen%20Shot%202022-04-14%20at%204.46.13%20PM.png)

#### Code: 
```python
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
    #Initialize a list to store order of subtitles for each of the document.
    subt_order = []
    #Iterate on every line in text_split list to create a ordered list of subtitles.
    for line in text_split:
    #Code to check whether line in text_split is in parse_list
        if line.lower().replace(' ', '') in parse_list:
            #Store the order of subtitles for that specific document.
            subt_order.append(line)
    #For loop to iterate on every single line within a document.
    for line in text_split:
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
                parse_dict[subt_order[iterstart].upper().replace(' ', '')] = content
            except:
                pass
    return parse_dict

```

## Main Procedures
#### Description: 
This part of the program will bring together all of the functions defined above, and creates a final output: a dataframe of all documents parsed by its subheaders into columns.

#### Procedures:
1. Using the text extraction function `DocToCorpus` defined, create a dataframe of raw text along with its document identification number. Assign output to `corpus` variable.
2. Define the list of subheaders to be used to parse the raw text. Assign to `parse_list` variable.
3. Create a empty list `doc_list` to store all of the dictionary of parsed content and thier subheaders.
4. Use for-loop to iterate through all of the rows in corpus (in other words, every document) and do the following for every iteration.
    * Print percent of document iterated to track progress of the loop.
    * Apply `ParseDesc()` function defined to get the dictionary that contains all subheaders and its corresponding subheaders.Append the function output to `doc_list`. 
5. Create an empty dataframe `data` to append and store parsed information.
6. Use for-loop to iterate on every element in `doc_list` and for every iteration, append the parsed data to dataframe.
7. Define output directory.
8. Export resulting dataset to the defined directory.

#### Result:
The result of this procedure is an excel file that has been stored in the local directory that the user defined. The preview of the excel file is as follows.

![Dictionary](https://github.com/takucnoel-endo/Images/blob/main/Screen%20Shot%202022-04-14%20at%205.04.57%20PM.png)

```python
#Access each files in directory and create a corpus.
corpus=DocToCorpus(indir='[input directory]/*.docx')
#Create a list of subtitles to match within a text values.
parse_list = ['position', 'department', 'paygrade', 'jobcode', 'classification', 'jobfamily', 'repordaytsto', 'prepareddate',
              'jobduties', 'additionalduties','experience', '\\t\\tsummary', 'education', 'numberofdirectreports',
              'numberofindirectreports', 'supervisionreceived','securitysensitive','attendancestandard','internalcontrols',
              'decisionmaking','budgetresponsibility', 'financialresponsibility', 'physicalrequirements','environmentalconditions'
              'knowledge,skills,and abilities','licesnses/certifications','otherrequirements',
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
outdir = '[output directory]/Parse_data.xlsx'
#Export dataset to indicated directory
data.to_excel(outdir, index = False)
```
