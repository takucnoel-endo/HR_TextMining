
################################################################################################################################################# 
##################################################################### TU HR #####################################################################
################################################################################################################################################# 

#library essential packages
library(readxl)
library(dplyr)
library(tidyverse)
library(tibble)
library(epiDisplay)

# read in all relevant files
skills <- read_excel("Skills.xlsx")
bright_jobs <- read_excel("All_Bright_Outlook_Occupations.xls", col_names=c("SOC Code","Occupation","Categories"), skip=4)
job_soc_codes <- read_excel("a.Job Codes Titles and SOC Codes.xlsx")
trinity_jobs <- read_excel("Parse_data.xlsx")


########### CLEANING ############################################################################################################################ 

######## Skills ########

# rename columns in skills
names(skills)[names(skills)=="O*NET-SOC Code"]<-"SOC Code"
names(skills)[names(skills)=="Title"]<-"Occupation"
names(skills)[names(skills)=="Element Name"]<-"Skill"

# remove irrelevant columns (Element ID, Scale ID, N, Lower CI Bound, Upper CI Bound, Date, Domain Source)
skills <- skills[,!names(skills) %in% c("Element ID","Scale ID","Standard Error","N","Lower CI Bound","Upper CI Bound","Date","Domain Source")]

# using the information from O*Net, add a column with the categorized group for each skills
skills$Group <- skills$Skill

### Basic Skills
skills$Group <- ifelse((str_detect(skills$Group,'Active Learning') | str_detect(skills$Group,'Active Listening') | 
                          str_detect(skills$Group,'Critical Thinking') | str_detect(skills$Group,'Learning Strategies') | 
                          str_detect(skills$Group,'Mathematics') | str_detect(skills$Group,'Monitoring') | 
                          str_detect(skills$Group,'Reading Comprehension') | str_detect(skills$Group,'Science') | 
                          str_detect(skills$Group,'Speaking') | str_detect(skills$Group,'Writing')),'Basic', skills$Group)
### Social Skills
skills$Group <- ifelse((str_detect(skills$Group,'Coordination') | str_detect(skills$Group,'Instructing') | 
                          str_detect(skills$Group,'Negotiation') | str_detect(skills$Group,'Persuasion') | 
                          str_detect(skills$Group,'Service Orientation') | str_detect(skills$Group,'Social Perceptiveness')),
                       'Social',skills$Group)
### Complex Problem Solving Skills
skills$Group <- ifelse((str_detect(skills$Group,'Complex Problem Solving')),'Complex Problem Solving',skills$Group)
### Technical Skills
skills$Group <- ifelse((str_detect(skills$Group,'Equipment Maintenance') | str_detect(skills$Group,'Equipment Selection') | 
                          str_detect(skills$Group,'Installation') | str_detect(skills$Group,'Operation and Control') | 
                          str_detect(skills$Group,'Operations Analysis') | str_detect(skills$Group,'Operations Monitoring') | 
                          str_detect(skills$Group,'Programming') | str_detect(skills$Group,'Quality Control Analysis') | 
                          str_detect(skills$Group,'Repairing') | str_detect(skills$Group,'Technology Design') | 
                          str_detect(skills$Group,'Troubleshooting')),'Technical',skills$Group)
### Systems Skills
skills$Group <- ifelse((str_detect(skills$Group,'Judgment and Decision Making') | str_detect(skills$Group,'Systems Analysis') | 
                          str_detect(skills$Group,'Systems Evaluation')),'Systems',skills$Group)
### Resource Management Skills
skills$Group <- ifelse((str_detect(skills$Group,'Management of Financial Resources') | 
                          str_detect(skills$Group,'Management of Material Resources') | 
                          str_detect(skills$Group,'Management of Personnel Resources') | 
                          str_detect(skills$Group,'Time Management')),'Resource Management',skills$Group)
### factor the group column
skills$Group <- as.factor(skills$Group)


# create vectors containing the data values for Importance & Level respectively
ImportanceDV <- skills%>%
  filter(`Scale Name`=="Importance")%>%
  transmute(ImportanceDV=`Data Value`)

LevelDV <- skills%>%
  filter(`Scale Name`=="Level")%>%
  transmute(LevelDV=`Data Value`)

# delete 1 row for each skill in the dataframe
skills <- skills[seq(0,nrow(skills),2),]

# delete the Scale Name & Data Value colummns
skills <- skills[,!names(skills) %in% c("Scale Name","Data Value")]

# add in the new Importance Data Value & Level Data Value columns
skills <- add_column(skills,ImportanceDV,.after="Skill")
skills <- add_column(skills,LevelDV,.after="ImportanceDV")

# check for NAs
colSums(is.na(skills))
# no NAs

######## Bright_Jobs ########

table(bright_jobs$Categories)

### rename levels in Categories column
bright_jobs$Categories <- ifelse(bright_jobs$Categories == 'Rapid Growth; Numerous Job Openings', 'Growth and Openings', bright_jobs$Categories)

# check for NAs
colSums(is.na(bright_jobs))
# no NAs


######## Bright_Skills ########

#join bright_jobs & skills data frames to create a dataframe with information on only bright outlook jobs
bright_skills <- inner_join(skills, bright_jobs, by = c("SOC Code","Occupation"))

# transform columns into correct data types
bright_skills$Occupation <- factor(bright_skills$Occupation)
bright_skills$Skill <- factor(bright_skills$Skill)
bright_skills$ImportanceDV <- as.numeric(bright_skills$ImportanceDV)
bright_skills$LevelDV <- as.numeric(bright_skills$LevelDV)
bright_skills$`Recommend Suppress` <- factor(bright_skills$`Recommend Suppress`)
bright_skills$`Not Relevant` <- factor(bright_skills$`Not Relevant`)
bright_skills$Occupation <- factor(bright_skills$Occupation)
bright_skills$Categories <- factor(bright_skills$Categories)

# check for NAs
colSums(is.na(bright_skills))
#no NAs


######## Trinity_Jobs ########

# remove irrelevant columns (Element ID, Scale ID, N, Lower CI Bound, Upper CI Bound, Date, Domain Source)
trinity_jobs <- trinity_jobs[,!names(trinity_jobs) %in% c("CLASSIFICATION","REPORTSTO","PREPAREDDATE","OTHERREQUIREMENTS","SUPERVISORYRESPONSIBILITIES",
                                                          "NUMBEROFDIRECTREPORTS","NUMBEROFINDIRECTREPORTS","SUPERVISIONRECEIVED","SECURITYSENSITIVE",
                                                          "ATTENDANCESTANDARD","INTERNALCONTROLS","DECISIONMAKING","BUDGETRESPONSIBILITY","FINANCIALRESPONSIBILITY",
                                                          'PHYSICALREQUIREMENTS')]
# fix column names
colnames(trinity_jobs)[which(names(trinity_jobs)==r"{\T\TSUMMARY}")] <- "SUMMARY"



# remove all other columns from job_soc_codes besides the Trinity Job Code & SOC Code columns
job_soc_codes <- subset(job_soc_codes,select=c(`Job Code`,`Job Classification 2 (required:  IPEDS/SOC)`)) 

# rename the columns to better identify their data & to match their name to the corresponding column in the trinity_jobs dataframe
names(job_soc_codes) <- c("JOBCODE","SOC Code")

# remove any jobs that don't have a corresponding SOC code (per TU HR's recommendation)
#job_soc_codes <- job_soc_codes%>%
#  filter(is.na(`SOC Code`)==FALSE)

# join the trinity_jobs & job_soc_codes dataframes to include the corresponding SOC Code in the trinity_jobs dataframe
trinity_jobs <- left_join(trinity_jobs,job_soc_codes,by="JOBCODE")

trinity_jobs%>%
  filter(is.na(`SOC Code`)==TRUE)
job_soc_codes%>%
  filter(JOBCODE==40)

colSums(is.na(trinity_jobs))
# ^^^^^^ THIS VERSION OF THE DATA IS FOR THE ONET PART OF THE PROJECT. NOT THE SKILLS DICTIONARY



trinity_jobs$POSITION<-gsub(r"{\xe2\x80\x99s}", "s", trinity_jobs$POSITION,fixed = TRUE)
trinity_jobs$POSITION<-gsub(r"{\xe2\x80\x93}", "s", trinity_jobs$POSITION,fixed = TRUE)
trinity_jobs$INTERACTION<-gsub(r"{\xe2\x80\x93}", "s", trinity_jobs$INTERACTION,fixed = TRUE)
trinity_jobs$REPORTSTO<-gsub(r"{\xe2\x80\x99s}", "s", trinity_jobs$REPORTSTO,fixed = TRUE)
trinity_jobs$POSITION<-gsub(r"{\xe2\x80\x99s}", "s", trinity_jobs$POSITION,fixed = TRUE)
trinity_jobs$SUMMARY<-gsub(r"{\xe2\x80\x99s}", "s", trinity_jobs$SUMMARY,fixed = TRUE)
trinity_jobs$SUMMARY<-gsub(r"{\t}", "", trinity_jobs$SUMMARY,fixed = TRUE)
trinity_jobs$ADDITIONALDUTIES<-gsub(r"{\xe2\x80\x99}", "", trinity_jobs$ADDITIONALDUTIES,fixed = TRUE)
trinity_jobs$ADDITIONALDUTIES<-gsub(r"{\xe2\x80\x9}", "", trinity_jobs$ADDITIONALDUTIES,fixed = TRUE)
trinity_jobs$EDUCATION<-gsub(r"{\xe2\x80\x99}", "", trinity_jobs$EDUCATION,fixed = TRUE)
trinity_jobs$EDUCATION<-gsub(r"{\xe2\x80\x99}", "", trinity_jobs$EDUCATION,fixed = TRUE)
trinity_jobs$EXPERIENCE<-gsub(r"{\xe2\x80\x99}", "", trinity_jobs$EXPERIENCE,fixed = TRUE)
trinity_jobs$INTERACTION<-gsub(r"{\xe2\x80\x99}", "", trinity_jobs$INTERACTION,fixed = TRUE)
trinity_jobs$NUMBEROFDIRECTREPORTS<-gsub(r"{\xe2\x80\x93}", "-", trinity_jobs$NUMBEROFDIRECTREPORTS,fixed = TRUE)
trinity_jobs$PHYSICALREQUIREMENTS<-gsub(r"{\t}", "", trinity_jobs$PHYSICALREQUIREMENTS,fixed = TRUE)
trinity_jobs$EQUIPMENT<-gsub(r"{\n}", "", trinity_jobs$EQUIPMENT,fixed = TRUE)


######## Bright_Trinity ########
# join trinity_jobs & bright_jobs dataframes to create a dataframe with information on Trinity occupations that correlate to bright outlook jobs
#bright_trinity <- inner_join(triniyu,bright_jobs,by=c("SOC Code"))

#remove the duplicate Occupation column & rename the remaining one
#bright_trinity <- bright_trinity[,!(names(bright_trinity) %in% c("Occupation.y"))]
#names(bright_trinity)[names(bright_trinity)=="Occupation.x"]<-"Occupation"

# transform columns into correct data types
#bright_trinity$Occupation <- factor(bright_trinity$Occupation)
#bright_trinity$Skill <- factor(bright_trinity$Skill)
#bright_trinity$`Scale Name` <- factor(bright_trinity$`Scale Name`)
#bright_trinity$`Data Value` <- as.numeric(bright_trinity$`Data Value`)
#bright_trinity$`Standard Error` <- as.numeric(bright_trinity$`Standard Error`)
#bright_trinity$`Recommend Suppress` <- factor(bright_trinity$`Recommend Suppress`)
#bright_trinity$`Not Relevant` <- factor(bright_trinity$`Not Relevant`)
#bright_trinity$Group <- factor(bright_trinity$Group)
#bright_trinity$Categories <- factor(bright_trinity$Categories)


########### DESCRIPTIVE STATISTICS ############################################################################################################################ 

######## Skills ########

#### Importance & Level Data Value ####
# each occupation contains 2 rows for each skillseach representing the scale name Importance or Level & each with a corresponding data value
## Importance: 1-5 scale (Not Important - Extremely Important)
# the degree of importance the skill is to the occupation
## Level: 0-7 scale
# the degree to which the skills is required or needed to perform the occupation

# we have chosen to qualify skills as bright outlook only if they contain an Importance & Level value of >3

### Importance ###
importance <- bright_skills %>%
  filter((`Scale Name`=='Importance' & `Data Value`>3)) %>%
  select(Occupation,Skill,Group,`Data Value`) %>%
  group_by(Occupation)

# importance skill 
importance_skill <- importance %>%
  select(Skill, Occupation) %>%
  group_by(Skill) %>%
  summarize(n=n()) %>%
  mutate(frequency=round((n/sum(n)*100),2)) %>%
  arrange(desc(frequency))

# importance group   
importance_group <- importance %>%
  group_by(Group) %>%
  summarize(n=n()) %>%
  mutate(frequency=round((n/sum(n)*100),2)) %>%
  arrange(desc(frequency))

### Level ###
level <- bright_skills %>%
  filter((`Scale Name`=='Level' & `Data Value`>3)) %>%
  select(Occupation,Skill,Group,`Data Value`) %>%
  group_by(Occupation)

# level skill 
level_skill <- level %>%
  select(Skill, Occupation) %>%
  group_by(Skill) %>%
  summarize(n=n()) %>%
  mutate(frequency=round((n/sum(n)*100),2)) %>%
  arrange(desc(frequency))

# level group   
level_group <- level %>%
  group_by(Group) %>%
  summarize(n=n()) %>%
  mutate(frequency=round((n/sum(n)*100),2)) %>%
  arrange(desc(frequency))


#### Occupation ####
table(skills$Occupation)
#every occupation is listed once so this isnt really useful information
#maybe we can just list out all the jobs in a paragraph? idk

#### Skill ####
table(skills$Skill)

#### Recommend Suppress ####
table(skills$`Recommend Suppress`)

#### Not Relevant ####
table(skills$`Not Relevant`)

######## Bright_Jobs ########

#### Occupation ####

table(bright_jobs$Occupation)
#every occupation is listed once so this isnt really useful information
#maybe we can just list out all the jobs in a paragraph? idk

#### Categories ####
table(bright_jobs$Categories)

# CODE CITATION: https://www.programmingr.com/statistics/frequency-table/
tab1(bright_jobs$Categories,sort.group="decreasing",cum.percent=TRUE)


######## Trinity_Jobs ########
#### Position ####
table(trinity_jobs$POSITION)


#### Department ####
table(trinity_jobs$DEPARTMENT)


# CODE CITATION: https://www.programmingr.com/statistics/frequency-table/
tab1(trinity_jobs$DEPARTMENT,sort.group="decreasing",cum.percent=TRUE)


#### Pay Grade ####
table(trinity_jobs$PAYGRADE)

# CODE CITATION: https://www.programmingr.com/statistics/frequency-table/
tab1(trinity_jobs$PAYGRADE,sort.group="decreasing",cum.percent=TRUE)



#### Job Family ####
table(trinity_jobs$JOBFAMILY)

# CODE CITATION: https://www.programmingr.com/statistics/frequency-table/
tab1(trinity_jobs$JOBFAMILY,sort.group="decreasing",cum.percent=TRUE)




#### ####








