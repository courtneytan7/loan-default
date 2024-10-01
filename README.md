# Predicting Loan Default
A CRISP-DM approach to predicting loan default for a financial institution (FI).

## 1. Business Understanding
### 1.1. Business Objectives
The objective of this project is to build a prediction model that detects loans likely to default and determines contributing factors, to ultimately reduce credit risk and enhance profitability of the financial institution.
### 1.2. Analytics Goals
**Descriptive analytics** to determine the current loan default rate.

**Diagnostic analytics** to identify features that contribute towards loan default.

**Predictive analytics** to estimate the probability of loan default in existing data.
### 1.3. Analytics Strategy
Predict the probabilty of loan default and identify contributing features through the use of predictive models such as logistic regression, decision tree and random forest that can determine feature importance and predict a target variable. All analytics performed using R.
### 1.4. Project Plan
![image](https://github.com/user-attachments/assets/3f15fabd-0444-4547-90c4-15c354d8325b)
Using a public data set, data cleaning is first performed to correct erroneous values. It is followed by data understanding to explore and visualise relationships among the data. Next comes model building, an iterative process of training, evaluating and optimizing predictive models using various techniques before achieving the final model.
## 2. Data Understanding
### 2.1. Data Source
This project uses loan application data from the [Home Credit Default Risk data set](https://www.kaggle.com/c/home-credit-default-risk/data) sourced from Kaggle.
### 2.2. Data Description
|Rows|Columns|
|---|---|
|307511|122|

The response variable 'TARGET' takes two possible values:
* 0 - no default
* 1 - default
### 2.3. Data Quality
Issues with the data set:
* Missing values
* Inconsistencies
* Errors
* Nonsensical data
### 2.4. Preliminary Analysis

Preliminary analysis performed:

* Distribution of Target Variable
  ![image](https://github.com/user-attachments/assets/75740a4c-5da8-4d03-8ce5-a0654fc5028c)

* Correlation of Features against Response Variable
  ![image](https://github.com/user-attachments/assets/e625c55e-9c3e-40ae-9b8d-1a2fd2098c64)

* Distribution of EXT_SOURCE_3 (an external credit score)
  ![image](https://github.com/user-attachments/assets/767f9662-a7e8-4e95-b4bb-bed2e105dbe2)

* Distribution of DAYS_BIRTH (number of days prior to the loan application date the client was born)
  ![image](https://github.com/user-attachments/assets/be0f4ffe-a001-4ea6-8579-87c6acd96ea1)

## 3. Data Preparation
### 3.1. Data Cleaning
The data was cleaned by addressing the following issues:
* Data types
* Missing values
* Derived columns
* Errors
* Redundant columns

### 3.2. Data Understanding
The following techniques were applied to understand the data:
* Feature association
* Feature importance
* Exploratory plots

Findings:

![image](https://github.com/user-attachments/assets/db9cb42c-53d2-431e-ad29-7452aca21a51)

## 4. Modelling
### 4.1. Modelling Techniques
To build a binary classification model, this project uses:
* Logistic regression
* Decision tree 
* Random forest

### 4.2. Evaluation Metrics
Evaluation metrics used are:
* Accuracy
* Precision
* Recall
* F1 score

### 4.3. Model Design (Train/Test Split)
The data set was split into train and validation sets in a 70/30 ratio (i.e. 70% of observations for training and 30% for validation).
![image](https://github.com/user-attachments/assets/932d1ffa-05ef-4f58-817b-410dfe6e975a)

### 4.4. Initial Modelling
![image](https://github.com/user-attachments/assets/9f403595-79bf-4241-8ea1-61279d5e2ee4)
The logistic regression model performance is similar across the train and validation sets – it has poor precision at 45 – 49% and even poorer recall at around 0.7%. The decision tree had no predictive power – precision and recall are 0 because it predicted all records as one class – the majority class. The random forest model performed well on the train set, but not on the validation set, which suggests overfitting.

### 4.5. Train Data Resampling
To address the imbalanced data, a resampling technique was applied. Random oversampling examples (ROSE) is a synthetic data generation technique that uses
bootstrapping and k-nearest neighbours to balance the classes. After resampling, a 50-50 distribution of target classes is achieved.
![image](https://github.com/user-attachments/assets/a3e4c366-6edd-4888-a25b-54f3daefb5b6)
![image](https://github.com/user-attachments/assets/e09f0930-4038-4366-803b-5b1c87bbd629)
