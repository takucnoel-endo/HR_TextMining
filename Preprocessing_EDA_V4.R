#Install required package if not found.
if (!require("readxl")) install.packages("readxl")
if (!require("tm")) install.packages("tm")
if (!require("stringr")) install.packages("stringr")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("tidytext")) install.packages("tidytext")
if (!require("textstem")) install.packages("textstem")
if (!require("topicmodels")) install.packages("topicmodels")
if (!require("dplyr")) install.packages("dplyr")
#Load required libraries
library(readxl)#For reading excel sheet.
library(tm) #For building corpus and further preprocessing.
library(stringr) #For string manipulation. 
library(stringi) #For low level string opration and cleaning.
library(wordcloud) #For word cloud visualization
library(tidytext)
library(textstem)
library(topicmodels)
library(dplyr)

##############
###Function###
##############
standardize <- function(corp, lemmatize, ...){

  #Description: Apply basic standardization techniques to corpus.
  #Param: @corp - corpus (vollatile corpus)
  #       @lemmatize - Whether to apply lemmatization to words (TRUE/FALSE).
  #       @... - additional stopwords vector. 

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


count_freq <- function(tdmmatrix, order, n){
  
  #Description: Count word frequency and produce top n most/least frequent words in bar plot.
  #Param: @tdmmatrix - term-frequency matrix. must be in matrix form. 
  #       @order - descending or ascending ("desc"/"asc")
  #       @n - top n 
  
  #Create a term count table.
  term_freq <- rowSums(tdmmatrix)
  if(order == 'desc'){
    #Sort the terms into most frequent to least frequent
    term_freq <-sort(term_freq, decreasing=TRUE)
    #Barplot of the word frequency. n most frequent.
    par(mar=c(15,4,4,2))
    plot = barplot(term_freq[1:n], col='darkred',
                                       las=2,
                                       ylab='Frequency',
                                       main=paste('Word Frequency: Top', n),
                                       cex.lab   = 1)
  }
  if(order == 'asc'){
    #Sort the terms into most frequent to least frequent
    term_freq <-sort(term_freq, decreasing=FALSE)
    #Barplot of the word frequency. n least frequent.
    par(mar=c(15,4,4,2))
    plot = barplot(term_freq[1:n], col='darkred',
                                       las=2,
                                       ylab='Frequency',
                                       main=paste('Word Frequency: Top', n),
                                       cex.lab   = 1)
  }
  return(term_freq)
  return(plot)
}


#Tokenizers
#Bigram Tokenizer.
Tokenizer2 <- function(x)unlist(lapply(ngrams(words(x), 2),
                                             paste, 
                                             collapse = ' '), 
                                      use.names = FALSE)
#Trigram Tokenizer
Tokenizer3 <- function(x)unlist(lapply(ngrams(words(x), 3),
                                             paste, 
                                             collapse = ' '), 
                                      use.names = FALSE)
#Combination Tokenizer.
Tokenizer1to3 <- function(x)unlist(lapply(ngrams(words(x), 1:3),
                                                paste, 
                                                collapse = ' '), 
                                         use.names = FALSE)


##################
###Main Program###
##################

#Read data into R session.
data <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Parsed_data.xlsx')

#Assign preliminary ID to document rows
data$doc_id <- seq(nrow(data))

#Rename summary columns name.
#Use raw string.
colnames(data)[which(names(data) ==
                       r"{\T\TSUMMARY}")] <- "SUMMARY"


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
              'EQUIPMENT','BUDGETRESPONSIBILITY','FINANCIALRESPONSIBILITY','PHYSICALREQUIREMENTS')
data$text <- paste0(data$SUMMARY,data$JOBDUTIES)
data$text <- paste0(data$text,data$ADDITIONALDUTIES)
data$text <- paste0(data$text,data$EDUCATION)
data$text <- paste0(data$text,data$EXPERIENCE)
data$text <- paste0(data$text,data$INTERACTION)
data$text <- paste0(data$text,data$COMPUTERSOFTWARE)
data$text <- paste0(data$text,data$EQUIPMENT)
data$text <- paste0(data$text,data$BUDGETRESPONSIBILITY)
data$text <- paste0(data$text,data$FINANCIALRESPONSIBILITY)
data$text <- paste0(data$text,data$PHYSICALREQUIREMENTS)
#Get rid of text specific columns
data <- data[, !(colnames(data) %in% join_vec)]

#Clean any formatting string with raw string expression.
data$text<-gsub(r"{\xe2\x80\x99s}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\\xe2\\x80\\x99s}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x93}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\t}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x9}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\n}", "", data$text,fixed = TRUE)
data$text<-gsub('Essential duties, as defined under the Americans with Disabilities Act, may include any of the following representative duties, knowledge, and skills.  This is not a comprehensive listing of all functions and duties performed by incumbents of this class; employees may be assigned duties which are not listed below; reasonable accommodations may be made as required.  Requirements are representative of minimum levels of knowledge, skills, and/or abilities.  The job description does not constitute an employment agreement and is subject to change at any time by the employer.  Essential duties and responsibilities may include, but are not limited to, the following:', "", data$text,fixed = TRUE)
data$DEPARTMENT<-gsub(r"{\\xe2\\x80\\x99s}", "s", data$DEPARTMENT,fixed = TRUE)

#In R, you can specify that a data text is a corpus type, so tm package can recognize it.
#Change the prepared data to corpus, for further preprocessing (Stop words, stemming ... etc)
#Crete a DataFrame Source from the data.
data_source <- DataframeSource(data)
#Convert the source to volatile corpus
corpus <- VCorpus(data_source)


#Standardization
#Define additional stopwords to use as one of arguments for the standardization function.
stop_w <- c('trinity','universitys','university','duties',
            'responsibilities','may','years','required',
            'include','following','essential','accredited','andor',
            'preferred','including','degree','requirements','functions',
            'knowledge', 'ability', 'job','description','duty',
            'work','student','provide','x','department','programming',
            'program','assist','faculty','staff','policy','accordance',
            'conduct','supervisory','responsibility','employee',
            'applicable','iii')
#Use the program defined function to standardize.
corpus <- standardize(corpus, lemmatize=TRUE, stop_w)



data %>%
  filter(str_detect(text, ))


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



#Combine all n-grams.
#Build tokenizer function
#Tokenizes into both unigram, and trigram.
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm1.3 <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
print(dtm1.3 <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm1.3))
print(corpus_unitotrifreq <- count_freq(as.matrix(tdm1.3), 'desc', 20))





#Look at the frequency of top 10 skills.
#Programming lanugages. 
#Some of the most popular programming language.
pl_vec <- c('python','r','sql','javascript','php','c','scala','ruby','perl','swift')
for(pl in pl_vec){
  print(paste(pl,paste(':',corpus_unitotrifreq[pl][[1]])))
}
#Technical skills
tech_vec <- c('database','machine learning','salesforce','finance','engineer',
              'software development','cyber security',
              'information security','web design')
for(tech in tech_vec){
  print(paste(tech,paste(':',corpus_unitotrifreq[tech][[1]])))
}
#Professional Skills
prof_vec <- c('communication','teamwork','problem solve','leadership',
              'organization','confidence','management','negotiation',
              'critical think','innovation')
for(prof in prof_vec){
  print(paste(prof,paste(':',corpus_unitotrifreq[prof][[1]])))
}





#Implement a Topic Model with Latent Dirichlet Allocation.
set.seed(100)
#Unigram
tm_model.1 <- LDA(dtm1,method='Gibbs',k=35,control=list(alpha=0.1))
#Look a the model result.
terms(tm_model.1, 10)
#Bigram
tm_model.2 <- LDA(dtm2,method='Gibbs',k=10,control=list(alpha=0.1))
#Look a the model result.
terms(tm_model.2, 5)
#Trigram
tm_model.3 <- LDA(dtm3,method='Gibbs',k=10,control=list(alpha=0.1))
#Look a the model result.
terms(tm_model.3, 5)


