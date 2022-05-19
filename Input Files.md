## Document Overview
This document will provide an extensive exaplanation of the input files (or folder) needed to run the programs used in the HR skills extraction project. 
The explanation will be devided into two different scripts: R Script for text analysis and deliverable generation and Python Script for data extraction.

## Text Extraction (Python Script) 
### Job Descriptions Folder
![Job Description Folder](https://github.com/takucnoel-endo/Images/blob/HR-Text-Mining/Job%20Descriptions%20Folder.png)
This folder contains all of the job descriptions available for trinity university HR at the time point of this project was initiated.
All of the documents are contains as `.docx` extension file. 
The following function in the python script will interact with this folder system and extract all text information from the word documents. 

```python
#Import modules
import pandas as pd #Dealing with dataframes.
import glob #For accessing files within a folder.
import textract #For extracting raw text from word document.

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
    
#Access each files in directory and create a corpus.
corpus=DocToCorpus(indir='[input directory]/*.docx')
```
## Text Analysis, Standardization, and Deliverable Generation (R Script)
### 1. Parsed Data.xlsx


