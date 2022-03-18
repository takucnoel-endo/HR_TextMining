library(readxl)#For reading excel sheet.
library(tm)
library(stringr)

#Read data into memory
data_raw<- read_excel('C:\\Users\\taku0\\OneDrive\\Documents\\
                      SP 2022\\Consulting\\Files\\Data\\Parse_data.xlsx')

#Make a copy of the data.
data <- data_raw

#Rename summary columns name.
#Use raw string.
colnames(data)[which(names(data) ==
                       r"{\T\TSUMMARY}")] <- "SUMMARY"

#Remove unnesessary features from the dataset.
subset_vec <- c('JOBFAMILY','NUMBEROFDIRECTREPORTS','NUMBEROFINDIRECTREPORTS')
data <- data[, !(colnames(data) %in% subset_vec)]

#For this data, the only features that needs to be kept separate from other columns are ...
#(Position, Department, Jobcode, Paygrade, Prepared Date)
data$Text <-  str_c(data$SUMMARY, '', data$JOBDUTIES)

