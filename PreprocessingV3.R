#Install required package if not found.
if (!require("readxl")) install.packages("readxl")
if (!require("tm")) install.packages("tm")
if (!require("stringr")) install.packages("stringr")
if (!require("tidyverse")) install.packages("tidyverse")
#Load required libraries
library(readxl)#For reading excel sheet.
library(tm) #For building corpus and further preprocessing.
library(stringr) #For string manipulation. 
library(stringi) #For low level string opration and cleaning.
library(wordcloud) #For word cloud visualization


##############
###Function###
##############
standardize <- function(corp, stpw = c()){
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
  corp <- tm_map(corp, removeWords, words=c(stopwords('english'), stpw))
  return(corp)
}

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

#Subset jobs with missing jobcode
data <- data[!is.na(data$JOBCODE),]

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

#Assign document id to updated data set.
data$doc_id <- seq(nrow(data))

#In R, you can specify that a data text is a corpus type, so tm package can recognize it.
#Change the prepared data to corpus, for further preprocessing (Stop words, stemming ... etc)

#Crete a DataFrame Source from the data.
data_source <- DataframeSource(data)
#Convert the source to volatile corpus
corpus <- VCorpus(data_source)


#Standardization
#Define additional stopwords to use as one of arguments for the standardization function.
stop_w <- c('trinity','universitys','university','duties','experience','student',
            'responsibilities','knowledge','may','years','employees','skills','required',
            'include','work','abilities','following','essential')
#Use the program defined function to standardize.
corpus <- standardize(corpus, stop_w)



#Exploration
#Create Term-Document_Matrix and Document-Term-Matrix
print(tdm <- TermDocumentMatrix(corpus))
print(dtm <- DocumentTermMatrix(corpus))
#Convert to matrix form.
tdm_m <- as.matrix(tdm)
dtm_m <- as.matrix(dtm)
dtm_m[1:35, c('job','excel','docs')]
#Create a term count table.
term_freq <- rowSums(tdm_m)
#Sort the terms into most frequent to least frequent
print(term_freq_desc <-sort(term_freq, decreasing=TRUE))
#Barplot of the word frequency. 10 most frequent.
barplot(term_freq_desc[1:10], col='tan', las=2)
#Create a word cloud using term frequecy
wordcloud(names(term_freq), term_freq, 
          max.words = 100, colors = c("grey80", "orange", "green"))



