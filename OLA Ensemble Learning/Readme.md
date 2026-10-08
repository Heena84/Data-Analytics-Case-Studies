# 🚖 Ola Driver Attrition Prediction — Ensemble Learning (Bagging & Boosting)

**Business Case Study | Data Analytics & Machine Learning**
Submitted by: **Heena Khan**

> Predicting which Ola drivers are likely to leave, and identifying the factors associated with attrition, using Random Forest (Bagging) and Gradient Boosting (Boosting).

📓 **Notebook:** [Google Colab](https://drive.google.com/file/d/10BYNm51YvDi61mQKqPkwMbwrIDF7wWM/view?usp=sharing)
📄 **Files in this repo:** Colab notebook export (PDF) and Business Case Study insights report (PDF)

---

## 📌 Table of Contents

1. [Problem Statement](#-problem-statement)
2. [Dataset](#-dataset)
3. [Concepts Used](#-concepts-used)
4. [Approach](#-approach)
5. [Key Insights](#-key-insights)
6. [Model Results](#-model-results)
7. [Feature Importance](#-feature-importance)
8. [Business Recommendations](#-business-recommendations)
9. [Limitations & Future Work](#-limitations--future-work)
10. [Repository Structure](#-repository-structure)
11. [How to Run](#-how-to-run)
12. [Tech Stack](#-tech-stack)
13. [Author](#-author)

---

## 🎯 Problem Statement

Recruiting and retaining drivers is one of Ola's toughest challenges. Driver churn is high, and drivers can stop working for the platform at any time or move to a competitor depending on rates. Acquiring new drivers is far more expensive than retaining existing ones, and frequent exits also hurt organisational morale.

As a data scientist in Ola's Analytics Department, the task is to **predict whether a driver will leave the company** using:

- **Demographics:** city, age, gender, education
- **Tenure information:** joining date, last working date
- **Performance history:** quarterly rating, monthly business value, grade, income

---

## 📊 Dataset

| Item | Detail |
|---|---|
| Source file | `ola_driver_scaler.csv` |
| Raw shape | 19,104 rows × 14 columns (monthly records) |
| Unique drivers | 2,381 |
| Period | Monthly reporting, 2019–2020 |
| Cities | 29 |
| Final modelling dataset | 2,381 rows (one row per driver) |

### Column profile

| Column | Description |
|---|---|
| `MMM-YY` | Reporting date (monthly) |
| `Driver_ID` | Unique driver ID |
| `Age` | Age of the driver |
| `Gender` | Male: 0, Female: 1 |
| `City` | City code |
| `Education_Level` | 0 = 10+, 1 = 12+, 2 = Graduate |
| `Income` | Monthly average income |
| `Dateofjoining` | Joining date |
| `LastWorkingDate` | Last working date (present only if the driver left) |
| `Joining Designation` | Designation at joining |
| `Grade` | Grade at the time of reporting |
| `Total Business Value` | Business acquired in the month (negative values indicate cancellations/refunds/EMI adjustments) |
| `Quarterly Rating` | Rating from 1 to 5 (higher is better) |

### Data quality notes

- `LastWorkingDate` is missing for **91.54%** of records. This is **not a data-quality problem**: a missing value means the driver is still working. It was used to build the target, not imputed.
- `Age` (61 missing, 0.32%) and `Gender` (52 missing, 0.27%) were imputed using **KNN imputation**.
- Negative `Total Business Value` was retained because it is a valid business signal, not an error.
- No duplicate rows were found.

---

## 🧠 Concepts Used

- Ensemble Learning: **Bagging** (Random Forest)
- Ensemble Learning: **Boosting** (Gradient Boosting)
- **KNN Imputation** of missing values
- Handling an **imbalanced dataset** (SMOTE + class weights)
- Hyperparameter tuning with `RandomizedSearchCV`
- Driver-level feature engineering from repeated monthly records

---

## 🔬 Approach

1. **Data understanding:** shape, dtypes, summary statistics, duplicates, missing values.
2. **Univariate analysis:** age, income, rating, grade, gender, education, city, business value.
3. **Aggregation to driver level:** the raw data has repeated monthly rows per driver, so it was aggregated so that *one driver = one observation*.
4. **Feature engineering:**
   - `Rating_Increase`: 1 if the driver's quarterly rating rose at any point
   - `Income_Increase`: 1 if the driver's income rose at any point
   - `Target`: 1 if `LastWorkingDate` is present (driver left), else 0
   - `Tenure_Years`, `Year_of_Joining`, `Reportings` (number of monthly reports)
   - Mean/max/last aggregates of income, grade, business value and rating
5. **Encoding:** one-hot encoding of `City` (`drop_first=True`), giving 46 features.
6. **Train/test split:** 80/20, stratified, `random_state=42`.
7. **KNN imputation** (`n_neighbors=5`), fitted on the training set only to avoid leakage.
8. **Standardisation** with `StandardScaler` (fitted on train only).
9. **Class imbalance:** SMOTE applied to the training set only (1,292 vs 612 balanced to 1,292 vs 1,292).
10. **Modelling:** Random Forest and Gradient Boosting, then tuned versions of both with `RandomizedSearchCV` (20 iterations, 5-fold CV, ROC-AUC scoring).
11. **Evaluation:** accuracy, precision, recall, F1, ROC-AUC, confusion matrices and ROC curves on the held-out test set (477 drivers).

---

## 💡 Key Insights

| Area | Finding |
|---|---|
| **Income** | Median income of churned drivers (₹51,630) is about **₹12,002 (~19%) lower** than retained drivers (₹63,632). |
| **Income growth** | Only **6.82%** of drivers whose income increased left, versus **69.02%** of those whose income did not increase. |
| **Rating improvement** | **80.49%** of drivers with no rating increase left, versus **43.99%** of those whose rating increased. |
| **Grade** | Attrition falls as grade rises: Grade 1 ≈ 80.4%, Grade 2 ≈ 70.2%, Grades 3–5 ≈ 51–54%. The relationship is not perfectly monotonic (Grade 5 is not the lowest). |
| **City** | Wide variation across cities: C13 (81.7%), C17 (77.5%), C23 (77.0%), C2 (76.4%) are the highest. |
| **Tenure** | Median tenure of churned drivers is 0.48 years vs 0.58 years for retained, pointing to early tenure as a risk period. |
| **Trend vs snapshot** | Performance *trajectory* (is the rating/income improving?) is more informative than a single snapshot value. |

> ⚠️ These are observed associations in this dataset and do not prove causation. See [Limitations](#-limitations--future-work).

---

## 📈 Model Results

Evaluated on the held-out test set (477 drivers; 324 churned, 153 retained).

| Model | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| Random Forest | 0.9182 | 0.9279 | **0.9537** | 0.9406 | 0.9639 |
| Tuned Random Forest | 0.9203 | 0.9333 | 0.9506 | 0.9419 | 0.9627 |
| Gradient Boosting | **0.9224** | **0.9443** | 0.9414 | **0.9428** | 0.9677 |
| Tuned Gradient Boosting | 0.9161 | 0.9329 | 0.9444 | 0.9387 | **0.9688** |

**Confusion matrices (test set)**

| | RF: Pred 0 | RF: Pred 1 | GB: Pred 0 | GB: Pred 1 |
|---|---|---|---|---|
| **Actual 0** | 129 | 24 | 135 | 18 |
| **Actual 1** | 15 | 309 | 19 | 305 |

**Takeaways**

- All four models perform similarly (ROC-AUC ≈ 0.96–0.97).
- Random Forest has the highest churn **recall** (309 of 324 churners caught; 15 missed).
- Gradient Boosting has the best accuracy, precision and F1.
- Tuned Gradient Boosting has the highest ROC-AUC, but tuning did **not** improve every metric. Tuned Random Forest's ROC-AUC dropped slightly (0.9639 → 0.9627), so each tuned model was checked on the same hold-out set rather than assumed to be better.

---

## 🔍 Feature Importance

| Rank | Random Forest | Gradient Boosting |
|---|---|---|
| 1 | Year_of_Joining (0.170) | Quarterly_Rating (0.380) |
| 2 | Quarterly_Rating (0.118) | Year_of_Joining (0.345) |
| 3 | Tenure_Years (0.092) | Reportings (0.132) |
| 4 | Reportings (0.080) | Tenure_Years (0.053) |
| 5 | Total_Business_Value (0.061) | Average_Business_Value (0.013) |

Both models agree that rating, tenure-related features and business value carry most of the predictive signal.

---

## ✅ Business Recommendations

1. **Driver churn early-warning system:** score every driver with a churn probability (e.g. Low 0–30%, Medium 30–60%, High 60–100%). Thresholds should be validated against business costs, not treated as universal.
2. **Focus on income growth:** monitor income trends, flag stagnant earnings, review incentives, improve demand allocation and investigate city-level earning differences.
3. **Monitor rating trends:** don't wait for a poor rating; trigger an intervention when ratings stagnate.
4. **New-driver retention programme:** strengthen onboarding, earnings monitoring, performance feedback and incentive communication in the first 3 to 6 months.
5. **City-specific retention:** investigate high-attrition cities (C13, C17, C23, C2) instead of applying one incentive everywhere. Compare income, income growth, rating, business value, tenure and incentives.
6. **Value × churn-risk matrix:** combine predicted churn probability with driver business value so that high-value, high-risk drivers get attention first.
7. **Choose the operating model on business cost, not ROC-AUC alone:** consider recall, precision, the cost of contacting a driver, the cost of losing one and the retention incentive cost.

---

## ⚠️ Limitations & Future Work

Being clear about the limits of the analysis:

- **Small group behind the income finding:** only about 1.8% of drivers (≈44) show an income increase, so the 6.82% attrition figure rests on a very small sample. Treat it as a strong signal worth investigating, not a precise estimate.
- **Possible target leakage in features:**
  - `Tenure_Years` is computed from `LastWorkingDate` for churned drivers (and from the last reporting date for active ones), so it partly encodes the outcome. `LastWorkingDate` and `Tenure_Days` were dropped, but `Tenure_Years` was retained.
  - `Reportings` (number of monthly records) and last-observed `Quarterly_Rating`/`Grade` are only fully known after a driver has left or the period has ended.
  - `Year_of_Joining` ranks highly partly because of the observation window (2019–2020).

  These likely inflate the ROC-AUC of ~0.96–0.97. For a true early-warning model, retrain using only information available *before* the prediction date.
- **Date handling:** date strings were parsed without an explicit day-first format, and a few drivers show negative tenure (minimum −27 days). Specifying formats explicitly and validating joining vs reporting dates is recommended.
- **Correlation ≠ causation:** low income, no rating improvement and city are associated with attrition, but this analysis does not establish causes.

**Future work**

- Use recent-window features: last 3-month income, rating and business-value trends.
- Build cohort-level retention analysis by joining year/month.
- Add time-based train/test splits and cost-sensitive threshold selection.
- Try additional boosting libraries (XGBoost, LightGBM) and calibrated probabilities.

---

## 📁 Repository Structure

```
Ola-Driver-Attrition-Ensemble-Learning/
│
├── README.md
├── OLA_Ensemble_Learning.ipynb                      # Colab notebook (add exported .ipynb)
├── OLA_-_Ensemble_Learning-Heena.pdf                # Notebook export (code + outputs)
├── Business_Case_Study-OLA_Ensemble_Learning-Heena.pdf   # Insights & recommendations report
└── data/
    └── ola_driver_scaler.csv                        # (optional) dataset
```

---

## ▶️ How to Run

1. Open the notebook in [Google Colab](https://drive.google.com/file/d/10BYNm51YvDi61mQKqPkwMbwrIDF7wWM/view?usp=sharing).
2. Upload `ola_driver_scaler.csv` when prompted (or mount your Drive).
3. Run all cells from top to bottom.

To run locally:

```bash
pip install pandas numpy matplotlib seaborn scikit-learn imbalanced-learn
jupyter notebook OLA_Ensemble_Learning.ipynb
```

> The notebook uses `google.colab.files.upload()`. When running locally, replace it with `pd.read_csv("path/to/ola_driver_scaler.csv")`.

---

## 🛠️ Tech Stack

**Python** · Pandas · NumPy · Matplotlib · Seaborn · Scikit-learn · Imbalanced-learn (SMOTE) · Google Colab

---

## 👩‍💻 Author

**Heena Khan**

*Business case study completed as part of the Scaler Data Science & Machine Learning programme.*

⭐ If you found this useful, consider starring the repo!
