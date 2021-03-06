## Project Overview
On this project, the team worked with the university human resources department to run a text analysis on job descriptions currently available at the university. More specifically, there were two research questions. 


1. What skills are currently included in Trinity staff job descriptions?
2. What skillsets are included in O*NET bright outlook occupations and which of those skills are currently included in Trinity staff job descriptions?

Here we will present the script for this project which includes text standardization, analysis, and skills extraction and deliverable generation. For this project, we used R programming lanuguage as it provides with extensive and useful libaries for text analysis.

## Data Overview
The data we used in this project was a pre-parsed dataset that includes subheaders of a job descriptions as columns and rows as each indivisual document. Prior to this script, we used python to parse job documents into datasets. The details about how we parsed the job postings and created the dataset is documented in another page - [Job Description Parsing Algorithm](https://github.com/takucnoel-endo/Code-Samples/blob/main/Job%20Description%20Parsing.md). Diagram below is the structure of the dataset that we used for this project.

![Parsed Text Dataset](https://github.com/takucnoel-endo/Images/blob/HR-Text-Mining/Screen%20Shot%202022-04-18%20at%206.24.01%20PM.png)
## Installing Packages & Importing Libraries
First we imported all of the nessesary libearies to get started with this project.
```r
#Install required package if not found.
if (!require("readxl")) install.packages("readxl")
if (!require("tm")) install.packages("tm")
if (!require("stringr")) install.packages("stringr")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("textstem")) install.packages("textstem")
if (!require("topicmodels")) install.packages("topicmodels")
if (!require("dplyr")) install.packages("dplyr")
if (!require("writexl")) install.packages("writexl")
#Load required libraries
library(readxl)#For reading excel sheet.
library(tm) #For building corpus and further preprocessing.
library(stringr) #For string manipulation. 
library(stringi) #For low level string opration and cleaning.
library(textstem) #For text stemming.
library(topicmodels) #For topic modeling.
library(dplyr) #For dataframe operations.
library(writexl) #For exporting datasets.
```

## Function - Text Standardization
#### Description: 
This function applied basic standardization techniques to corpus. These techniques include turning to lower case, removing numbers, removing punctuations, removing white spaces, and removing stop words. This function can also perform lemmatization of terms in corpus with user defined parameter. Returns a corpus with all specified text standardization applied.
#### Parameters: 
`corp`: `tm` package volatile corpus.

`lemmatize`: Whether or not to apply lemmatization on terms in the corpus (True/False). 

`...`: Additional stopwords vector. If not specified, then stop words will be a third party predefined stopwords.
```r
standardize <- function(corp, lemmatize, ...){
  #Basic standerdization
  #Make all lower case
  corp <- tm_map(corp, content_transformer(tolower))
  #remove numbers
  corp <- tm_map(corp, content_transformer(removeNumbers))
  #Remove punctuation
  corp <- tm_map(corp, content_transformer(removePunctuation))
  #remove white space
  corp <- tm_map(corp, content_transformer(stripWhitespace))
  #If word lemmatization option is TRUE.
  if(lemmatize==TRUE){
    #Lemmatize
    corp <- tm_map(corp, lemmatize_strings)
    corp <-tm_map(corp, PlainTextDocument)
  }
  #Additional standerdization
  #Stop words
  corp <- tm_map(corp, removeWords, words=c(stopwords('english'), ...))
  return(corp)
}
```
## Function - Word Frequency and Visualization
#### Description: 
Returns a top n term counts on the corpus in ascending or descending order. This returns both table and bar chart for visualizations. 
#### Parameters: 
`tdmmatrix`: Term-frequency matrix. must be in matrix form. 

`order`: Descending or ascending ("desc"/"asc")

`n`: top `n` terms.
```r
count_freq <- function(tdmmatrix, order, n){
  #Create a term count table.
  term_freq <- rowSums(tdmmatrix)
  if(order == 'desc'){
    #Sort the terms into most frequent to least frequent
    term_freq <-sort(term_freq, decreasing=TRUE)
    #Barplot of the word frequency. n most frequent.
    par(mar=c(13,4,4,2))
    plot = barplot(term_freq[1:n], col='darkred',las=2,ylab='Frequency',main=paste('Word Frequency: Top', n),cex.lab   = 1)
  }
  if(order == 'asc'){
    #Sort the terms into most frequent to least frequent
    term_freq <-sort(term_freq, decreasing=FALSE)
    #Barplot of the word frequency. n least frequent.
    par(mar=c(13,4,4,2))
    plot = barplot(term_freq[1:n], col='darkred',las=2,ylab='Frequency',main=paste('Word Frequency: Top', n),cex.lab   = 1)
  }
  return(term_freq)
  return(plot)
}
```
## Function - Tokenizing Words
#### Description: 
Collection of anonymous functions to tokenize words into bigrams, trigrams, as well as combinations of unigrams, bigrams, and trigrams. 

```r
#Tokenizers
#Bigram Tokenizer.
Tokenizer2 <- function(x)unlist(lapply(ngrams(words(x), 2),paste, collapse = ' '), use.names = FALSE)
#Trigram Tokenizer
Tokenizer3 <- function(x)unlist(lapply(ngrams(words(x), 3),paste, collapse = ' '), use.names = FALSE)
#Combination Tokenizer.
Tokenizer1to3 <- function(x)unlist(lapply(ngrams(words(x), 1:3),paste, collapse = ' '), use.names = FALSE)
```
## Function - Skills Matching and Extraction
#### Description: 
Performs matching of terms to skills synonyms and returns the dataframe of matched terms in corpus corresponding to certain skills.
#### Parameters:
`skill_syn`: Synonyms dictionary that has a list of skills that are similar to each other.

`corp`: `tm` package volatile corpus.
```r
Match_skills <- function(skill_syn, corp){
  #TERM MATCHING
  #Initialize empty skills dictionary
  skills_list = list()
  #Initialize count to track of loop progress.
  count = 1
  for (onet_skill in colnames(skill_syn)){
    skill = onet_skill
    #Initialize a vector to store matched terms.
    terms_matched = c()
    #For every matching pattern in each of 35 skills.
    for(word_pattern in unique(str_to_lower(stem_strings(pull(skill_syn[skill]))))){
      pattern = word_pattern
      for(doc_num in (1:length(corp$content))){
        #Store mactched term. RegEx: \\bpattern[a-zA-Z]*\\b
        term = grep(str_remove_all(paste(paste("\\b",pattern), "[a-zA-Z]*\\b"), ' '), unlist(str_split(corp[[doc_num]]$content[1],' ')), value=T)
        #Append matched term to the term macth vector.
        terms_matched <- append(term, terms_matched)
      }
      #Dynamically assign matched term as a vector for each 35 skills
      #Also put them into list of vectors to storage for later use.
      skills_list[[count]] = assign(str_remove_all(paste(skill, '_terms'), ' '), unique(terms_matched))
    }
    print(paste(count, paste('Extracting', skill)))
    count = count + 1
  }
  #BUILDING DATAFRAME
  #Find the maximum length of skills vectors.
  length_vec = c()
  for(i in seq(1:length(skills_list))){
    length_vec = append(length(skills_list[[i]]), length_vec)
  }
  #Create empty data frame
  skills_dict <- data.frame(matrix(NA,nrow = max(length_vec),ncol = length(skills_list)))
  #Set the column name skills dictionary.
  colnames(skills_dict) = colnames(syn)
  #Create the skills dictionary by first standardizing length of all vectors into the same length and adding those vectors into dataframe.
  for(colind in seq(1:length(skills_list))){
    length(skills_list[[colind]]) = max(length_vec)
    skills_dict[,colind] = skills_list[[colind]]
  }
  return(skills_dict)
}
```

## Main Script
### Reading Data and Assigning ID
```r
#Read data into R session.
data <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Parsed_data.xlsx')
#Assign preliminary ID to document rows
data$doc_id <- seq(nrow(data))
```
### Data Ceaning
#### Columns
First, we worked with the columns of the raw data. Here, we renamed a column and removed columns that are unnessesary for this analyis. The unnessesary columns were determined by its nature of repetitiveness and by its lack of information that it provides to the analysis itself. For example, columns such as `COMPUTER SOFTWARE` was removed, because for most jobs, it contains only Microsoft products. Finally we renamed the analysis text to `text`.
```r
#Rename summary columns name.
#Use raw string.
colnames(data)[which(names(data) ==
                       r"{\T\TSUMMARY}")] <- "SUMMARY"
#The extraction code extracted EXPERIENCE,KNOWLEDGE, SKILLS, AND ABILITIES, and LICENSES/CERTIFICATIONS together. 
#Parse these string to only collect KNOWLEDGE, SKILLS, AND ABILITIES. 
data$KNOWLEDGESKILLSABILITIES<-gsub('LICENSES/CERTIFICATIONS.*', '', gsub('KNOWLEDGE, SKILLS, AND ABILITIES', '', str_extract(data$EXPERIENCE, "KNOWLEDGE, SKILLS, AND ABILITIES.*")))
#Group columns by columns to be joined together, and columns that is not important for analysis.
#Remove unnesessary features from the dataset.
subset_vec <- c("CLASSIFICATION","REPORTSTO","PREPAREDDATE","OTHERREQUIREMENTS","SUPERVISORYRESPONSIBILITIES",
                "NUMBEROFDIRECTREPORTS","NUMBEROFINDIRECTREPORTS","SUPERVISIONRECEIVED","SECURITYSENSITIVE",
                "ATTENDANCESTANDARD","INTERNALCONTROLS","DECISIONMAKING", 'EDUCATION', 'PHYSICALREQUIREMENTS',
                'FINANCIALRESPONSIBILITY','BUDGETRESPONSIBILITY','EQUIPMENT','ADDITIONALDUTIES','EDUCATION',
                'EXPERIENCE','INTERACTION','COMPUTERSOFTWARE')
data <- data[, !(colnames(data) %in% subset_vec)]
#Remove all partial duplicated rows by Job Codes.
data <- data %>% distinct(JOBCODE, .keep_all = TRUE)
#Join columns together. 
join_vec <- c('SUMMARY', 'JOBDUTIES','ADDITIONALDUTIES','EDUCATION','EXPERIENCE','INTERACTION','COMPUTERSOFTWARE',
              'EQUIPMENT','BUDGETRESPONSIBILITY','FINANCIALRESPONSIBILITY','PHYSICALREQUIREMENTS','KNOWLEDGESKILLSABILITIES')
data$text <- data$KNOWLEDGESKILLSABILITIES
#Get rid of text specific columns
data <- data[, !(colnames(data) %in% join_vec)]
```
#### Text manipulations
After getting rid of unnessesary columns, some more data cleaning by text manipulation was needed to be applied. One of the biggest issue with this raw data was the formatting strings that indicate special characters. For example, in many columns and the `text` column, apostrophe `'` was represented in hexadecimal form `\xe2\x80\x99s` or other similar representation. These characters had to be removed from the text in order to perform well on text mining process.
```r
#Clean any formatting string with raw string expression.
data$text<-gsub(r"{\xe2\x80\x99s}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\\xe2\\x80\\x99s}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x93}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\t}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x9}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\n}", "", data$text,fixed = TRUE)
data$text<-gsub('Essential duties, as defined under the Americans with Disabilities Act, may include any of the following representative duties, knowledge, and skills.  This is not a comprehensive listing of all functions and duties performed by incumbents of this class; employees may be assigned duties which are not listed below; reasonable accommodations may be made as required.  Requirements are representative of minimum levels of knowledge, skills, and/or abilities.  The job description does not constitute an employment agreement and is subject to change at any time by the employer.  Essential duties and responsibilities may include, but are not limited to, the following:', "", data$text,fixed = TRUE)
data$DEPARTMENT<-gsub(r"{\\xe2\\x80\\x99s}", "s", data$DEPARTMENT,fixed = TRUE)
data$POSITION<-gsub('\\xe2\\x80\\x99s', "s", data$POSITION,fixed = TRUE)
data$POSITION<-gsub(r"{\\xe2\\x80\\x93s }", "s", data$POSITION,fixed = TRUE)
data$JOBCODE<-gsub("\\s*\\([^\\)]+\\)","",data$JOBCODE)
data$JOBCODE<-gsub(r"{\\t}","",data$JOBCODE)
data$JOBFAMILY<-gsub("REPORTS TO.*", "", data$JOBFAMILY)
```

### Corpus Preparation and Pre-processing
#### Volatile Corpus
After cleaning and text wrangling has been completed, we created a sourced object of the cleaned dataset and transformed the source obeject into a volatile corpus using `tm` package available in R. Turning the dataset into corpus using `tm` library allows for usage of extensive pre-processing and analysis functions provided by `tm` library, which is shown in the next section.
```r
#In R, you can specify that a data text is a corpus type, so tm package can recognize it.
#Change the prepared data to corpus, for further preprocessing (Stop words, stemming ... etc)
#Crete a DataFrame Source from the data.
data_source <- DataframeSource(data)
#Convert the source to volatile corpus
corpus <- VCorpus(data_source)
```
#### Corpus Pre-processing
Here, we performed corpus preprocessing by using the `standardize` function I defined above. A list of additional stopwords I defined were also read in from excel file stored in my local drive. As described in the function description, the function turns every term into lower case, removes numbers, removes punctuations, removes white spaces, and removes stop words. This function can also perform lemmatization of terms in corpus with user defined parameter. Returns a corpus with all specified text standardization applied.
```r
#Standardization
#Import dictionary of stop words from a file.
stop_w <- pull(read_excel('[path]/stopwords.xlsx', col_names=FALSE))
#Use the program defined function to standardize.
corpus <- standardize(corpus, lemmatize=TRUE, stop_w)
```

### Exploratory Analysis
Once preprocessing is done, we performed sequences of exploratory text analysis. We first explored top n most appeared terms in the corpus for all n-grams. Next, we used topic modeling technique to explore topics in corpus and its related keywords.
#### Unigrams
```r
#Exploration
#Unigram
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm1 <- TermDocumentMatrix(corpus))
print(dtm1 <- DocumentTermMatrix(corpus))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm1))
#Count for the whole corpus the frequency of the word.
#Use the program defined function to sort and output list as well as n most/least frequent words. 
print(corpus_unifreq <- count_freq(as.matrix(tdm1), 'desc', 20))
```
#### Bigrams
```r
#Bigram
#Build tokenizer function
#Tokenizes into bigram
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm2 <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer2)))
print(dtm2 <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer2)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm2))
#Count for the whole corpus the frequency of the trigram.
#Use the program defined function to sort and output list as well as n most/least frequent trigram. 
print(corpus_bifreq <- count_freq(as.matrix(tdm2), 'desc', 20))
```
#### Trigrams
```r
#Trigram
#Build tokenizer function
#Tokenizes into trigram.
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm3 <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer3)))
print(dtm3 <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer3)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm3))
#Count for the whole corpus the frequency of the trigram.
#Use the program defined function to sort and output list as well as n most/least frequent trigram. 
print(corpus_trifreq <- count_freq(as.matrix(tdm3), 'desc', 20))
```
#### Combined n-grams
```r
#Combine all n-grams.
#Build tokenizer function
#Tokenizes into both unigram, and trigram.
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm1.3 <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
print(dtm1.3 <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm1.3))
print(corpus_unitotrifreq <- count_freq(as.matrix(tdm1.3), 'desc', 20))


```
#### Exploratory Topic Modeling
```r
dtm1_lda = dtm1[apply(dtm1 , 1, sum)>0, ] #remove all docs without words
#Implement a Topic Model with Latent Dirichlet Allocation.
set.seed(100)
#Unigram
tm_model.1 = LDA(dtm1_lda,method='Gibbs',k=10,control=list(alpha=0.1))
#Look a the model result.
print(terms(tm_model.1, 10))
```

### Extracting Skills
Here, we answer our first research question: What skills are currently included in Trinity staff job descriptions? This question is answered by using predefined function `Match_skills` explained ealier in this document. 
```r
#Perform synonym mathing to the 35 skills
syn = read_csv('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Synonyms - Sheet1.csv')
#Perform skills match.
SkillsDictionary = Match_skills(syn, corpus)
#Export to excel
write_xlsx(SkillsDictionary, 
           '/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Deliverables:Results/Skills_Dict.xlsx')
#Terms that didnt march and its freq.
difference = setdiff(names(sort(rowSums(as.matrix(tdm1)), decreasing=TRUE)),
                     unique(c(t(SkillsDictionary))[!is.na(c(t(SkillsDictionary)))]))
diff = data.frame('terms'=names(sort(rowSums(as.matrix(tdm1)),decreasing=TRUE)[difference]), 
                  'freq'=as.vector(sort(rowSums(as.matrix(tdm1)),decreasing=TRUE)[difference]))
#write_xlsx(diff,'/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/difference_freq.xlsx')



#Create 35skills-jobcode frequency table using the Skills Dictionary.
SkillFrequency = data.frame(matrix(ncol = length(colnames(SkillsDictionary)) + 2, nrow = 0))
colnames(SkillFrequency) = c('JobCode','Department',colnames(SkillsDictionary))
for(doc_num in (1:length(corpus$content))){
  #Reassign variable because R...
  doc_num = doc_num
  SkillsFreq_vec = c()
  for(skill in colnames(SkillsDictionary)){
    #Reassign variable because R...
    skill = skill
    #Initialize term frequecy count
    SkillFreq = 0
    intersection = intersect(SkillsDictionary[skill][!is.na(SkillsDictionary[skill])], 
                             unlist(str_split(corpus[[doc_num]]$content[1],' ')))
    SkillsFreq_vec = append(SkillsFreq_vec, length(intersection))
  }
  
  SkillFrequency[nrow(SkillFrequency)+1, 3:length(colnames(SkillFrequency))] = SkillsFreq_vec
}
SkillFrequency$JobCode = data$JOBCODE
SkillFrequency$Department = data$DEPARTMENT

write_xlsx(SkillFrequency, 
           '/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Deliverables:Results/Skills_Frequency.xlsx')

```


```r
########### CLEANING ############################################################################################################################ 

######## Skills ########

# rename columns in skills
names(skills)[names(skills)=="O*NET-SOC Code"]="SOC Code"
names(skills)[names(skills)=="Title"]="Occupation"
names(skills)[names(skills)=="Element Name"]="Skill"

# remove irrelevant columns (Element ID, Scale ID, N, Lower CI Bound, Upper CI Bound, Date, Domain Source)
skills = skills[,!names(skills) %in% c("Element ID","Scale ID","Standard Error","N","Lower CI Bound","Upper CI Bound","Date","Domain Source")]

# using the information from O*Net, add a column with the categorized group for each skills
skills$Group = skills$Skill

### Basic Skills
skills$Group = ifelse((str_detect(skills$Group,'Active Learning') | str_detect(skills$Group,'Active Listening') | 
                          str_detect(skills$Group,'Critical Thinking') | str_detect(skills$Group,'Learning Strategies') | 
                          str_detect(skills$Group,'Mathematics') | str_detect(skills$Group,'Monitoring') | 
                          str_detect(skills$Group,'Reading Comprehension') | str_detect(skills$Group,'Science') | 
                          str_detect(skills$Group,'Speaking') | str_detect(skills$Group,'Writing')),'Basic', skills$Group)
### Social Skills
skills$Group = ifelse((str_detect(skills$Group,'Coordination') | str_detect(skills$Group,'Instructing') | 
                          str_detect(skills$Group,'Negotiation') | str_detect(skills$Group,'Persuasion') | 
                          str_detect(skills$Group,'Service Orientation') | str_detect(skills$Group,'Social Perceptiveness')),
                       'Social',skills$Group)
### Complex Problem Solving Skills
skills$Group = ifelse((str_detect(skills$Group,'Complex Problem Solving')),'Complex Problem Solving',skills$Group)
### Technical Skills
skills$Group = ifelse((str_detect(skills$Group,'Equipment Maintenance') | str_detect(skills$Group,'Equipment Selection') | 
                          str_detect(skills$Group,'Installation') | str_detect(skills$Group,'Operation and Control') | 
                          str_detect(skills$Group,'Operations Analysis') | str_detect(skills$Group,'Operations Monitoring') | 
                          str_detect(skills$Group,'Programming') | str_detect(skills$Group,'Quality Control Analysis') | 
                          str_detect(skills$Group,'Repairing') | str_detect(skills$Group,'Technology Design') | 
                          str_detect(skills$Group,'Troubleshooting')),'Technical',skills$Group)
### Systems Skills
skills$Group = ifelse((str_detect(skills$Group,'Judgment and Decision Making') | str_detect(skills$Group,'Systems Analysis') | 
                          str_detect(skills$Group,'Systems Evaluation')),'Systems',skills$Group)
### Resource Management Skills
skills$Group = ifelse((str_detect(skills$Group,'Management of Financial Resources') | 
                          str_detect(skills$Group,'Management of Material Resources') | 
                          str_detect(skills$Group,'Management of Personnel Resources') | 
                          str_detect(skills$Group,'Time Management')),'Resource Management',skills$Group)
### factor the group column
skills$Group = as.factor(skills$Group)


# create vectors containing the data values for Importance & Level respectively
ImportanceDV = skills%>%
  filter(`Scale Name`=="Importance")%>%
  transmute(ImportanceDV=`Data Value`)

LevelDV = skills%>%
  filter(`Scale Name`=="Level")%>%
  transmute(LevelDV=`Data Value`)

# delete 1 row for each skill in the dataframe
skills = skills[seq(0,nrow(skills),2),]

# delete the Scale Name & Data Value colummns
skills = skills[,!names(skills) %in% c("Scale Name","Data Value")]

# add in the new Importance Data Value & Level Data Value columns
skills = add_column(skills,ImportanceDV,.after="Skill")
skills = add_column(skills,LevelDV,.after="ImportanceDV")


######## Bright_Jobs ########
### rename level in Categories column
bright_jobs$Categories = ifelse(bright_jobs$Categories == 'Rapid Growth; Numerous Job Openings', 'Growth and Openings', bright_jobs$Categories)



######## Bright_Skills ########
#join bright_jobs & skills data frames to create a dataframe with information on only bright outlook jobs
bright_skills = inner_join(skills, bright_jobs, by = c("SOC Code","Occupation"))
# transform columns into correct data types
bright_skills$Occupation = factor(bright_skills$Occupation)
bright_skills$Skill = factor(bright_skills$Skill)
bright_skills$ImportanceDV = as.numeric(bright_skills$ImportanceDV)
bright_skills$LevelDV = as.numeric(bright_skills$LevelDV)
bright_skills$`Recommend Suppress` = factor(bright_skills$`Recommend Suppress`)
bright_skills$`Not Relevant` = factor(bright_skills$`Not Relevant`)
bright_skills$Occupation = factor(bright_skills$Occupation)
bright_skills$Categories = factor(bright_skills$Categories)
# create a threshold for Importance & Level
# Importance = 2.5
# Level = 3.5
bright_skills = bright_skills %>% filter(ImportanceDV>=2.5 & LevelDV>=3.5)


######## Trinity_Jobs ########
# remove irrelevant columns (Element ID, Scale ID, N, Lower CI Bound, Upper CI Bound, Date, Domain Source)
trinity_jobs = data[,!names(data) %in% c("CLASSIFICATION","REPORTSTO","PREPAREDDATE","OTHERREQUIREMENTS","SUPERVISORYRESPONSIBILITIES",
                                         "NUMBEROFDIRECTREPORTS","NUMBEROFINDIRECTREPORTS","SUPERVISIONRECEIVED","SECURITYSENSITIVE",
                                         "ATTENDANCESTANDARD","INTERNALCONTROLS","DECISIONMAKING","BUDGETRESPONSIBILITY","FINANCIALRESPONSIBILITY",
                                          'PHYSICALREQUIREMENTS')]
#fix column names
colnames(job_soc_codes)[which(names(job_soc_codes)=='Job Classification 2 (required:  IPEDS/SOC)')] = "SOC Code"
colnames(job_soc_codes)[which(names(job_soc_codes)=='Job Code')] = "JOBCODE"
#remove all other columns from job_soc_codes besides the Trinity Job Code & SOC Code columns
job_soc_codes = subset(job_soc_codes,select=c(JOBCODE, `SOC Code`)) 
#remove any jobs that don't have a corresponding SOC code (per TU HR's recommendation)
job_soc_codes = job_soc_codes %>% filter(is.na(`SOC Code`)==FALSE)
# remove the decimal values from JOBCODE
job_soc_codes$JOBCODE = substr(job_soc_codes$JOBCODE,1,nchar(job_soc_codes$JOBCODE)-2)
# join the trinity_jobs & job_soc_codes dataframes to include the corresponding SOC Code in the trinity_jobs dataframe
trinity_jobs = left_join(trinity_jobs,job_soc_codes,by="JOBCODE")
trinity_jobs = trinity_jobs %>% filter(is.na(`SOC Code`)==FALSE)
trinity_jobs = unique(trinity_jobs)
# filter for only trinity jobs that correspond to a bright outlook occupation
trinity_jobs = inner_join(trinity_jobs,bright_jobs,by="SOC Code")





####Creating Final Skill Frequency#####
#Update the value name so that they are the same when matched.
bright_skills$Skill=revalue(bright_skills$Skill,c("Judgment and Decision Making"="Judgement and Decision Making"))
#Udate column names.
names(bright_skills)[names(bright_skills)=="SOC Code"]="SOC.Code"
names(trinity_jobs)[names(trinity_jobs)=="JOBCODE"]="JobCode"

#Joined dataset from the skill frequency and the subset columns of the trinity jobs.
SkillsFreq_Prelim = unique(inner_join(SkillFrequency,subset(trinity_jobs,select=c("JobCode","SOC Code","POSITION")),by="JobCode"))
#Filter the Skill Frequency by no missing values.
SkillsFreq_Prelim%>%
  filter(is.na(`SOC Code`)==FALSE)

#Initlailze soc codes vector to loop.
soc_codes=as.vector(unique(trinity_jobs$`SOC Code`))
#Initialize empty dataset for frequency storage.
final=data.frame(matrix(ncol=39,nrow=0))
colnames(final)=colnames(SkillFrequency)
#For loop
for(soc in soc_codes){
  #Filter bright skills dataset for current soc code
  SOCSkills=bright_skills%>%
    dplyr::select(SOC.Code,Skill)%>%
    filter(SOC.Code==soc)
  #Filter preliminary skills frequency dataset for current soc code
  SOCSkillFreq=SkillsFreq_Prelim%>%
    filter(`SOC Code`==soc)
  #Get the difference between the column names of the preliminary skills frequency and the bright skills.
  diff=setdiff(colnames(SkillsFreq_Prelim),as.vector(SOCSkills$Skill))
  diff=diff[!diff %in% c("JobCode","POSITION","Department","SOC Code")]
  #If the data are in the difference columns, assign -1 to denote irrelevant skills for that soc code.
  SOCSkillFreq[,diff] = -1
  #combine into final dataset.
  final=rbind(final,SOCSkillFreq)
}
#Export final skill frequency dataset.
write_xlsx(final, 
           '/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Deliverables:Results/Skills_Frequency_Final.xlsx')


```
