##### Data Cleaning 2

## install packages
pacman::p_load(tidyverse, lubridate)
# install.packages('DataExplorer')
# install.packages('corrplot')
# install.packages('corrr')
# install.packages('zoo')

## load libraries
library(DataExplorer)
library(corrplot)
library(corrr)
library(zoo)

## set working directory
getwd()
setwd('NUS-ISS/Project')
getwd()

## load data
train3 <- readRDS('train2.Rds')
test3 <- readRDS('test2.Rds')

### 1. Derived columns: DAYS_*

# the columns DAYS_BIRTH, DAYS_EMPLOYED, DAYS_REGISTRATION, DAYS_ID_PUBLISH, DAYS_LAST_PHONE_CHANGE are in -days

# **** train3 data frame ****

# a. DAYS_BIRTH --> CLIENT_AGE
# change name to CLIENT_AGE
colnames(train3)[which(names(train3) == 'DAYS_BIRTH')] <- 'CLIENT_AGE'
colnames(train3) # successful. it is now CLIENT_AGE (col no. 18)
# modify values: /-365
train3$CLIENT_AGE <- train3$CLIENT_AGE / -365
head(train3$CLIENT_AGE) # successful

# b. DAYS_EMPLOYED --> YEARS_EMPLOYED
# change name to YEARS_EMPLOYED
colnames(train3)[which(names(train3) == 'DAYS_EMPLOYED')] <- 'YEARS_EMPLOYED'
colnames(train3) # successful. it is now YEARS_EMPLOYED (col no. 19)
# modify values: /-365
train3$YEARS_EMPLOYED <- train3$YEARS_EMPLOYED / -365
head(train3$YEARS_EMPLOYED) # successful

# c. DAYS_REGISTRATION --> YEARS_REGISTRATION
# change name
colnames(train3)[which(names(train3) == 'DAYS_REGISTRATION')] <- 'YEARS_REGISTRATION'
colnames(train3)[20]
# modify values: /-365
train3$YEARS_REGISTRATION <- train3$YEARS_REGISTRATION / -365
head(train3$YEARS_REGISTRATION) # successful

# d. DAYS_ID_PUBLISH --> YEARS_ID_PUBLISH
# change name
colnames(train3)[which(names(train3) == 'DAYS_ID_PUBLISH')] <- 'YEARS_ID_PUBLISH'
colnames(train3)[21]
# modify values: /-365
train3$YEARS_ID_PUBLISH <- train3$YEARS_ID_PUBLISH / -365
head(train3$YEARS_ID_PUBLISH) # successful

# e. DAYS_LAST_PHONE_CHANGE --> YEARS_LAST_PHONE_CHANGE
# change name
colnames(train3)[which(names(train3) == 'DAYS_LAST_PHONE_CHANGE')] <- 'YEARS_LAST_PHONE_CHANGE'
# modify values: /-365
train3$YEARS_LAST_PHONE_CHANGE <- train3$YEARS_LAST_PHONE_CHANGE / -365
head(train3$YEARS_LAST_PHONE_CHANGE) # successful

# **** test3 data frame ****

# a. DAYS_BIRTH --> CLIENT_AGE
# change name to CLIENT_AGE
colnames(test3)[which(names(test3) == 'DAYS_BIRTH')] <- 'CLIENT_AGE'
colnames(test3) # successful. it is now CLIENT_AGE (col no. 17)
# modify values: /-365
test3$CLIENT_AGE <- test3$CLIENT_AGE / -365
head(test3$CLIENT_AGE) # successful

# b. DAYS_EMPLOYED --> YEARS_EMPLOYED
# change name to YEARS_EMPLOYED
colnames(test3)[which(names(test3) == 'DAYS_EMPLOYED')] <- 'YEARS_EMPLOYED'
colnames(test3) # successful. it is now YEARS_EMPLOYED (col no. 18)
# modify values: /-365
test3$YEARS_EMPLOYED <- test3$YEARS_EMPLOYED / -365
head(test3$YEARS_EMPLOYED) # successful

# c. DAYS_REGISTRATION --> YEARS_REGISTRATION
# change name
colnames(test3)[which(names(test3) == 'DAYS_REGISTRATION')] <- 'YEARS_REGISTRATION'
colnames(test3)[19]
# modify values: /-365
test3$YEARS_REGISTRATION <- test3$YEARS_REGISTRATION / -365
head(test3$YEARS_REGISTRATION) # successful

# d. DAYS_ID_PUBLISH --> YEARS_ID_PUBLISH
# change name
colnames(test3)[which(names(test3) == 'DAYS_ID_PUBLISH')] <- 'YEARS_ID_PUBLISH'
colnames(test3)[20]
# modify values: /-365
test3$YEARS_ID_PUBLISH <- test3$YEARS_ID_PUBLISH / -365
head(test3$YEARS_ID_PUBLISH) # successful

# e. DAYS_LAST_PHONE_CHANGE --> YEARS_LAST_PHONE_CHANGE
# change name
colnames(test3)[which(names(test3) == 'DAYS_LAST_PHONE_CHANGE')] <- 'YEARS_LAST_PHONE_CHANGE'
# modify values: /-365
test3$YEARS_LAST_PHONE_CHANGE <- test3$YEARS_LAST_PHONE_CHANGE / -365
head(test3$YEARS_LAST_PHONE_CHANGE) # successful

str(train3)

### 2. Missing Values

## 2.1 **** factor columns ****

## 2.1.1 *** train3 *** 

# create list of factor column names
fac_col <- colnames(train3[sapply(train3, class) == 'factor'])

# create data frame of % NA values
na_fac <- sapply(train3[fac_col], function(col)sum(is.na(col))/length(col)) %>% sort(decreasing = TRUE)
na_fac <- data.frame(na_fac)         
na_fac # columns with NA: OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_TYPE_SUITE, CODE_GENDER

# a. OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_TYPE_SUITE: change NA to 'Unknown'
sapply(train3[c('OCCUPATION_TYPE', 'ORGANIZATION_TYPE', 'NAME_TYPE_SUITE', 'CODE_GENDER')], unique) # check unique values

# OCCUPATION_TYPE
train3$OCCUPATION_TYPE <- addNA(train3$OCCUPATION_TYPE) # add NA as level
levels(train3$OCCUPATION_TYPE) <- c(levels(train3$OCCUPATION_TYPE), 'Unknown') # add 'Unknown' as level
train3$OCCUPATION_TYPE[is.na(train3$OCCUPATION_TYPE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(train3$OCCUPATION_TYPE)) # no NA

# ORGANIZATION_TYPE
train3$ORGANIZATION_TYPE <- addNA(train3$ORGANIZATION_TYPE) # add NA as level
levels(train3$ORGANIZATION_TYPE) <- c(levels(train3$ORGANIZATION_TYPE), 'Unknown') # add 'Unknown' as level
train3$ORGANIZATION_TYPE[is.na(train3$ORGANIZATION_TYPE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(train3$ORGANIZATION_TYPE)) # no NA

# NAME_TYPE_SUITE
train3$NAME_TYPE_SUITE <- addNA(train3$NAME_TYPE_SUITE) # add NA as level
levels(train3$NAME_TYPE_SUITE) <- c(levels(train3$NAME_TYPE_SUITE), 'Unknown') # add 'Unknown' as level
train3$NAME_TYPE_SUITE[is.na(train3$NAME_TYPE_SUITE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(train3$NAME_TYPE_SUITE)) # no NA

# b. CODE_GENDER: delete rows (<1% missing)

train3 <- train3[!is.na(train3$CODE_GENDER),]
dim(train3) # 4 rows deleted

## 2.1.2 *** test3 ***

# create list of factor column names
test_fac_col <- colnames(test3[sapply(test3, class) == 'factor'])

# create data frame of % NA values
test_na_fac <- sapply(test3[test_fac_col], function(col)sum(is.na(col))/length(col)) %>% sort(decreasing = TRUE)
test_na_fac <- data.frame(test_na_fac)         
test_na_fac # columns with NA: OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_TYPE_SUITE

# a. OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_TYPE_SUITE: change NA to 'Unknown'
sapply(test3[c('OCCUPATION_TYPE', 'ORGANIZATION_TYPE', 'NAME_TYPE_SUITE')], unique) # check unique values

# OCCUPATION_TYPE
test3$OCCUPATION_TYPE <- addNA(test3$OCCUPATION_TYPE) # add NA as level
levels(test3$OCCUPATION_TYPE) <- c(levels(test3$OCCUPATION_TYPE), 'Unknown') # add 'Unknown' as level
test3$OCCUPATION_TYPE[is.na(test3$OCCUPATION_TYPE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(test3$OCCUPATION_TYPE)) # no NA

# ORGANIZATION_TYPE
test3$ORGANIZATION_TYPE <- addNA(test3$ORGANIZATION_TYPE) # add NA as level
levels(test3$ORGANIZATION_TYPE) <- c(levels(test3$ORGANIZATION_TYPE), 'Unknown') # add 'Unknown' as level
test3$ORGANIZATION_TYPE[is.na(test3$ORGANIZATION_TYPE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(test3$ORGANIZATION_TYPE)) # no NA

# NAME_TYPE_SUITE
test3$NAME_TYPE_SUITE <- addNA(test3$NAME_TYPE_SUITE) # add NA as level
levels(test3$NAME_TYPE_SUITE) <- c(levels(test3$NAME_TYPE_SUITE), 'Unknown') # add 'Unknown' as level
test3$NAME_TYPE_SUITE[is.na(test3$NAME_TYPE_SUITE)] <- 'Unknown' # convert NA to 'Unknown
sum(is.na(test3$NAME_TYPE_SUITE)) # no NA

## 2.2 **** numeric columns ****

## 2.2.1 *** train3 *** 

# create list of numeric column names
num_col <- colnames(train3[sapply(train3, class) == 'numeric'])
num_col

# create data frame of % NA values
na_num <- sapply(train3[num_col], function(col)sum(is.na(col))/length(col)) %>% sort(decreasing = TRUE)
na_num <- data.frame(na_num)         
na_num 
rownames(na_num)[na_num > 0] # columns with NA: 
  # [1] "OWN_CAR_AGE"                "EXT_SOURCE_1"               "ENTRANCES_MODE"            
  # [4] "FLOORSMAX_AVG"              "EXT_SOURCE_3"               "AMT_REQ_CREDIT_BUREAU_HOUR"
  # [7] "AMT_REQ_CREDIT_BUREAU_DAY"  "AMT_REQ_CREDIT_BUREAU_WEEK" "AMT_REQ_CREDIT_BUREAU_MON" 
  # [10] "AMT_REQ_CREDIT_BUREAU_QRT"  "AMT_REQ_CREDIT_BUREAU_YEAR" "OBS_30_CNT_SOCIAL_CIRCLE"  
  # [13] "DEF_30_CNT_SOCIAL_CIRCLE"   "OBS_60_CNT_SOCIAL_CIRCLE"   "DEF_60_CNT_SOCIAL_CIRCLE"  
  # [16] "EXT_SOURCE_2"               "AMT_GOODS_PRICE"            "AMT_ANNUITY"               
  # [19] "CNT_FAM_MEMBERS"            "YEARS_LAST_PHONE_CHANGE"   

# a. variables > 13% NA --> replace with median

# get names of variables > 13% NA
large_na_num <- rownames(na_num)[na_num > 0.13]
large_na_num

# replace NA with median
train3[large_na_num] <- data.frame(sapply(train3[large_na_num], function(x) ifelse(is.na(x), median(x, na.rm = TRUE), x)))
sum(is.na(train3[large_na_num])) # check NA: 0 left

# b. variables < 13% NA --> delete rows (<1% missing)

# get names of variables < 13% NA
small_na_num <- rownames(na_num)[na_num < 0.13]
small_na_num

# delete rows
train3 <- train3[complete.cases(train3[small_na_num]),]
dim(train3) 
sum(is.na(train3)) # 0 NA left --> all good

## 2.2.2 *** test3 ***

# create list of numeric column names
test_num_col <- colnames(test3[sapply(test3, class) == 'numeric'])

# create data frame of % NA values
test_na_num <- sapply(test3[test_num_col], function(col)sum(is.na(col))/length(col)) %>% sort(decreasing = TRUE)
test_na_num <- data.frame(test_na_num)         
test_na_num 
rownames(test_na_num)[test_na_num > 0] # columns with NA:
  # [1] "OWN_CAR_AGE"                "ENTRANCES_MODE"             "FLOORSMAX_AVG"             
  # [4] "EXT_SOURCE_1"               "EXT_SOURCE_3"               "AMT_REQ_CREDIT_BUREAU_HOUR"
  # [7] "AMT_REQ_CREDIT_BUREAU_DAY"  "AMT_REQ_CREDIT_BUREAU_WEEK" "AMT_REQ_CREDIT_BUREAU_MON" 
  # [10] "AMT_REQ_CREDIT_BUREAU_QRT"  "AMT_REQ_CREDIT_BUREAU_YEAR" "OBS_30_CNT_SOCIAL_CIRCLE"  
  # [13] "DEF_30_CNT_SOCIAL_CIRCLE"   "OBS_60_CNT_SOCIAL_CIRCLE"   "DEF_60_CNT_SOCIAL_CIRCLE"  
  # [16] "AMT_ANNUITY"                "EXT_SOURCE_2"

# a. variables > 12% NA --> replace with median

# get names of variables > 12% NA
test_large_na_num <- rownames(test_na_num)[test_na_num > 0.12]
test_large_na_num

# replace NA with median
test3[test_large_na_num] <- data.frame(sapply(test3[test_large_na_num], function(x) ifelse(is.na(x), median(x, na.rm = TRUE), x)))
sum(is.na(test3[test_large_na_num])) # check NA: 0 left

# b. variables < 12% NA --> delete rows (<1% missing) 

# get names of variables < 12% NA
test_small_na_num <- rownames(test_na_num)[test_na_num < 0.12]
test_small_na_num

# delete rows
test3 <- test3[complete.cases(test3[test_small_na_num]),]
dim(test3) 
sum(is.na(test3)) # 0 NA left --> all good

# -----------------

# make copies of train3 and test 3 --> train4 and test4
train4 <- train3 # no NA
test4 <- test3   # no NA

# ------------------

### 3. Inconsistencies/Outliers

## 3.1 *** train4 ***
summary(train4)

## YEARS_EMPLOYED --> presence of negative years

# inspect column
head(train4$YEARS_EMPLOYED)
summary(train4$YEARS_EMPLOYED)
hist(train4$YEARS_EMPLOYED)

# find % of these values
sum(train4$YEARS_EMPLOYED < 0)/nrow(train4) # 18%

# replace with median
train4$YEARS_EMPLOYED <- replace(train4$YEARS_EMPLOYED, which(train4$YEARS_EMPLOYED < 0), median(train4$YEARS_EMPLOYED))
sum(train4$YEARS_EMPLOYED < 0) # no negative values left

## 3.2 *** test4 ***
summary(test4)

## YEARS_EMPLOYED --> presence of negative years

# find % of these values
sum(test4$YEARS_EMPLOYED < 0)/nrow(test4) # 19%

# replace with median
test4$YEARS_EMPLOYED <- replace(test4$YEARS_EMPLOYED, which(test4$YEARS_EMPLOYED < 0), median(test4$YEARS_EMPLOYED))
sum(test4$YEARS_EMPLOYED < 0) # no negative values left

# ---------- END OF CLEANING ---------------

# ##### save train4 and test4 as R object
saveRDS(train4, file='train4.Rds')
saveRDS(test4, file='test4.Rds')

