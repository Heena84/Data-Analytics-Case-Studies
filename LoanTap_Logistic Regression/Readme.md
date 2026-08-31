# 💳 LoanTap – Loan Default Prediction

Predicting loan default risk using **Logistic Regression** and identifying borrower characteristics that can help LoanTap make better credit underwriting decisions.

---

## 📌 Project Overview

This case study focuses on the underwriting process for **LoanTap Personal Loans**.

The objective is to determine whether a credit line should be extended to a borrower and support decisions around repayment terms by predicting the likelihood of loan default.

---

## 🎯 Business Objective

* Identify factors associated with loan default.
* Build a classification model to predict **Fully Paid vs Charged Off** loans.
* Evaluate the model with a focus on **Precision, Recall, F1-score, and ROC-AUC**.
* Provide recommendations to improve credit-risk assessment.

---

## 📊 Dataset

The dataset contains borrower, loan, employment, and credit-related information.

Important variables include:

* Loan Amount
* Interest Rate
* Installment
* Employment Length
* Annual Income
* Home Ownership
* Debt-to-Income Ratio (DTI)
* Revolving Balance
* Credit Accounts
* Mortgage Accounts
* Public Records
* Bankruptcy Records
* Loan Status

### Target Variable

```text
0 → Fully Paid
1 → Charged Off
```

The target variable is **imbalanced**, with substantially more fully paid loans than charged-off loans.

---

## 🔍 Analysis Performed

### Exploratory Data Analysis

* Dataset structure and dimensions
* Missing-value analysis
* Duplicate checks
* Target-variable distribution
* Univariate and bivariate analysis
* Numerical and categorical variable analysis
* Correlation analysis
* Outlier detection

### Feature Engineering

* Created indicators for public records, mortgage accounts, and bankruptcy.
* Converted loan term and employment length into numerical variables.
* Encoded the target variable.
* Handled missing values using median/mode imputation.
* Removed high-cardinality and less-useful variables.
* Applied percentile-based capping for extreme values.
* One-hot encoded categorical variables.
* Standardized numerical features.

### Multicollinearity

A strong relationship was identified between **loan amount and installment**.

VIF analysis showed high multicollinearity, so `installment` was removed while retaining `loan_amnt`.

---

## 🤖 Model

A **Logistic Regression** model was developed to predict the probability of loan default.

Because the target variable is imbalanced, `class_weight="balanced"` was used to give greater importance to the minority **Charged Off** class.

The data was divided into training and testing sets using a **stratified train-test split**.

---

## 📈 Model Evaluation

The model was evaluated using:

* Confusion Matrix
* Precision
* Recall
* F1 Score
* ROC-AUC
* Precision-Recall Curve
* Custom classification threshold

### Why Accuracy Was Not Used Alone

Because approximately 80% of loans are fully paid, a model predicting "Fully Paid" for every borrower could achieve high accuracy while performing poorly at detecting defaults.

Therefore, **Recall and Precision for the Charged Off class are particularly important for credit-risk assessment.**

---

## 🔎 Key Insights

* The dataset is significantly imbalanced toward **Fully Paid** loans.
* Loan amount and installment showed strong multicollinearity.
* High-cardinality variables such as employment title and address were unsuitable for direct one-hot encoding.
* Extreme observations were capped rather than automatically removed because they may represent genuine borrowers.
* Detecting **Charged Off** borrowers is more important than maximizing overall accuracy.
* Probability thresholds can be adjusted depending on LoanTap's preferred balance between identifying risky borrowers and incorrectly rejecting good borrowers.

---

## 💡 Business Recommendations

### 1. Risk-Based Underwriting

Use predicted default probabilities to classify borrowers into different risk categories and support credit approval decisions.

### 2. Optimize the Classification Threshold

The default threshold of 0.50 does not necessarily provide the best business outcome. LoanTap can select a threshold based on the relative cost of missed defaults versus rejecting creditworthy customers.

### 3. Focus on Recall for High-Risk Borrowers

Missing an actual defaulter can be costly. Therefore, the model should be evaluated with particular attention to **Recall for the Charged Off class**.

### 4. Improve Model with Additional Data

The model can be further improved by incorporating additional borrower-level financial and behavioral information and validating it on newer datasets.

---

## 🛠️ Technologies & Libraries

**Python | Pandas | NumPy | Matplotlib | Seaborn | Scikit-learn | Google Colab**

---

## 📁 Project Files

* 📓 `LoanTap_Logistic_Regression.ipynb` – Complete analysis and model implementation
* 📄 `LoanTap_Case_Study_Report.pdf` – Detailed case study report
* 📄 `README.md` – Project documentation
* 📁 `images/` – Key visualizations

---

## 📝 Conclusion

The LoanTap case study demonstrates how **Exploratory Data Analysis, Feature Engineering, and Logistic Regression** can be applied to a real-world credit-risk problem.

The analysis emphasizes that credit-risk models should not rely on accuracy alone. **Precision, Recall, F1-score, ROC-AUC, and threshold selection** provide a more appropriate framework for evaluating the model's ability to identify potential loan defaults.

