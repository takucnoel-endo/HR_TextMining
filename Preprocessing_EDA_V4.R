#Install required package if not found.
if (!require("readxl")) install.packages("readxl")
if (!require("tm")) install.packages("tm")
if (!require("stringr")) install.packages("stringr")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("tidytext")) install.packages("tidytext")
if (!require("textstem")) install.packages("textstem")
#Load required libraries
library(readxl)#For reading excel sheet.
library(tm) #For building corpus and further preprocessing.
library(stringr) #For string manipulation. 
library(stringi) #For low level string opration and cleaning.
library(wordcloud) #For word cloud visualization
library(tidytext)
library(textstem)


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
  
  #Additional standerdization
  #Stop words
  corp <- tm_map(corp, removeWords, words=c(stopwords('english'), ...))
  #If word lemmatization option is TRUE.
  if(lemmatize==TRUE){
    #Lemmatize
    corp <- tm_map(corp, lemmatize_strings)
    corp <-tm_map(corp, PlainTextDocument)
  }
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
data <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Parse_data.xlsx')

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
                "ATTENDANCESTANDARD","INTERNALCONTROLS","DECISIONMAKING")
data <- data[, !(colnames(data) %in% subset_vec)]


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

#Clean any string formatting string with raw string expression.
data$text<-gsub(r"{\xe2\x80\x99s}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x93}", "s", data$text,fixed = TRUE)
data$text<-gsub(r"{\t}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\xe2\x80\x9}", "", data$text,fixed = TRUE)
data$text<-gsub(r"{\n}", "", data$text,fixed = TRUE)

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
            'preferred','including','degree','requirements','functions')
#Use the program defined function to standardize.
corpus <- standardize(corpus, lemmatize=TRUE, stop_w)




#Exploration
#Unigram
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm <- TermDocumentMatrix(corpus))
print(dtm <- DocumentTermMatrix(corpus))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm))
#Count for the whole corpus the frequency of the word.
#Use the program defined function to sort and output list as well as n most/least frequent words. 
count_freq(as.matrix(tdm), 'desc', 20)

#Bigram
#Build tokenizer function
#Tokenizes into bigram
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer2)))
print(dtm <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer2)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm))
#Count for the whole corpus the frequency of the trigram.
#Use the program defined function to sort and output list as well as n most/least frequent trigram. 
count_freq(as.matrix(tdm), 'desc', 20)


#Trigram
#Build tokenizer function
#Tokenizes into trigram.
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer3)))
print(dtm <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer3)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm))
#Count for the whole corpus the frequency of the trigram.
#Use the program defined function to sort and output list as well as n most/least frequent trigram. 
count_freq(as.matrix(tdm), 'desc', 20)

#Combine all n-grams.
#Build tokenizer function
#Tokenizes into both unigram, and trigram.
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm <- TermDocumentMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
print(dtm <- DocumentTermMatrix(corpus, control=list(tokenize = Tokenizer1to3)))
#Count FOR EACH DOCUMENT the frequency of word.
print(dtfreq <- tidy(dtm))








