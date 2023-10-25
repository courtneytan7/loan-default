##### Data Understanding (EDA)

# install packages
pacman::p_load(tidyverse, lubridate)
# install.packages('DataExplorer')
# install.packages('corrplot')
# install.packages('corrr')
# install.packages('lares')
# install.packages('ggforce')
# install.packages('ltm')

# load libraries
library(DataExplorer)
library(corrplot)
library(corrr)
library(lares)
library(ggforce)
library(ltm)

# set working directory
getwd()
setwd('NUS-ISS/Project')
getwd()

# load data
train5 <- readRDS('train4.Rds')
test5 <- readRDS('test4.Rds')

# display settings
options(scipen=100)
options(max.print=500)

### 1. Feature Association - pairwise correlation of x variables
## a. Numerical variables - Pearson Correlation
# get data frame of numeric variables
train5_num <- train5[sapply(train5, class) == 'numeric']

# Correlation analysis
train5_num.cor <- cor(train5_num)
corrplot(train5_num.cor, tl.cex = 0.5)
train5_num.cor

## a. AMT_ANNUITY & AMT_CREDIT
cor(train5$AMT_ANNUITY, train5$AMT_CREDIT) # 0.769 strong positive relationship
cor.test(train5$AMT_ANNUITY, train5$AMT_CREDIT) # p < 0.05, stat. sig.
# plot
ggplot(train5, aes(AMT_ANNUITY, AMT_CREDIT)) + 
  geom_point(aes(color=factor(TARGET)), size=4, alpha=0.5) +
  theme_bw(base_family = 'Times') + 
  labs(color='TARGET')
# scatterplot
ggplot(train5, aes(AMT_ANNUITY, AMT_CREDIT)) + geom_point() + labs(title = 'AMT_CREDIT vs. AMT_ANNUITY ')

## b. AMT_GOODS_PRICE & AMT_CREDIT
cor(train5$AMT_GOODS_PRICE, train5$AMT_CREDIT) # 0.987 strong positive relationship
cor.test(train5$AMT_GOODS_PRICE, train5$AMT_CREDIT) # p < 0.05, stat. sig.
# plot
ggplot(train5, aes(AMT_GOODS_PRICE, AMT_CREDIT)) + 
  geom_point(size=4, alpha=0.5) +
  labs(title = 'AMT_CREDIT vs. AMT_GOODS_PRICE')
# scatterplot
ggplot(train5, aes(AMT_GOODS_PRICE, AMT_CREDIT)) + geom_point() + labs(title = 'AMT_CREDIT vs. AMT_GOODS_PRICE')

## c. AMT_GOODS_PRICE & AMT_ANNUITY
cor(train5$AMT_GOODS_PRICE, train5$AMT_ANNUITY) # 0.774 strong positive relationship
cor.test(train5$AMT_GOODS_PRICE, train5$AMT_ANNUITY) # p < 0.05, stat. sig.
# plot
ggplot(train5, aes(AMT_GOODS_PRICE, AMT_ANNUITY)) + 
  geom_point() +
  labs(title = 'AMT_ANNUITY vs. AMT_GOODS_PRICE ')

## a, b, c: remove AMT_GOODS_PRICE

## d. CNT_FAM_MEMBERS & CNT_CHILDREN
cor.test(train5$CNT_FAM_MEMBERS, train5$CNT_CHILDREN) # 0.879, stat. sig.
# plot
ggplot(train5, aes(CNT_FAM_MEMBERS, CNT_CHILDREN)) + 
  geom_point() +
  labs(title = 'CNT_CHILDREN vs. CNT_FAMILY_MEMBERS')

# remove CNT_CHILDREN: children is a subset of family members

## e. OBS_60_CNT_SOCIAL_CIRCLE & OBS_30_CNT_SOCIAL_CIRCLE
cor.test(train5$OBS_60_CNT_SOCIAL_CIRCLE, train5$OBS_30_CNT_SOCIAL_CIRCLE) # 0.998, stat. sig.
# plot
ggplot(train5, aes(OBS_60_CNT_SOCIAL_CIRCLE, OBS_30_CNT_SOCIAL_CIRCLE)) + 
  geom_point() +
  labs(title = 'OBS_30_CNT_SOCIAL_CIRCLE vs. OBS_60_CNT_SOCIAL_CIRCLE')

# remove OBS_30_CNT_SOCIAL_CIRCLE: info is captured in OBS_60...

## f. DEF_60_CNT_SOCIAL_CIRCLE & DEF_30_CNT_SOCIAL_CIRCLE
cor.test(train5$DEF_60_CNT_SOCIAL_CIRCLE, train5$DEF_30_CNT_SOCIAL_CIRCLE) # 0.861, stat. sig.
# plot
ggplot(train5, aes(DEF_60_CNT_SOCIAL_CIRCLE, DEF_30_CNT_SOCIAL_CIRCLE)) + 
  geom_point() +
  labs(title = 'DEF_30_CNT_SOCIAL_CIRCLE vs. DEF_60_CNT_SOCIAL_CIRCLE')

# remove DEF_30_CNT_SOCIAL_CIRCLE: info is captured in DEF_60...

## remove said columns:
drop <- c('AMT_GOODS_PRICE', 'CNT_CHILDREN', 'OBS_30_CNT_SOCIAL_CIRCLE', 'DEF_30_CNT_SOCIAL_CIRCLE')
train6 <- train5[, !(names(train5) %in% drop)]
test6 <- test5[, !(names(test5) %in% drop)]

### 2. Correlation with TARGET: categorical and numerical variables (using train6)

## a. Numerical variables

## (i) Pearson Correlation - TARGET is numeric --> also can be called point-biserial correlation??? PBC also uses cor.test, gices same result as this Pearson

train6_num <- train6[sapply(train6, class) == 'numeric'] # get numeric variables
train6_num.cor <- correlate(train6_num) # get correlation
cor.target <- train6_num.cor %>% focus(TARGET) # focus on TARGET column
cor.target[order(cor.target$TARGET),] # ascending - top 5 -ve correlations
cor.target[order(-cor.target$TARGET),] # descending - top 5 +ve correlations
# plot
corr_var(train6_num, TARGET, top = 15)

## (i) Biserial Point Correlation (same as .cor)
str(train6_num)
levels(train6_num$TARGET)
biserial.cor(train6_num$EXT_SOURCE_2, train6_num$TARGET, level = 1)
biserial.cor(train6_num$EXT_SOURCE_2, train6_num$TARGET, level = 2)
biserial.cor(train6_num$EXT_SOURCE_3, train6_num$TARGET, level = 1)
biserial.cor(train6_num$EXT_SOURCE_1, train6_num$TARGET, level = 1)

## (ii) plot Biserial Point Coorrelation
corr_var(train6_num, TARGET, top = 15, max_pvalue = 0.05)
levels(train6_num$TARGET)
corr_var(train6_num, TARGET_0, redundant = TRUE, top = 5)

## (ii) ANOVA - TARGET is factor - cannot as ANOVA is for categorical x and numeric y

# # factorize TARGET
# str(train6_num) # inspect df - TARGET is numeric
# train6_num_ANOVA <- train6_num # create copy of train6 for ANOVA
# train6_num_ANOVA$TARGET <- as.factor(train6_num_ANOVA$TARGET) # factorize TARGET
# 
# # ANOVA
# summary(aov(TARGET ~ ., data=train6_num_ANOVA))
# sapply(train6_num_ANOVA, unique)

## b. Categorical variables - ANOVA and Chi-Squared

# train6
# get categorical variables
train6$TARGET <- as.factor(train6$TARGET) # factorize TARGET
train6_cat <- train6[sapply(train6, class) == 'factor'] # get factor columns
str(train6_cat)

# remove variables with 1 level
train6_cat <- subset(train6_cat, select=-c(FLAG_MOBIL, NAME_FAMILY_STATUS))

# Chi Squared Test
CHIS <- lapply(train6_cat[,-1], function(x) chisq.test(train6_cat[,1], x))
chi_result <- rbindlist(lapply(CHIS, tidy), idcol=TRUE)[,c(1,3)] %>% arrange(p.value)
typeof(chi_result)
chi_df <- as.data.frame(chi_result)
str(chi_df)
chi_df

# rename .id column
chi_df <- rename(chi_df, 'Variable' = '.id')
chi_df

barplot(chi_df$p.value)
barplot(chi_df[1:5,]$p.value)
ggplot(data=chi_df[1:5,], aes(x=.id, y=p.value)) +
  geom_bar(position=position_dodge(), stat = 'identity') +
  coord_flip() + 
  scale_y_continuous(name = 'P value') +
  scale_x_discrete(name='Variable') +
  geom_errorbarh(aes(xmax=as.numeric(.id)+0.45,xmin=as.numeric(.id)-0.45,height=0),position=position_dodge(width=0.9))
 

ggplot(chi_df[1:5,], aes(.id, p.value)) +        # Create ggplot2 barchart with default y-axis
  geom_bar(stat = "identity") +
  coord_flip() + 
  ylim(0, 5.56e-100)
  

# ANOVA with TARGET as numeric --> decided agaist
# # train5
# # get categorical variables
# train5_cat <- train5[sapply(train5, class) == 'factor']
# train5_cat$TARGET <- train5$TARGET # add TARGET column
# 
# # ANOVA error - some variables have only 1 level
# sapply(train5_cat, unique) 
# train5_cat <- subset(train5_cat, select=-c(FLAG_MOBIL,NAME_FAMILY_STATUS)) # these variables have only 1 unique value, remove columns from ANOVA analysis
# 
# # ANOVA 
# summary(aov(TARGET ~ ., data=train5_cat))
# anova.result <- aov(TARGET ~ ., data=train5_cat)
# anova.result %>% arrange(fvalue)

# try ANOAV with numeric TARGET (with all variables together)
str(train6) # TARGET is factor
train_fake <- train6
train_fake$TARGET <- as.numeric(levels(train_fake$TARGET))[train_fake$TARGET] # convert factor to numeric
class(train_fake$TARGET) # numeric
summary(aov(TARGET ~ ., data = train_fake))
summary(aov(TARGET ~ CODE_GENDER, data=train_fake))

### remove FLAG_MOBIL,NAME_FAMILY_STATUS from train6 and test6:
train6 <- subset(train6, select=-c(FLAG_MOBIL,NAME_FAMILY_STATUS))
test6 <- subset(test6, select=-c(FLAG_MOBIL,NAME_FAMILY_STATUS))

### remove SK_ID_CURR from train6 and test6
train6 <- subset(train6, select=-SK_ID_CURR)
test6 <- subset(test6, select=-SK_ID_CURR)

summary(train6_fit)

### 3. Plot variables of interest

## numerical: EXT_SOURCE_2, EXT_SOURCE_3, EXT_SOURCE_1, CLIENT_AGE, YEARS_EMPLOYED
## categorical: OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_INCOME_TYPE
str(train6) # TARGET is factor

### numerical: EXT_SOURCE_2, EXT_SOURCE_3, EXT_SOURCE_1
## Histograms
# EXT_SOURCE_2
ggplot(train6, aes(x=EXT_SOURCE_2, fill=TARGET)) + 
        geom_histogram(col='black') + 
        ggtitle('Histogram of EXT_SOURCE_2') + 
        theme(legend.position = 'top')

# EXT_SOURCE_3
ggplot(train6, aes(x=EXT_SOURCE_3, fill=TARGET)) + 
  geom_histogram(binwidth=0.1, col='black') + 
  ggtitle('Histogram of EXT_SOURCE_3') + 
  theme(legend.position = 'top')

# EXT_SOURCE_1
ggplot(train6, aes(x=EXT_SOURCE_1, fill=TARGET)) + 
  geom_histogram(binwidth=0.1, col='black') + 
  ggtitle('Histogram of EXT_SOURCE_1') + 
  theme(legend.position = 'top')

# YEARS_EMPLOYED
ggplot(train6, aes(x=YEARS_EMPLOYED, fill=TARGET)) + 
  geom_histogram(binwidth=0.1, col='black') + 
  ggtitle('Histogram of YEARS_EMPLOYED') + 
  theme(legend.position = 'top')

## Boxplots
# EXT_SOURCE_2
ggplot(train6, aes(TARGET, EXT_SOURCE_2, fill=TARGET)) + 
    geom_boxplot(outlier.color = 'red',
                outlier.shape = 4,
                outlier.size = 4) + 
    labs(title = 'EXT_SOURCE_2 Distribution by Default Status (TARGET)')
          
# EXT_SOURCE_3
ggplot(train6, aes(TARGET, EXT_SOURCE_3, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'EXT_SOURCE_3 Distribution by Default Status (TARGET)')          
        
# EXT_SOURCE_1
ggplot(train6, aes(TARGET, EXT_SOURCE_1, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'EXT_SOURCE_1 Distribution by Default Status (TARGET)') 

# CLIENT_AGE
ggplot(train6, aes(TARGET, CLIENT_AGE, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'CLIENT_AGE Distribution by Default Status (TARGET)')

# YEARS_EMPLOYED
ggplot(train6, aes(TARGET, YEARS_EMPLOYED, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'YEARS_EMPLOYED Distribution by Default Status (TARGET)')

# DEF_60_CNT_SOCIAL_CIRCLE
# histogram
ggplot(train6, aes(x=DEF_60_CNT_SOCIAL_CIRCLE, fill=TARGET)) + 
  geom_histogram(col='black') + 
  ggtitle('Histogram of DEF_60_CNT_SOCIAL_CIRCLE') + 
  theme(legend.position = 'top')


# boxplot
ggplot(train6, aes(TARGET, DEF_60_CNT_SOCIAL_CIRCLE, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'DEF_60_CNT_SOCIAL_CIRCLE Distribution by Default Status (TARGET)') 

# OWN_CAR_AGE
# histogram
ggplot(train6, aes(x=OWN_CAR_AGE, fill=TARGET)) + 
  geom_histogram(col='black') + 
  ggtitle('Histogram of OWN_CAR_AGE') + 
  theme(legend.position = 'top')

# boxplot
ggplot(train6, aes(TARGET, OWN_CAR_AGE, fill=TARGET)) + 
  geom_boxplot(outlier.color = 'red',
               outlier.shape = 4,
               outlier.size = 4) + 
  labs(title = 'OWN_CAR_AGE Distribution by Default Status (TARGET)') 

## categorical: OCCUPATION_TYPE, ORGANIZATION_TYPE, NAME_INCOME_TYPE
## grouped bar charts
# OCCUPATION_TYPE
ggplot(train6, aes(fill=TARGET,  x=OCCUPATION_TYPE)) + 
  geom_bar(position='dodge') + 
  theme(text = element_text(size=20), 
        axis.text.x = element_text(angle=45, hjust=1)) + 
  labs(title='Default Status by Occupation Type', y='Count')
# plot %
plotty <- train6[, c('OCCUPATION_TYPE', 'ORGANIZATION_TYPE', 'NAME_INCOME_TYPE', 'TARGET')]
head(plotty)
occ_type_pct <- plotty %>% group_by(OCCUPATION_TYPE) %>% summarise(def_pct = sum((TARGET == 1)/n()) * 100)

plotty %>% group_by(OCCUPATION_TYPE) %>% summarise(def_pct = sum((TARGET == 1)/n()) * 100) %>% 
  ggplot(aes(x=OCCUPATION_TYPE, y=def_pct)) +
  geom_bar(position='dodge', stat='identity', fill='#073763') + 
  theme(text = element_text(size=20), 
        axis.text.x = element_text(angle=45, hjust=1)) + 
  labs(title='Default Status by Occupation Type', y='% Default')


# ORGANIZATION_TYPE
ggplot(train6, aes(fill=TARGET,  x=ORGANIZATION_TYPE)) + 
  geom_bar(position='dodge') + 
  theme(text = element_text(size=12), 
        axis.text.x = element_text(angle=50, hjust=1)) + 
  labs(title='Default Status by Organization Type', y='Count')
# plot by pct
plotty %>% group_by(ORGANIZATION_TYPE) %>% summarise(org_def_pct = sum((TARGET == 1)/n()) * 100) %>% 
  ggplot(aes(x=ORGANIZATION_TYPE, y=org_def_pct)) +
  geom_bar(position='dodge', stat='identity', fill='#073763') + 
  theme(text = element_text(size=20), 
        axis.text.x = element_text(angle=45, hjust=1)) + 
  labs(title='Default Status by Organization Type', y='% Default')
# combine factor levels
str(plotty)
unique(plotty$ORGANIZATION_TYPE)
plotty$ORGANIZATION_TYPE <- fct_collapse(plotty$ORGANIZATION_TYPE, 
             BusinessEntity = c('Business Entity Type 1', 'Business Entity Type 2', 'Business Entity Type 3'), 
             Industry = c('Industry: type 1', 'Industry: type 2', 'Industry: type 3','Industry: type 3', 'Industry: type 4', 'Industry: type 5', 'Industry: type 6', 'Industry: type 7', 'Industry: type 8', 'Industry: type 9', 'Industry: type 10', 'Industry: type 11', 'Industry: type 12', 'Industry: type 13'),
             Trade = c('Trade: type 1', 'Trade: type 2', 'Trade: type 3', 'Trade: type 4', 'Trade: type 5', 'Trade: type 6', 'Trade: type 7'), 
             Transport = c('Transport: type 1', 'Transport: type 2', 'Transport: type 3', 'Transport: type 4')
)

str(plotty)        
# bar plot with combined factor levels
ggplot(plotty, aes(fill=TARGET,  x=ORGANIZATION_TYPE)) + 
  geom_bar(position='dodge') + 
  theme(text = element_text(size=12), 
        axis.text.x = element_text(angle=50, hjust=1)) + 
  labs(title='Default Status by Organization Type', y='Count')
# plot by pct (colour gradient sorted)
plotty %>% group_by(ORGANIZATION_TYPE) %>% summarise(org_def_pct = sum((TARGET == 1)/n()) * 100) %>% 
  ggplot(aes(x=ORGANIZATION_TYPE, y=org_def_pct, fill=org_def_pct)) +
  geom_bar(position='dodge', stat='identity') + 
  theme(text = element_text(size=10), 
        axis.text.x = element_text(angle=45, hjust=1)) + 
  labs(title='Default Status by Organization Type', y='% Default') +
  scale_fill_gradient2(low='azure4', high='#073763')

plotty %>% group_by(ORGANIZATION_TYPE) %>% summarise(org_def_pct = sum((TARGET == 1)/n()) * 100) %>% sort(org_def_pct)

# NAME_INCOME_TYPE
ggplot(train6, aes(fill=TARGET,  x=NAME_INCOME_TYPE)) + 
  geom_bar(position='dodge') + 
  theme(text = element_text(size=15), 
        axis.text.x = element_text(angle=50, hjust=1)) + 
  labs(title='Default Status by Income Type', y='Count') 

sum(train6$NAME_INCOME_TYPE == 'Businessman') # 10
sum(train6$NAME_INCOME_TYPE == 'Student') # 18
sum(train6$NAME_INCOME_TYPE == 'Unemployed') # 19

plotty %>% group_by(NAME_INCOME_TYPE) %>% summarise(sum((TARGET == 1)/n()) * 100)
# plot by pct
plotty %>% group_by(NAME_INCOME_TYPE) %>% summarise(nit_def_pct = sum((TARGET == 1)/n()) * 100) %>% 
  ggplot(aes(x=NAME_INCOME_TYPE, y=nit_def_pct)) +
  geom_bar(position='dodge', stat='identity', fill='#073763') + 
  theme(text = element_text(size=15), 
        axis.text.x = element_text(angle=45, hjust=1),
        axis.title.x = element_text(size = 14)) + 
  labs(title='Default Status by Income Type', y='% Default')

# -------- END OF DATA EXPLORATION ----------------

# ##### save train6 and test6 as R object
saveRDS(train6, file='train6.Rds')
saveRDS(test6, file='test6.Rds')

