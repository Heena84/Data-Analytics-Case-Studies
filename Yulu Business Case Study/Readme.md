Project Name : Yulu - Hypothesis Testing

Objective : 

The company wants to know:
•	Which variables are significant in predicting the demand for shared electric cycles in the Indian market?
•	How well those variables describe the electric cycle demands


### About the Dataset

* **Source:** Confidential / Proprietary data source.
* **Size:** 10886 rows and 12 features. 
* **Key Variables:** season, humidity, registered, count.

*Note: The raw dataset is omitted from this repository to protect data privacy and intellectual property.*

Tools Used:

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
  
Workflow :

1.	Data Cleaning
2.	Exploratory Data Analysis
3.	Hypothesis Testing
4.	Visualization
5.	Business Insights
   
Files Included :

| File | Description |
| Yulu_Business_Case_Study_Heena.ipynb| Analysis notebook |
| Business Case Study-Yulu-Heena Khan.pdf| Project report |

Key Insights:

Insights 1


- Rental count is right-skewed
- Most rentals are concentrated in lower-to-medium range.
________________________________________
Insights 2


- Rentals appear slightly higher on working days
- Fall season shows highest rentals
- Spring season shows lowest rentals
- Clear weather has highest rentals
- Bad weather significantly reduces rentals
________________________________________
Statistical Hypothesis Testing


Is there any significant difference between the no. of bike rides on weekdays and weekends?

H0: The demand of bikes on weekdays is greater or similar to the demand of bikes on weekend.

Ha: The demand of bikes on weekdays is less than the demand of bikes on weekend.

Let μ1 and μ2 be the average no. of bikes rented on weekdays and weekends respectively.

Mathematically, the above formulated hypothesis can be written as:

H0:μ1>=μ2

________________________________________

Visualizations:

![ Distribution-total-rentals](images/ Distribution-total-rentals.png)
![ workingday-vs-rentals](images/ workingday-vs-rentals.png)
![ season-vs-rentals](images/ season-vs-rentals.png)
![ weather-vs-rentals](images/ weather-vs-rentals.png)
![ Heatmap](images/ Heatmap.png)
![ Density-count](images/ Density-count.png)
![ Density-vs-count](images/ Density-vs-count.png)

________________________________________

Conclusion:

EDA based insights –


- Total 10,886 rows were present in the data set.
- Neither missing values, nor duplicate rows were found.
- 'temp' and 'atemp' columns were found to be highly correlated.
- Dropping one of them (atemp) to avoid multicollinearity.
- 'count', 'casual' and 'registered' columns were highly correlated.
- Dropping casual & registered columns to avoid multicollinearity.
- Outlier values were found in the 'count' column.

Insights from hypothesis testing 


- The no. of bikes rented on weekdays is comparatively higher than on weekends.
- The no. of bikes rented on regular days is comparatively higher than on holidays.
- The demand of bicycles on rent differs under different weather conditions.
- The demand of bicycles on rent is different during different seasons.
- The weather conditions are surely dependent upon the ongoing season.
- Miscellaneous observations -
- The distribution of 'count' column wasn't actually normal or near normal.
- Infact the column's distribution is found to be a bit skewed towards right.
________________________________________
Business Recommendations:

Generic recommendations -


- The demand of bikes on rent are usually higher during Weekdays.
- The demand of bikes on rent are usually higher during Regular days.
- The chances of person renting a bike are usually higher during Season 3.
- The chances of person renting a bike are usually higher during Weather condition 1.

Business Recommendations for Yulu

Increase Supply During High Demand


- Deploy more cycles during:
- Pleasant weather
- Office hours
- Summer/fall seasons 

Weather-Based Dynamic Planning


- Reduce deployment during heavy rain or storms
- Introduce weather-based pricing/promotions 

Corporate Commuter Focus


- Since working days show higher rentals:
- Partner with IT parks
- Expand metro connectivity zones
  
We recommend the company to maintain the bike stocks accordingly.

