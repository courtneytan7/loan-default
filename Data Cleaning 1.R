##### Project: Prediction of Loan Default

#### Data Understanding/Cleaning 1

# install packages
pacman::p_load(tidyverse, lubridate, DataE)
# install.packages('DataExplorer')
library(DataExplorer)
# install.packages('corrplot')
library(corrplot)
# install.packages('corrr')
library(corrr)

# set working directory
getwd()
setwd('NUS-ISS/Project')
getwd()

# read in data
train <- read_csv('data_new/application_train.csv')
test <- read_csv('data_new/application_test.csv')

## 1. Initial Inspection
str(train)
str(test)
dim(train)
dim(test)
introduce(train)

## 2. Missing Values

# plot missing values by column
plot_missing(train)
plot_missing(test)

# find % of missing values in each column
missing_pct <- colMeans(is.na.data.frame(train))*100 # same thing as the next code
missing_pct %>% sort(decreasing = TRUE)
apply(train, 2, function(col)sum(is.na(col))/length(col)) # refer to plot

# determine columns with >40% missing values (in train data set) to delete
which(colMeans(is.na(train)) > 0.4) %>% length() # 49 columns to delete
cols_to_delete <- which(colMeans(is.na(train)) > 0.4) # save these columns in a variable
cols_to_delete

# ensure that these columns are the same in test data set
which(colMeans(is.na(test)) > 0.4) %>% length # also 49
test_cols_to_delete <- which(colMeans(is.na(test)) > 0.4)
# get names of these columns in train and test; check if identical --> YES
identical((colnames(train)[cols_to_delete]), (colnames(test)[test_cols_to_delete]))

#    ---------------------
## Assess importance of deleted columns (in cols_to_delete): do correlation of train data (ANOVA since target is kept as numeric)

# split deleted cols into numeric and character 
str(cols_to_delete)
str(train[cols_to_delete])
deleted_cols <- train[cols_to_delete]
deleted_num <- deleted_cols[sapply(deleted_cols, class) == 'numeric']
deleted_char <- deleted_cols[sapply(deleted_cols, class) == 'character']
deleted_num$TARGET <- train$TARGET # add TARGET column
deleted_char$TARGET <- train$TARGET # add TARGET column

# do not factorize TARGET column - output cannot be factor for logistic regression and ANOVA
# all columns in deleted_char except TARGET are factorized

# ANOVA for all 
# factorize characher columns in cols_to_delete except TARGET
deleted_cols2 <- deleted_cols
deleted_cols2[colnames(deleted_char)] <- lapply(deleted_cols2[colnames(deleted_char)], factor)
deleted_cols2$TARGET <- train$TARGET
str(deleted_cols2)

# ANOVA
summary(aov(TARGET ~ ., data=deleted_cols2)) # OWN_CAR_AGE, EXT_SOURCE_1, FLOORSMAX_AVG, ENTRANCES_MODE
# columns to exclude from cols_to_delete: OWN_CAR_AGE, EXT_SOURCE_1, FLOORSMAX_AVG, ENTRANCES_MODE
#      ----------------------

# remove said columns from cols_to_delete and test_cols_to_delete
cols_to_delete2 <- cols_to_delete 
# cols_to_delete2[which(names(cols_to_delete2) %in% c('OWN_CAR_AGE', 'EXT_SOURCE_1', 'FLOORSMAX_AVG', 'ENTRANCES_MODE'))] <- NULL
cols_to_delete2 <- cols_to_delete2[-c(1, 2, 10, 23)]
length(cols_to_delete2) # 45 columns
test_cols_to_delete2 <- test_cols_to_delete
test_cols_to_delete2 <- test_cols_to_delete2[-c(1, 2, 10, 23)]
test_cols_to_delete2 %>% length() # 45 columns

# delete columns in train and test data
train2 <- subset(train, select=-cols_to_delete2)
test2 <- subset(test, select=-test_cols_to_delete2)

# check column deletion in train2 and test2
dim(train2)
dim(test2)

sum(is.na(train2))
mean(is.na(train2)) # 4.6% missing values (after)
mean(is.na(train))  # 24.4% missing values (before)

# 'XNA' values present (discovered when getting unique values in section 5)

# find no. 'XNA' values in data frames
length(which(train2=='XNA')) # 55378 in train2 in "CODE_GENDER" & "ORGANIZATION_TYPE"
length(which(test2=='XNA')) # 9274 in test2 in "ORGANIZATION_TYPE" only
 # apply(train2, 1, function(x) colnames(which(x=='XNA')))
colnames(train2[grep('XNA', train2)]) # finds names of columns that contain a certain string ("CODE_GENDER" & "ORGANIZATION_TYPE")
# convert 'XNA' to NA
train2[train2=='XNA'] <- NA
test2[test2=='XNA'] <- NA
# check % of missing (NA) values now
mean(is.na(train2)) # 4.9% 
mean(is.na(test2)) # 4.6%
# check for any 'XNA' values
any(train2=='XNA') # none left
any(test2=='XNA') # none left


## 3. Duplicates

# check for duplicates
anyDuplicated(train2) # no duplicates
anyDuplicated(test2) # no duplicates

## 4. Data Types

# check existing data types
str(train2)
str(test2)

# inspect unique values
unique_values <- lapply(train2, unique)
unique_values
lengths(unique_values) # finds number of unique values in each column

# factorize categorical columns (numerical columns <5 unique values [num_cols] + HOUR_APPR_PROCESS_START, character columns)

# get column names to factorize
numeric_train2 <- train2[sapply(train2, class) == 'numeric'] # get dataframe of numeric columns
num_cols <- colnames(numeric_train2[lengths(sapply(numeric_train2, unique)) < 5]) # get names of numeric columns <5 unique values
char_cols <- colnames(train2[sapply(train2, class) == 'character']) # get  names of categorical columns
factor_cols <- c(num_cols, char_cols, 'HOUR_APPR_PROCESS_START') # create list of all column names to factorize
factor_cols
factor_cols_no_target <- factor_cols[-1]
factor_cols_no_target
## factorize columns (incl. TARGET)
# lapply(train2[factor_cols], unique)
# train2[factor_cols] %>% length() # 48 columns to factorize
# train2[factor_cols] <- lapply(train2[factor_cols], factor) # factorize train2
# test2[factor_cols[-1]] <- lapply(test2[factor_cols[-1]], factor) # factorize test2
# str(test2) # factorized
# str(train2) # factorized

# factorize columns except TARGET
train2[factor_cols_no_target] %>% length() # 47 columns to factorize
train2[factor_cols_no_target] <- lapply(train2[factor_cols_no_target], factor) # factorize train2
test2[factor_cols[-1]] <- lapply(test2[factor_cols[-1]], factor) # factorize test2
str(train2) # factorized, except TARGET
str(test2) # factorized (test2 has no TARGET column)

##### save train2 and test2 as csv (for some reason diff when loaded back?)
write_csv(train2, 'train2.csv')
write_csv(test2, 'test2.csv')

##### save train2 and test2 as R object
saveRDS(train2, file='train2.Rds')
saveRDS(test2, file='test2.Rds')
# to load these: variable_name <- readRDS('file_name.Rds')

##### ----------------------------------------------
#     that;s it for cleaning 1. Refer to cleaning 2 for dealing
#     with missing values, derived columns, inconsistencies



## 5. String Inconsistencies 
# check unique values in character columns
lapply(train2[sapply(train2, class) == 'character'], function(x) table(x)) # revealed 'XNA' values
# no other inconsitencies

## 6. Erroneous Data (wrong format like date)

# the columns DAYS_BIRTH, DAYS_EMPLOYED, DAYS_REGISTRATION, DAYS_ID_PUBLISH, DAYS_LAST_PHONE_CHANGE are in -days
# a. DAYS_BIRTH
summary((train2$DAYS_BIRTH / -365)) # acceptable data, to create column in +year terms

# b. DAYS_EMPLOYED
summary(train2$DAYS_EMPLOYED / -365) # some negative values
summary(train2[train2$DAYS_EMPLOYED > 0, "DAYS_EMPLOYED"]) # all negative values are just 1 value: -365243 days
sum(train2$DAYS_EMPLOYED > 0) # 55374 negative values
sum(train2$DAYS_EMPLOYED > 0)/nrow(train2) # 18% of values are erroneous
  
# c. DAYS_REGISTRATION
summary(train2$DAYS_REGISTRATION / -365) # acceptable data, no neg values

# d. DAYS_ID_PUBLISH
summary(train2$DAYS_ID_PUBLISH / -365) # acceptable data, no neg values

# e. DAYS_LAST_PHONE_CHANGE
summary(train2$DAYS_LAST_PHONE_CHANGE / -365) # 1NA, otherwise acceptable data, no neg values
  
### Preliminary EDA

## count no. numeric rows
length(select_if(train2, is.character))

## plot continuous variables
plot_histogram(train2)

# plot TARGET column
train2$TARGET %>% table() %>% barplot(,
                                            main = 'Distribution of Target Variable',
                                            xlab = 'Default Status',
                                            ylab = 'Frequency',
                                            col = rgb(0.2,0.4,0.6,1.0))

# correlation of all numeric features against target

i1 <- sapply(train2, is.numeric)
y1 <- "TARGET"
x1 <- setdiff(names(train2)[i1], y1)
corre <- cor(train2[x1], train2[[y1]], use = "complete.obs")
# EXT_SOURCE_3, EXT_SOURCE_2 highest correlation (negative), DAYS_BIRTH highest positive
# corrplot(t(corre), is.cor=FALSE, method='color')

# another method of corrleation
cor_new <- train2[i1] %>% correlate() %>% focus(TARGET)
head(cor_new)

# plot ^
cor_new %>%
  mutate(term = factor(term, levels = term[order(TARGET)])) %>%
  ggplot(aes(x = term, y = TARGET)) + 
    geom_bar(stat = "identity") +
    ylab('Correlation with TARGET') + 
    xlab('Variable')

df_cor_new = as.data.frame(cor_new)
df_cor_new[which.min(df_cor_new$TARGET),] # find highest -ve corr 
df_cor_new[which.max(df_cor_new$TARGET),] # find highest +ve corr

#cor(train2$AMT_ANNUITY, train2$TARGET, use = "complete.obs")
#?cor

# DAYS_BIRTH highest positive corr (0.0789) - plot:

# transform DAYS_BIRTH into positive years
# create copy of train2 --> train2fake to add t_DAYS_BIRTH column
train2fake <- train2
train2fake <- train2fake %>% mutate(t_DAYS_BIRTH = DAYS_BIRTH/-365)
head(train2fake$t_DAYS_BIRTH)

# plot t_DAYS_BIRTH 
ggplot(train2fake, aes(x = t_DAYS_BIRTH, fill=factor(TARGET))) +
    geom_histogram(binwidth = 5, col = 'black') +
    theme(legend.position = 'top') +
    labs(title = 'Age of Client', x = 'Years', y = 'Count')

#boxplot
ggplot() +
  geom_boxplot(aes(y=t_DAYS_BIRTH)) + 
  scale_x_discrete( ) + 
  labs(title = 'Age of Client', y = 'Years') + 
  coord_flip()

ggplot(train2fake, aes(y=t_DAYS_BIRTH)) + 
  geom_boxplot() + 
  scale_x_discrete() + 
  labs(title = 'Age of Client', y = 'Years') + 
  coord_flip()

# EXT_SOURCE_3 - greatest -ve correlation - plot:

# plot EXT_SOURCE_3 histogram
ggplot(train2, aes(x = EXT_SOURCE_3, fill=factor(TARGET))) +
  geom_histogram(binwidth = 0.1, col = 'black') +
  theme(legend.position = 'top') +
  labs(title = 'EXT_SOURCE_3', x = 'Score', y = 'Count')

# EXT_SOURCE_3 boxplot

ggplot(train2, aes(y=EXT_SOURCE_3)) + 
  geom_boxplot() + 
  scale_x_discrete() + 
  labs(title = 'EXT_SOURCE_3', y = 'Score') + 
  coord_flip()
 # -------------------------------------
