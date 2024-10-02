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

### 4.6. Model Building and Assessment
The following models were built using resampled data.

**Logistic Regression**

A logistic regression model was built using the variables determined during initial modelling, after eliminating multicollinearity (using VIF) and insignificant variables (based on p-value).
![image](https://github.com/user-attachments/assets/143d2907-c5c8-4935-94dd-c63e0d0b442b)
Compared to the initial model, the accuracy is lower but precision and recall improved significantly.
The model also indicated feature importance based on standardized coefficients.
![image](https://github.com/user-attachments/assets/f5c4a150-b79f-4a8b-a17f-d6812ae3c5f0)

**Decision Tree**

The decision tree model was trained on resampled data using all variables.
![image](https://github.com/user-attachments/assets/17079746-71e5-4a40-8809-7342f313063b)
![image](https://github.com/user-attachments/assets/bcb49a78-0bd4-4ae4-a63e-784c8685cdc3)
The decision tree splits the data according to only one feature - total income amount – at different points. Looking at the first terminal node from the left, the default rate is the lowest at 18% when the total income amount is less than $156,000. On the other hand, The default rate is highest when the income is > $156,000 and <$380,000.

**Random Forest**
A random forest model was trained on resampled data using all variables and default settings.
![image](https://github.com/user-attachments/assets/6bff5078-a562-462b-bf97-4065535b0689)
Running the model on the train set yielded good results, but on the validation set, the model performed rather poorly, with precision and recall at 24 and 14% respectively. This suggests overfitting.
The top five predictors of loan default as determined by the random forest model are (1) total income amount, (2) external source 3, (3) external source 2, (4) external source 1, and (5) number of 60 days past due in the client’s social circle.
![image](https://github.com/user-attachments/assets/101cc6ff-9cfc-45ae-9b90-582dffacbfa1)

**Model Comparison**

![image](https://github.com/user-attachments/assets/dcc76b4e-e976-421d-8fbe-12c2301f11c3)

Among the three models, the decision tree can be ruled out as it has very low precision despite having high accuracy. Between the logistic regression and random forest models, logistic regression performed better in terms of recall, while random forest was superior in accuracy and precision. Judging from the F1 score, the logistic regression ultimately performed the best among the three.
However, since random forests have many advantages such as being good at handling large datasets, an attempt was made to train a random forest model using the training data determined by the logistic regression model.

**Random Forest - Model Tuning**

*Optimise Training Data*

A random forest model was built using features in the logistic regression data set – free of multicollinearity and insignificant variables.
![image](https://github.com/user-attachments/assets/8c3f1b8a-b9a0-4712-b4ea-e1122ded401b)
The F1 score improved over the previous random forest model, and is also higher than the logistic regression model.

*Optimise ntree and mtry*

The number of trees grown (ntree) and number of predictors sampled for splitting at each node (mtry) were also optimized. The parameter values that minimised OOB error were ntree = 500 and mtry = 5.
![image](https://github.com/user-attachments/assets/3a8b8834-c9c5-4845-80b2-ff25340f756e)

**Final Model**

The final model was built using features from the logistic regression data set and optimised parameters.
![image](https://github.com/user-attachments/assets/95277e50-7105-4db8-a7c4-232d85d9a3ab)
The performance of this optimized random forest model is the best among the previous models, with a recall of 60.2% and F1 score of 26.1%.
The top five features are (1) EXT_SOURCE_3, (2) EXT_SOURCE_2, (3) DEF_60_CNT_SOCIAL_CIRCLE, (4) EXT_SOURCE_1, (5) YEARS_EMPLOYED.
![image](https://github.com/user-attachments/assets/7b905cb1-b52f-402e-9d97-df6600af2a17)

## 5. Evaluation
### 5.1. Results
![image](https://github.com/user-attachments/assets/d3890994-a4dc-4009-9a2f-5b3c03e95ae5)
The final model achieves all three objectives. From historical data, the observed default rate is 0.08%. The model identified important features that contribute towards default, the top 5 being EXT_SOURCE_3, EXT_SOURCE_2, DEF_60_CNT_SOCIAL_CIRCLE, EXT_SOURCE_1, and YEARS_EMPLOYED. Scoring the final model on future data will make predictions on whether a client defaults or not, allowing the FI to take mitigative action.
### 5.2. Challenges
Several challenges were faced during this project.
1. Computational limitations resulted in unnecessary delays. Model building and scoring was time consuming and computationally demanding. 
2. Vague data descriptions limited data understanding in the initial stages of the project. A deeper understanding of each column could have resulted in more meaningful manipulation of values. 
3. High dimensionality posed some difficulty in building models – they were prone to overfitting and over complexity.
### 5.3. Improvements
Using more data in model building may be helpful. This project only considered loan application data, but credit bureau data previous loan data might add more insight. Another improvement is to experiment with a higher ntree value in the random forest model. This model only considered 500 due to computational constraints, but increasing it could potentially reduce error.
## 6. Conclusion
This project aims to build a predictive model using logistic regression, decision tree and random forest to predict loan default. The final model used a random forest algorithm, optimised in training data, ntree and mtry. It achieved an accuracy of 72.5%, precision of 16.7%, recall of 60.2% and F1 score of 26.1%. The top 5 features that contribute to loan default are EXT_SOURCE_3, EXT_SOURCE_2, DEF_60_CNT_SOCIAL_CIRCLE, EXT_SOURCE_1, and YEARS_EMPLOYED.
