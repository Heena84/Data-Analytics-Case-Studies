# Scaler Learner Salary Segmentation — Clustering Case Study

Segmenting 150k+ Scaler learners by salary and experience using manual peer-group flags (Designation, Class, Tier) and unsupervised learning (K-Means and Hierarchical clustering), then turning the findings into business recommendations.

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![scikit-learn](https://img.shields.io/badge/scikit--learn-clustering-orange)
![Status](https://img.shields.io/badge/status-complete-brightgreen)

---

## Table of contents
1. [Business problem](#business-problem)
2. [Dataset](#dataset)
3. [Approach](#approach)
4. [Key results](#key-results)
5. [Key insights](#key-insights)
6. [Business recommendations](#business-recommendations)
7. [Repository structure](#repository-structure)
8. [How to run](#how-to-run)
9. [Limitations and future work](#limitations-and-future-work)
10. [Author](#author)

---

## Business problem

Scaler, an upskilling platform, wants to understand **how its learners are distributed across salary and experience levels** so it can:

- design programmes for the right learner segments,
- benchmark salaries by role, company and experience,
- identify learners who are paid below their peers and could benefit from upskilling or job-switch support,
- improve the quality of the data it collects.

## Dataset

One row per CTC (annual compensation, in INR) update per learner.

| Column | Description |
|---|---|
| `company_hash` | Anonymised employer name |
| `email_hash` | Anonymised learner identifier |
| `orgyear` | Year the learner joined the workforce |
| `ctc` | Annual compensation (₹) |
| `job_position` | Job role (free text) |
| `ctc_updated_year` | Year the CTC was last updated |

- **205,843 rows**, 153,443 unique learners (about 93k rows share an email hash with another row).
- The dataset is provided by Scaler for academic use and is **not included** in this repository. Place `scaler_hashed_for_students.csv` in the project folder to run the notebook.

## Approach

### 1. Exploratory data analysis
Shape, data types, `category` conversion, missing values, statistical summary, univariate plots (distributions, boxplots, count plots) and bivariate plots (CTC vs role, experience and update year), each with written observations.

### 2. Data pre-processing
| Step | Method |
|---|---|
| Company names | Regex cleaning (lower-casing, punctuation removal, whitespace collapse, junk numeric names → `Unknown`) |
| Invalid values | Impossible joining years removed (`orgyear` outside 1980–2021) |
| Repeated learners | Latest CTC record kept per learner (205,809 → 153,443 records) |
| CTC outliers | IQR rule applied on **log10(CTC)**, accepted range ₹1.01 lakh – ₹92.38 lakh (4.66% removed) |
| Missing values | **KNN imputation** (k=5) for experience and removed CTC values, used for clustering only |
| Encoding | Role one-hot encoding, company frequency encoding |
| Scaling | `StandardScaler` on log CTC and experience |

### 3. Manual clustering (peer-group flags)
Each learner's CTC is compared with the mean CTC of a peer group (1 = above, 2 = equal, 3 = below):

- **Designation flag** — company + job position + years of experience
- **Class flag** — company + job position
- **Tier flag** — company

### 4. Unsupervised learning
Hopkins statistic, elbow method, silhouette analysis, **K-Means**, and **hierarchical clustering** (Ward linkage on a sample) with a K-Means vs hierarchical agreement check (Adjusted Rand Index).

## Key results

### Manual flags

| Flag | Coverage | Above mean | Below mean | Median CTC (above vs below) |
|---|---|---|---|---|
| Designation | 38.9% | 15.9% | 22.9% | ₹15L vs ₹6.4L |
| Class | 62.3% | 24.8% | 37.4% | ₹18L vs ₹7L |
| Tier | 78.0% | 29.8% | 48.2% | ₹19L vs ₹7.1L |

### K-Means segments (K = 2, silhouette 0.41)

| Segment | Learners | Median CTC | Median experience |
|---|---|---|---|
| Lower-pay / early career | 94,712 (61.7%) | ₹6.8 lakh | 4 years |
| Higher-pay / experienced | 58,731 (38.3%) | ₹19.9 lakh | 9 years |

- Hopkins statistic: **0.928** (strong clustering tendency).
- Hierarchical clustering gives a similar split (silhouette 0.376); agreement with K-Means: **ARI = 0.654**.

![K-Means Segment](images/K-Means Segment.png)

![Elbow and Silhouette](images/Elbow and Silhouette.png)


## Key insights

- **CTC is extremely right-skewed** (skewness ≈ 16; median ₹9.5L vs mean ₹22.7L). Medians and log-scale analysis are essential.
- **Experience alone explains only part of pay** (Spearman correlation with log CTC = 0.34); role and employer matter too.
- Median pay is **2.9× higher** in the experienced segment, and Engineering Leadership is about 11× more concentrated there (8.8% vs 0.8%).
- Adding role one-hot columns *lowers* silhouette (0.405 → 0.271): segments are driven by **pay and experience, not job family**.
- Coverage rises from Designation to Tier, but like-for-like fairness falls: the experience gap between above- and below-mean learners widens, so broader flags increasingly measure seniority.
- **30,354 learners (20.7%)** are below the peer mean on both Designation and Tier.
- Data/ML roles show a median of ₹12L vs ₹10L overall (about a 20% premium).
- **Data quality is a major issue:** 25.5% of roles are missing, there are 1,016 distinct free-text role values, and 4.66% of CTC values are implausible (about twice as many too low as too high, suggesting unit errors).

## Business recommendations

1. **Two programme families:** placement and interview-prep tracks for the early-career 62%; leadership and system-design tracks for the experienced 38%.
2. **Salary-benchmark tool** using medians and P25/P75 bands with a fallback chain (Designation → Class → Tier) and clear labelling of the comparison level.
3. **Target "paid below peers" learners** (20.7%) with upskilling, negotiation coaching and job-switch support.
4. **Pay-progression marketing** (median pay about 2.9× higher from ~4 to ~9 years), presented as an indicative range, not a guarantee.
5. **Employer partnerships** prioritised by sample size and median CTC; validate small-sample companies before building outreach.
6. **Position data/ML as a moderate premium** and test demand before investing heavily.
7. **Fix data capture:** role dropdown, CTC range and unit validation, joining-year validation, and de-duplicated or timestamped profile updates.

## Repository structure

```
.
├── Scaler_Clustering_Corrected_Final.ipynb   # Full analysis notebook
├── README.md                                 # Project documentation
└── scaler_hashed_for_students.csv            # Dataset (not included — add locally)
```

## How to run

**Option 1 — Google Colab**
1. Open `Scaler_Clustering_Corrected_Final.ipynb` in Colab.
2. Run all cells and upload `scaler_hashed_for_students.csv` when prompted.

**Option 2 — Locally**
```bash
git clone https://github.com/Heena84/Data-Analytics-Case-Studies/Scaler%20Clustering.git
cd Data-Analytics-Case-Studies/Scaler%20Clustering
pip install pandas numpy matplotlib seaborn scikit-learn scipy jupyter
# place scaler_hashed_for_students.csv in this folder
jupyter notebook Scaler_Clustering_Corrected_Final.ipynb
```

**Configuration (first code cell):** `DEDUPLICATE_LEARNERS`, `IQR_MULTIPLIER`, `MIN_GROUP_SIZE`, `MIN_COMPANY_RECORDS` and `K_FINAL` (set an integer to override the silhouette-chosen K).

**Tech stack:** Python, pandas, NumPy, Matplotlib, Seaborn, scikit-learn, SciPy.

## Limitations and future work

- Self-reported, cross-sectional data; no inflation adjustment across update years.
- Outlier removal caps the top end at about ₹92 lakh, so true top earners are excluded.
- Company names are anonymised, so employers cannot be linked to industry or size; role is missing for about a quarter of learners.
- Silhouette of ~0.4 indicates moderate separation: segments summarise a continuum rather than sharply separated groups.
- **Future work:** try K = 3 for finer segments, standardise role text with NLP, add industry and skill features, and test density-based clustering (DBSCAN / HDBSCAN) or Gaussian mixture models.

## Author

**Heena**
- GitHub: [Heena84](https://github.com/your-username)
- LinkedIn: www.linkedin.com/in/heena-khan-4227335b

---
*This project was completed as part of a data science case study. The dataset belongs to Scaler and is used for educational purposes only.*
