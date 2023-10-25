##### Data Modelling 2 (after upsampling)

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
# install.packages('ROSE')
# install.packages('dominanceanalysis')
# install.packages('reghelper')
# install.packages('jtools')
# install.packages('ggstance')
# install.packages('Boruta')

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
library(ROSE)
library(randomForest)
library(rpart)
library(rpart.plot)
library(ROCR)
library(dominanceanalysis)
library(reghelper)
library(jtools)
library(ggstance)
library(Boruta)

# set working directory
getwd()
setwd('NUS-ISS/Project')
getwd()

# load data
train_a <- readRDS('train_set.Rds')
validation_a <- readRDS('validation_set.Rds')

train_a.rose <- readRDS('train_set_rose.Rds')
train_a_lr.rose <- readRDS('train_set4_rose.Rds')
train_a_rf.rose <- readRDS('train_rf_rose.Rds')

# display settings
options(scipen=100)
options(max.print=1000)

#### Logistic Regression

## fit model
lrnew <- glm(formula = TARGET ~ ., family = binomial, data = train_a_lr.rose)
summary(lrnew)

## confusion matrix

# on train_a
prob_lrt <- predict(lrnew, newdata=train_a, type='response')
pred_lrt <- ifelse(prob_lrt > 0.5, 1, 0)
confusionMatrix(factor(pred_lrt), factor(train_a$TARGET), positive = '1')

# on valiadtion_a
prob_lrv <- predict(lrnew, newdata = validation_a, type = 'response')
pred_lrv <- ifelse(prob_lrv > 0.5, 1, 0)
confusionMatrix(factor(pred_lrv), factor(validation_a$TARGET), positive = '1')

## Feature Importance (standardized coefficients)

# get stadardized coefficients
std <- beta(lrnew)$coef[,1]
ordered_std <- std[order(std)]
ordered_std_df <- as.data.frame(ordered_std)
ordered_std_df

ordered_std_df$FEATURES <- row.names(ordered_std_df)
ordered_std_df$FEATURES <- substr(ordered_std_df$FEATURES, 1, nchar(ordered_std_df$FEATURES) - 2)

osd <- ordered_std_df
osd$FEATURES <- factor(osd$FEATURES, levels = osd$FEATURES)

ggplot(data = osd, aes(x = FEATURES, y = ordered_std)) + 
  geom_bar(stat = 'identity', fill='#073763') +
  theme(text = element_text(size=10), 
        axis.text.x = element_text(angle=50, hjust=1)) + 
  labs(title='Feature Importance', y='Standardized Coefficients')

#### Decision Tree

# before rose (to do again after removing neg values in AMT_INCOME_TOTAL)

# remove neg values
sum(train_a$AMT_INCOME_TOTAL < 0)
train_a$AMT_INCOME_TOTAL <- replace(train_a_dt.rose$AMT_INCOME_TOTAL, which(train_a_dt.rose$AMT_INCOME_TOTAL < 0), median(train_a_dt.rose$AMT_INCOME_TOTAL))
sum(train_a_dt.rose$AMT_INCOME_TOTAL < 0) # no negative values left


### Model 1
# build model 
dtnew <- rpart(TARGET ~ ., data = train_a.rose, method = 'class', control = rpart.control("minsplit" = 1))
rpart.plot(dtnew, extra = 106)

# predict train set (train_a)
pred_dtt <- predict(dtnew, train_a, type = 'class')
confusionMatrix(pred_dtt, train_a$TARGET, positive = '1')

# predict validation set (validation_a)
pred_dtv <- predict(dtnew, validation_a, type = 'class')
confusionMatrix(pred_dtv, validation_a$TARGET, positive = '1')

## model performance
# calculate area under curve

# ROC chart
plot.roc()

# lift chart

## Model 2
# build model
dtnew2 <- rpart(TARGET ~ ., data = train_a.rose, method = 'class', control = rpart.control(minsplit = 1, minbucket = 1, maxdepth = 10, usesurrogate = 2, xval = 10, cp = 0.01))
rpart.plot(dtnew2, extra = 106)

summary(train_a.rose$AMT_INCOME_TOTAL) # negative values in this column??

# make copy of train set for decision tree
train_a_dt.rose <- train_a.rose

# how many negative
sum(train_a_dt.rose$AMT_INCOME_TOTAL < 0) / nrow(train_a_dt.rose)
nrow(train_a_dt.rose$AMT_INCOME_TOTAL)

# replace neg values with median
train_a_dt.rose$AMT_INCOME_TOTAL <- replace(train_a_dt.rose$AMT_INCOME_TOTAL, which(train_a_dt.rose$AMT_INCOME_TOTAL < 0), median(train_a_dt.rose$AMT_INCOME_TOTAL))
sum(train_a_dt.rose$AMT_INCOME_TOTAL < 0) # no negative values left

## Build model again
# build model 
dtnew <- rpart(TARGET ~ ., data = train_a_dt.rose, method = 'class', control = rpart.control("minsplit" = 1))
rpart.plot(dtnew, extra = 106)

# predict train set (train_a)
pred_dtt <- predict(dtnew, train_a_dt.rose, type = 'class')
confusionMatrix(pred_dtt, train_a_dt$TARGET, positive = '1')

# predict validation set (validation_a)
pred_dtv <- predict(dtnew, validation_a, type = 'class')
confusionMatrix(pred_dtv, validation_a$TARGET, positive = '1')

#### Random Forest
rf1 <- randomForest(TARGET ~ ., data = train_a_rf.rose)
memory.limit()
memory.limit(size = 82000)
memory.size()
memory.limit()

#### Rattle
library(rattle)
rattle()

ggVarImp(crs$rf,
         title="Variable Importance Random Forest train_a_rf.rose")

?ggVarImp

importance(crs$rf, type=1)

rn <- round(randomForest::importance(crs$rf), 2)
orn <- (rn[order(rn[,3], decreasing=TRUE),])

# mean decrease accuracy
rn1 <- round(randomForest::importance(crs$rf, type = 1), 2)
rn1[order(rn1, decreasing=TRUE),]
varImpPlot(crs$rf)

rn[order(rn[,2], decreasing=TRUE),]

### Model Tuning

## tuneRF
set.seed(22)
bestmtry <- tuneRF(train_a_rf.rose[,-1], train_a_rf.rose[,1],
                   stepFactor = 0.5,
                   improve = 0.05,
                   ntreeTry = 200,
                   plot = TRUE,
                   trace = TRUE)

## caret

control <- trainControl(method = 'repeatedcv', number=10, repeats=3, search = 'random')
set.seed(22)
mtry <- sqrt(ncol(train_a_rf.rose))
rf_random <- train(TARGET ~ ., data = train_a_rf.rose, method = 'rf', metric=metric, tuneLength=15, trControl = control)
?trainControl

## new
# define control
trControl <- trainControl(method = 'cv', number = 10, search = 'grid')
xvars <- names(train_a_rf.rose[-1])

rf_default <- train(train_a_rf.rose[, names(train_a_rf.rose) %in% xvars],
                    train_a_rf.rose$TARGET,
                    method = 'rf',
                    metric = 'Accuracy', 
                    trControl = trControl)

library(rattle)
rattle()

# 500 trees
varImpPlot(crs$rf)

#### Random Forest with LR data set: train_a_lr.rose

rattle()

# gives better performance

# tune this model (need best ntree first)
set.seed(22)
bestmtry1 <- tuneRF(train_a_lr.rose[,-1], train_a_lr.rose[,1],
                   stepFactor = 0.5,
                   improve = 0.05,
                   ntreeTry = 500,
                   plot = TRUE,
                   trace = TRUE)

# 500 trees
varImpPlot(crs$rf)

# 400 trees
varImpPlot(crs$rf)

test_data <- readRDS('test6.Rds')
