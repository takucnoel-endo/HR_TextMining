#Install required package if not found.
if (!require("readxl")) install.packages("readxl")
if (!require("tm")) install.packages("tm")
if (!require("stringr")) install.packages("stringr")
if (!require("tidyverse")) install.packages("tidyverse")
#Load required libraries
library(readxl)#For reading excel sheet.
library(tm)
library(stringr)
library(dplyr)


#Read data into R session.
data <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Parse_data.xlsx')
bright_jobs <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/All_Bright_Outlook_Occupations.xlsx',
                          col_names=c("SOC Code","Occupation","Categories"), skip = 4)
job_soc_codes <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/a.Job Codes Titles and SOC Codes.xlsx')
skills <- read_excel('/Users/takucnoelendo/Documents/SP 2022/Consulting/HR Project/Data/Skills.xlsx')

#################
###Skills Data###
#################
# rename columns in skills
names(skills)[names(skills)=="O*NET-SOC Code"]<-"SOC Code"
names(skills)[names(skills)=="Title"]<-"Occupation"
names(skills)[names(skills)=="Element Name"]<-"Skill"
# remove irrelevant columns (Element ID, Scale ID, N, Lower CI Bound, Upper CI Bound, Date, Domain Source)
skills <- skills[,!names(skills) %in% c("Element ID","Scale ID","N","Lower CI Bound","Upper CI Bound","Date","Domain Source")]

# using the information from O*Net, add a column with the categorized group for each skills
skills$Group <- skills$Skill
### basic skills
skills$Group <- ifelse((str_detect(skills$Group,'Active Learning') | str_detect(skills$Group,'Active Listening') | 
                          str_detect(skills$Group,'Critical Thinking') | str_detect(skills$Group,'Learning Strategies') | 
                          str_detect(skills$Group,'Mathematics') | str_detect(skills$Group,'Monitoring') | 
                          str_detect(skills$Group,'Reading Comprehension') | str_detect(skills$Group,'Science') | 
                          str_detect(skills$Group,'Speaking') | str_detect(skills$Group,'Writing')),'Basic', skills$Group)
### social skills
skills$Group <- ifelse((str_detect(skills$Group,'Coordination') | str_detect(skills$Group,'Instructing') | 
                          str_detect(skills$Group,'Negotiation') | str_detect(skills$Group,'Persuasion') | 
                          str_detect(skills$Group,'Service Orientation') | str_detect(skills$Group,'Social Perceptiveness')),
                       'Social',skills$Group)
### complex problem solving skills
skills$Group <- ifelse((str_detect(skills$Group,'Complex Problem Solving')),'Complex Problem Solving',skills$Group)
### Technical Skills
skills$Group <- ifelse((str_detect(skills$Group,'Equipment Maintenance') | str_detect(skills$Group,'Equipment Selection') | 
                          str_detect(skills$Group,'Installation') | str_detect(skills$Group,'Operation and Control') | 
                          str_detect(skills$Group,'Operations Analysis') | str_detect(skills$Group,'Operations Monitoring') | 
                          str_detect(skills$Group,'Programming') | str_detect(skills$Group,'Quality Control Analysis') | 
                          str_detect(skills$Group,'Repairing') | str_detect(skills$Group,'Technology Design') | 
                          str_detect(skills$Group,'Troubleshooting')),'Technical',skills$Group)
### systems skills
skills$Group <- ifelse((str_detect(skills$Group,'Judgment and Decision Making') | str_detect(skills$Group,'Systems Analysis') | 
                          str_detect(skills$Group,'Systems Evaluation')),'Systems',skills$Group)
### resource management skills
skills$Group <- ifelse((str_detect(skills$Group,'Management of Financial Resources') | 
                          str_detect(skills$Group,'Management of Material Resources') | 
                          str_detect(skills$Group,'Management of Personnel Resources') | 
                          str_detect(skills$Group,'Time Management')),'Resource Management',skills$Group)
# factor the group column
skills$Group <- as.factor(skills$Group)



###################
####Bright_Jobs####
###################
table(bright_jobs$Categories)
### rename levels in Categories column
bright_jobs$Categories <- ifelse(bright_jobs$Categories == 'Rapid Growth; Numerous Job Openings', 'Growth and Openings', bright_jobs$Categories)
#### Bright_Skills ####
#join bright_jobs & skills data frames to create a dataframe with information on only bright outlook jobs
bright_skills <- inner_join(skills, bright_jobs, by = c("SOC Code","Occupation"))
# transform columns into correct data types
bright_skills$Occupation <- factor(bright_skills$Occupation)
bright_skills$Skill <- factor(bright_skills$Skill)
bright_skills$`Scale Name` <- factor(bright_skills$`Scale Name`)
bright_skills$`Data Value` <- as.numeric(bright_skills$`Data Value`)
bright_skills$`Standard Error` <- as.numeric(bright_skills$`Standard Error`)
bright_skills$`Recommend Suppress` <- factor(bright_skills$`Recommend Suppress`)
bright_skills$`Not Relevant` <- factor(bright_skills$`Not Relevant`)
bright_skills$Occupation <- factor(bright_skills$Occupation)
bright_skills$Categories <- factor(bright_skills$Categories)


############
###Corpus###
############
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

for cols in join_vec

data$Text <-  str_c(data[, 'SUMMARY'], '', data[,'JOBDUTIES'])


data$Text



