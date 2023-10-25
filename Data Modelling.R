##### Modelling

# install packages
pacman::p_load(tidyverse, lubridate)
# install.packages('DataExplorer')
# install.packages('corrplot')
# install.packages('corrr')
# install.packages('lares')
# install.packages('caTools')
# install.packages('lemon')
# install.packages('car')
# install.packages('caret')

# load libraries
library(DataExplorer)
library(corrplot)
library(corrr)
library(lares)
library(caTools)
library(lemon)
library(car)
library(caret)
library(MASS)

# set working directory
getwd()
setwd('NUS-ISS/Project')
getwd()

# load data
train7 <- readRDS('train6.Rds')
test7 <- readRDS('test6.Rds')

# display settings
options(scipen=100)
options(max.print=1000)

# inspect train7
str(train7) # TARGET is factor

### Create train and validation data sets

set.seed(22) # set initial seed
split <- sample.split(train7$TARGET, SplitRatio = 0.7)
train_set <- train7[split,]
validation_set <- train7[!split,]

### train and validation data set info - TARGET distribution
train_set2 <- train_set
train_dist <- train_set2 %>% count(TARGET) %>% mutate(percent = n / sum(n) * 100)
knit_print.data.frame <- lemon_print
validation_set2 <- validation_set
validation_dist <- validation_set2 %>% count(TARGET) %>% mutate(percent = n / sum(n) * 100)
train_dist
validation_dist

### 1. Initial Model - lr1
# model fit (using train_set)
lr1 <- glm(formula = TARGET ~ ., family = binomial, data = train_set)
summary(lr1)

# VIF for multicollinearity
vif(lr1)

## model 2 - lr2 - drop ORGANIZATION_TYPE
lr2 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE, family = binomial, data = train_set)
summary(lr2)
vif(lr2)

## model 3 - lr3 - drop NAME_INCOME_TYPE
lr3 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE -NAME_INCOME_TYPE, family = binomial, data = train_set)
vif(lr3)

## model 4 - lr4 - drop REGION_RATING_CLIENT
lr4 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE -NAME_INCOME_TYPE -REGION_RATING_CLIENT, family = binomial, data = train_set)
vif(lr4)

## model 5 - lr5 - drop REG_REGION_NOT WORK_REGION
lr5 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE -NAME_INCOME_TYPE -REGION_RATING_CLIENT -REG_REGION_NOT_WORK_REGION, family = binomial, data = train_set)
vif(lr5)

## model 6 - lr6 - drop FLAG_DOCUMENT_3
lr6 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE -NAME_INCOME_TYPE -REGION_RATING_CLIENT -REG_REGION_NOT_WORK_REGION -FLAG_DOCUMENT_3, family = binomial, data = train_set)
vif(lr6)

## model 7 - lr7 - drop REG_CITY_NOT_WORK_CITY --> no more multicollinearity
lr7 <- glm(formula = TARGET ~ . -ORGANIZATION_TYPE -NAME_INCOME_TYPE -REGION_RATING_CLIENT -REG_REGION_NOT_WORK_REGION -FLAG_DOCUMENT_3 -REG_CITY_NOT_WORK_CITY, family = binomial, data = train_set)
vif(lr7)
summary(lr7)

### model 7 has no multicollinearity
### model 7 confusion matrices below, and model 1 confusion matrices for comparison

# model evaluation - confusion matrix train set lr1
prob1 <- predict(lr1, newdata = train_set, type = 'response') # calculate prediction probabilities
pred1 <- ifelse(prob1 > 0.5, 1, 0)
confusionMatrix(factor(pred1), factor(train_set$TARGET))

# model evaluation - confusion matrix validation set lr1
prob <- predict(lr1, newdata = validation_set, type = 'response') # calculate prediction probabilities
pred <- ifelse(prob > 0.5, 1, 0)
confusionMatrix(factor(pred), factor(validation_set$TARGET))

# confusion matrix 2 - lr 7 on train_set
prob2t <- predict(lr7, newdata=train_set, type='response')
pred2t <- ifelse(prob2t > 0.5, 1, 0)
confusionMatrix(factor(pred2t), factor(train_set$TARGET))

# confusion matrix 2 - lr7 on valiadtion_set
prob2v <- predict(lr7, newdata = validation_set, type = 'response')
pred2v <- ifelse(prob2v > 0.5, 1, 0)
confusionMatrix(factor(pred2v), factor(validation_set$TARGET))

#### Remove insignificant variables based on p-value

## create new df: train_set3 without above variables determined by model 7 (after VIF)
train_set3 <- train_set # create copy of train_set
drop <- c('ORGANIZATION_TYPE', 'NAME_INCOME_TYPE', 'REGION_RATING_CLIENT', 'REG_REGION_NOT_WORK_REGION', 'FLAG_DOCUMENT_3', 'REG_CITY_NOT_WORK_CITY')
train_set3 <- train_set3[, !(names(train_set3) %in% drop)] # 6 variables dropped

# review lr7 summary
summary(lr7) 

## determine sig/non-sig variables
summary(lr7)$coef[summary(lr7)$coef[,4] <= .05, 4] # get significant variables and p-values
sig <- names(summary(lr7)$coef[summary(lr7)$coef[,4] <= .05, 4]) # get names of sig variables
sig
nosig <- names(summary(lr7)$coef[summary(lr7)$coef[,4] > .05, 4]) # get names of non-sig variables (factor levels)
nosig

## get names of non-significant variables
# numeric non-sig var
nosigvar_num <- c('AMT_INCOME_TOTAL', 'CLIENT_AGE', 'CNT_FAM_MEMBERS', 'OBS_60_CNT_SOCIAL_CIRCLE', 'AMT_REQ_CREDIT_BUREAU_HOUR', 'AMT_REQ_CREDIT_BUREAU_DAY', 'AMT_REQ_CREDIT_BUREAU_YEAR')
# factor non-sig variables
nosigvar_fac <- c('FLAG_OWN_REALTY', 'NAME_TYPE_SUITE', 'NAME_EDUCATION_TYPE', 'NAME_HOUSING_TYPE', 'FLAG_EMAIL', 'OCCUPATION_TYPE', 'WEEKDAY_APPR_PROCESS_START', 'HOUR_APPR_PROCESS_START', 'LIVE_REGION_NOT_WORK_REGION', 'LIVE_CITY_NOT_WORK_CITY', 'FLAG_DOCUMENT_4', 'FLAG_DOCUMENT_5', 'FLAG_DOCUMENT_6', 'FLAG_DOCUMENT_7', 'FLAG_DOCUMENT_9', 'FLAG_DOCUMENT_10', 'FLAG_DOCUMENT_12', 'FLAG_DOCUMENT_15', 'FLAG_DOCUMENT_17', 'FLAG_DOCUMENT_19', 'FLAG_DOCUMENT_20', 'FLAG_DOCUMENT_21')

## drop these variables from train_set --> train_set4: after accounting for both VIF and insig var based on p-value
train_set4 <- train_set3 # create copy of train_set3
train_set4 <- train_set4[, !names(train_set4) %in% nosigvar_num] # remove non-sig num var --> 7 variables dropped
train_set4 <- train_set4[, !names(train_set4) %in% nosigvar_fac] # remove non-sig fac var --> 22 variables dropped

## model 8 - lr8 - no multicollinearity, inisig variables dropped
lr8 <- glm(formula = TARGET ~ ., family = binomial, data = train_set4)
summary(lr8)

## likelihood ratio test
anova(lr7, lr8, test = 'LRT') # p-value < 0.05: insig variables should be included (according to website)

## confusion matrix 3 - lr 8 on train_set
prob3t <- predict(lr8, newdata=train_set, type='response')
pred3t <- ifelse(prob3t > 0.5, 1, 0)
confusionMatrix(factor(pred3t), factor(train_set$TARGET), positive = '1')

## confusion matrix 3 - lr8 on valiadtion_set 
prob3v <- predict(lr8, newdata = validation_set, type = 'response')
pred3v <- ifelse(prob3v > 0.5, 1, 0)
confusionMatrix(factor(pred3v), factor(validation_set$TARGET), positive = '1')
?confusionMatrix

#### Decision Tree

### All variables; using train_set

# proportion of 0/1 in TARGET variable 
prop.table(table(train_set$TARGET))
prop.table(table(validation_set$TARGET))

# load libraries
library(rpart)
library(rpart.plot)

# build model
dtfit <- rpart(TARGET ~ ., data = train_set, method = 'class', control = rpart.control("minsplit" = 1))
rpart.plot(dtfit, extra = 106)

# predict train set
dtpredt <- predict(dtfit, train_set, type = 'class')
confusionMatrix(dtpredt, train_set$TARGET, positive = '1')

# predict validation set
dtpred <- predict(dtfit, validation_set, type = 'class')
confusionMatrix(dtpred, validation_set$TARGET, positive = '1')

#### Random Forest 

# load libraries
library(randomForest)

# combine factor levels of ORGANIZATION_TYPE (error in fitting RF model - Can not handle categorical predictors with more than 53 categories - ORGANIZATION_TYPE HAS 58 factor levels
train_set_rf <- train_set # make copy of train_set
train_set_rf$ORGANIZATION_TYPE <- fct_collapse(train_set_rf$ORGANIZATION_TYPE, 
                                         BusinessEntity = c('Business Entity Type 1', 'Business Entity Type 2', 'Business Entity Type 3'), 
                                         Industry = c('Industry: type 1', 'Industry: type 2', 'Industry: type 3','Industry: type 3', 'Industry: type 4', 'Industry: type 5', 'Industry: type 6', 'Industry: type 7', 'Industry: type 8', 'Industry: type 9', 'Industry: type 10', 'Industry: type 11', 'Industry: type 12', 'Industry: type 13'),
                                         Trade = c('Trade: type 1', 'Trade: type 2', 'Trade: type 3', 'Trade: type 4', 'Trade: type 5', 'Trade: type 6', 'Trade: type 7'), 
                                         Transport = c('Transport: type 1', 'Transport: type 2', 'Transport: type 3', 'Transport: type 4')
) # combine factor levels
str(train_set_rf) # check --> 35 levels now

# build model --> did not work, did on rattle instead
rf <- randomForest(TARGET ~ ., data = train_set_rf) # Error: cannot allocate vector of size 815.9 Mb
str(train_set)
memory.limit()

# feature importance
oldrn <- round(randomForest::importance(crs$rf), 2)
oldrn[order(oldrn[,3], decreasing=TRUE),]

oldrn1 <- round(randomForest::importance(crs$rf, type = 1), 2)
rn1[order(rn1, decreasing=TRUE),]
varImpPlot(crs$rf)

#### Handle imbalanced data

## install packages
install.packages('ROSE')
library(ROSE)

## synthetic data generation using ROSE

# train_set
train_set.rose <- ROSE(TARGET ~ ., data = train_set, seed = 1)$data # generate synthetic data 

table(train_set$TARGET) # check proportion of 0/1 in TARGET
table(train_set.rose$TARGET)
prop.table(table(train_set$TARGET)) # 92% [0] and 8% [1]
prop.table(table(train_set.rose$TARGET)) # 50% [0] and 50% [1]

# train_set4 for logistic regression - VIF, insig accounted for
train_set4.rose <- ROSE(TARGET ~ ., data = train_set4, seed = 1)$data # generate synthetic data
prop.table(table(train_set4.rose$TARGET)) # check

# train_set_rf for random forest
train_rf.rose <- ROSE(TARGET ~ ., data = train_set_rf, seed = 1)$data # generate synthetic data
prop.table(table(train_rf.rose$TARGET)) # check

# ------------------------------------------------------------------------
# save as R objects
saveRDS(train_set, file='train_set.Rds')
saveRDS(validation_set, file='validation_set.Rds')

saveRDS(train_set.rose, file='train_set_rose.Rds')
saveRDS(train_set4.rose, file='train_set4_rose.Rds')
saveRDS(train_rf.rose, file='train_rf_rose.Rds')
