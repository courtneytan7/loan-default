# Predicting Loan Default
A CRISP-DM approach to predicting loan default for a financial institution (FI).

## 1. Business Understanding
### 1.1 Business Objectives
The objective of this project is to build a prediction model that detects loans likely to default and determines contributing factors, to ultimately reduce credit risk and enhance profitability of the financial institution.
### 1.2 Analytics Goals
**Descriptive analytics** to determine the current loan default rate.

**Diagnostic analytics** to identify features that contribute towards loan default.

**Predictive analytics** to estimate the probability of loan default in existing data.
### 1.3 Analytics Strategy
Predict the probabilty of loan default and identify contributing features through the use of predictive models such as logistic regression, decision tree and random forest that can determine feature importance and predict a target variable. All analytics performed using R.
### 1.4 Project Plan
![image](https://github.com/user-attachments/assets/3f15fabd-0444-4547-90c4-15c354d8325b)
Using a public data set, data cleaning is first performed to correct erroneous values. It is followed by data understanding to explore and visualise relationships among the data. Next comes model building, an iterative process of training, evaluating and optimizing predictive models using various techniques before achieving the final model.
## 2. Data Understanding
### 2.1 Data Source
This project uses loan application data from the [Home Credit Default Risk data set](https://www.kaggle.com/c/home-credit-default-risk/data) sourced from Kaggle.
### 2.2 Data Description
|Rows|Columns|
|---|---|
|307511|122|

The response variable 'TARGET' takes two possible values:
* 0 - no default
* 1 - default
### 2.3 Data Quality
Issues with the data set:
* Missing values
* Inconsistencies
* Errors
* Nonsensical data
### 2.4 Preliminary Analysis

Preliminary analysis performed:

* Distribution of Target Variable
* Correlation of Features against Response Variable
* Distribution of EXT_SOURCE_3 (an external credit score)
* Distribution of DAYS_BIRTH (number of days prior to the loan application date the client was born)

