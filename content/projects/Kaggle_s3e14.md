+++
authors = ["Cheng-Han Shih"]
title = "PREDICTION OF BLUEBERRY YIELD"
date = "2023-06-05"
description = ""
categories = [
    "data-science"
]
tags = [
    "r",
    "machine-learning",
    "modeling",
    "data-processing"
]
# series = ["Theme Demo"]
+++

![](/images/Kaggle_s3e14/bluebarry.png#plt_center)

Blueberries are often hailed as a superfood due to their rich nutritional content, thus garnering high interest in their health benefits and culinary versatility. Among the various types of blueberries, wild blueberries stand out for their high content of vitamins, manganese, anthocyanins, carotenoids, potassium, zinc, and antioxidants. Notably, wild blueberries have a significantly higher antioxidant content compared to cultivated blueberries, making them a highly sought-after commodity in the agricultural market.

To maximize the yield of wild blueberries, researchers and growers are seeking innovative methods to predict and optimize production outcomes. One approach is the use of predictive modeling techniques, based on a rich set of predictor variables derived from field observations. These variables encompass various factors that influence the growth and productivity of wild blueberries.

# Introduction

In this study, we aim to develop a predictive model for estimating the yield of wild blueberries using data obtained from the wild blueberry yield prediction dataset provided in a Kaggle competition. Our analysis will focus on integrating various predictor variables, including environmental factors, pollinator densities, and plant characteristics, to build a robust predictive model.

Let’s take a look at the variables in the dataset:

* Clonesize (m²): The proportion of blueberries per square meter that are propagated asexually.

* Honeybee (m²/min): The density of honeybees per square meter in the field.

* Bumbles (m²/min): The density of bumblebees per square meter in the field.

* Andrena (m²/min): The density of Andrena bees per square meter in the field.

* Osmia (m²/min): The density of Osmia bees per square meter in the field.

* Max.U.T (Max of Upper TRange °F): The highest daily maximum temperature recorded during the entire blooming season.

* Min.U.T (Min of Upper TRange °F): The lowest daily maximum temperature recorded during the entire blooming season.

* A.U.T (Average of Upper TRange °F): The average daily maximum temperature during the entire blooming season.

* Max.L.T (Max of Lower TRange °F): The highest daily minimum temperature recorded during the entire blooming season.

* Min.L.T (Min of Lower TRange °F): The lowest daily minimum temperature recorded during the entire blooming season.

* A.L.T (Average of Lower TRange °F): The average daily minimum temperature during the entire blooming season.

* R.D (Raining Days): The total number of days with more than zero rainfall during the entire blooming season.

* A.R.D (Average Raining Days): The average number of rainy days during the entire blooming season.

* Fruitset: The proportion of flowers that eventually form fruit.

* Fruitmass (g): The average mass of an individual blueberry fruit (grams).

* Seeds: The average total number of seeds found in each blueberry fruit.

**Response Variable: Yield**

[Figure 1: Data Table 1](/images/Kaggle_s3e14/datatable1.png)

[Figure 2: Data Table 2](/images/Kaggle_s3e14/datatable2.png)

[Figure 3: Data Table 3](/images/Kaggle_s3e14/datatable3.png)

---

# EDA

## Correlation plot

Based on the preliminary analysis of the dataset, we observed from [Figure 4: Correlation Plot](/images/Kaggle_s3e14/corr.png?width=10&height=10) that Fruitset, Fruitmass, Seeds, and Yield are almost perfectly positively correlated with each other in the bottom right corner. We can expect a close relationship among them as a higher fruit set ratio boosts the base for yield, and so does the average mass of individual blueberry fruits.

Bumblebees and Osmia bees also show a positive correlation with Fruitset, Fruitmass, Seeds, and Yield. We speculate this may be because bee pollination is a necessary factor for fruiting in blueberries; hence, a higher density of bees in the field can lead to a better fruit set rate, subsequently affecting yield.

Additionally, the proportion of asexual reproduction shows a negative correlation with Fruitset, Fruitmass, Seeds, and Yield. Upon further investigation, we find that this is because the offspring from sexual reproduction yield higher than those from asexual reproduction.

The number of rainy days also correlates negatively with Fruitset, Fruitmass, Seeds, and Yield; as rain causes blossoms to wilt.

## Wild vs. Cultivated Blueberries

After researching, we know that blueberries on the market can generally be divided into wild and cultivated varieties. What are the differences between them?

Cultivated blueberries usually have a higher yield because they can be managed in controlled environments where soil, moisture, sunlight, and temperature can be precisely adjusted to maximize growth and yield.

Furthermore, cultivated blueberries often use high-yield varieties and can take advantage of modern agricultural techniques and mechanization to improve production efficiency and increase yield. In contrast, wild blueberries typically have lower yields because they grow in natural environments, constrained by natural conditions such as soil quality, water supply, and sunlight exposure, which cannot be controlled. Additionally, the growth of wild blueberries may be affected by natural predators and disasters, further impacting yield.

We approximated the growth days of blueberries into two types by dividing the number of rainy days by the average number of rainy days, as seen in [Figure 6: Berry Species](/images/Kaggle_s3e14/barrytype2.png). Type I blueberries, with a shorter growth cycle, have higher yields, which we suspect might be cultivated, whereas Type II blueberries, with a longer growth cycle, have lower yields, which we suspect might be wild.

How do we distinguish between them? In [Figure 5: Grandma Berry?](/images/Kaggle_s3e14/barrytype.png), we removed some individual data points not only because their growth cycle ratios were significantly different compared to the two types of blueberries but also because some data were very unreasonable. For instance, consider a blueberry that takes 50 times longer to grow than other blueberries; it might be termed a "Grandma Berry." After adjusting the data, there are still over 20,000 records left.

## The Impact of Growing Environment on Blueberries

Continuing our analysis, we sought to explore the characteristics brought about by the growing regions by observing the average temperatures of the production areas. We calculated a new average temperature by adding the highest maximum temperature and the highest minimum temperature and then taking the mean. Using this new average temperature, we broadly divided the production areas into four regions, as seen in [Figure 7: Four Areas](/images/Kaggle_s3e14/area.png).

After plotting a comparison chart of the regions and their yields, we acknowledged that blueberries also have an optimal temperature range for growth, with temperatures that are either too high or too low inhibiting their growth. We discovered that although the temperatures in Zones 2 and 3 are not the highest, their yields are the best among the four regions, as can be seen from [Figure 8: Compare Areas](/images/Kaggle_s3e14/area2.png).

This finding highlights the importance of an optimal temperature range for maximizing blueberry yield, suggesting that these zones likely offer conditions that are just right for balancing blueberry growth factors such as exposure to sunlight and temperature regulation, which are less than ideal in the other zones.

---

# Model Selection

## K-Fold Cross Validation

Before beginning model construction, we employ cross-validation to ensure the model does not overfit. We are using the K-fold cross-validation method, which we will briefly introduce here.

K-fold cross-validation divides the dataset into K equally sized subsets, known as folds, and then carries out K rounds of training and testing. In each iteration, one fold is used as the test set, while the remaining K-1 folds serve as the training set. After completing K iterations, the average of the performance metrics from each test is taken as the final assessment of the model's performance.

Cross-validation provides a more robust estimate of model performance because it involves multiple tests and training sessions on different subsets, reducing reliance on a single split and avoiding the impact of extreme sample combinations that could lead to model overfitting. In this model construction, we have set K to 5. This choice allows for a balanced trade-off between computation time and the thoroughness of the evaluation, providing a comprehensive insight into the model's capability to generalize across unseen data.

## Comparison of Model Results

We conducted individual adjustments for four different models. The competition involved about 1900 participants, and the scoring was based on the model’s Mean Absolute Error (MAE). The final ranking of the adjusted linear model was approximately 1570, the random forest ranked 1400, the XGBoost was lower at around 1030, and the best-performing model was LightGBM, ranked 334.

How did we achieve this? Data cleaning, feature engineering, and model tuning are essential steps. Next, we will provide a more detailed introduction to data modeling and adjustment processes.

## Is This a Well-Designed Problem?

Before diving into model specifics, our observations of the yield variable led us to suspect it resembled a categorical variable, although it appeared numeric. Ultimately, we treated it as a continuous variable. Treating this problem as a classification issue would result in approximately 500 categories, with some categories having only one sample, making it practically impossible to treat the variable as discrete for prediction purposes.

We also encountered some unreasonable data points. For instance, after standardizing the data, we found honeybee densities exceeding 46 standard deviations, which seemed highly suspicious. Considering that this variable had almost no impact on the model in interaction with other variables, we decided to remove Honeybees from our dataset.

However, this is just the beginning. Given earlier data anomalies, such as the "Grandma Berry" issue, we grew skeptical about the integrity of the dataset, even contemplating whether these could be deliberately inserted errors.

The dataset provided by Kaggle ostensibly used a technique of generating large datasets from small data pools, but a closer inspection revealed that some data points were similar or even nearly identical. Therefore, after completing our model construction, we suspect that the test set might also have been derived from the training set, raising concerns about the validity of our model evaluation and the general challenge design.

This scenario highlights a critical aspect of data science competitions: the quality and design of the dataset can significantly impact the feasibility of the problem and the interpretability of the results. As data scientists, it's crucial to critically evaluate the data, challenge assumptions, and understand the underlying structure of the dataset to develop robust and reliable models.

## Linear Model
The linear model has effectively captured the challenges we identified in the data. As seen from [Figure 9: Linear Model](/images/Kaggle_s3e14/linearmodel.png), the data indeed shows characteristics of discrete variables, although we have limited options to address this.

As previously noted, we observed that yield behaves like a categorical variable numerically, and the model might also pick up on this information. Therefore, when the model outputs predictions, it tends to predict categories, but incorrect categorization leads to significant errors. This issue is particularly severe in linear models, and although subsequent models perform much better in the middle range of the data, similar issues persist at the endpoints. We may not currently have a satisfactory solution to these kinds of problems.

Returning to the comparison of model strengths and weaknesses, the advantages of the linear model in this dataset include fast operation speed and high statistical interpretability, which allows for quick identification of significant outliers impacting the model. The downside is that the model's results are highly susceptible to outliers and depend on the linear relationships in the data, necessitating thorough data cleaning for effective results.

Given that the distribution of results from subsequent models is similar to that of the linear model, we are only showcasing Figure 9 and not presenting further results. This approach underscores the shared challenges across different models and highlights the need for robust methods to handle the peculiarities of the dataset we are dealing with.

## Random Forest
Random Forest models haven't been the focus of much discussion due to the relatively minor impact of model tuning and the greater influence of random seed variability compared to parameter adjustments.

In this dataset, one advantage of using Random Forest is that it generally performs better than the linear model right out of the box, with little to no tuning required. This might suggest that the data type itself is more suited to tree-based models, which typically handle categorical-like data structures better than linear approaches. However, it has not addressed the issues we encountered with the linear model, and therefore, the improvement in our results using Random Forest has been quite limited.

## XGBoost
When we began experimenting with tuning parameters for the XGBoost model, we made a significant discovery that greatly shifted our approach to model adjustment. Initially inspired by a reference in the original papers, we believed that a shallower tree depth was preferable, so we adjusted other parameters accordingly. However, after a series of tests, setting the tree depth to 5—deeper than I initially expected—yielded better model performance.

From my previous experience in model tuning, such a deep tree depth might typically lead to overfitting. However, in this instance, it enhanced the model's performance. I hypothesize that the overfitting induced by deeper trees might coincide with the observed distribution of the data, which appears to exhibit categorical characteristics within a continuous variable.

This outcome prompted me to reconsider whether the training and test datasets are derived from the same underlying processes. It raised the question of whether what we initially perceived as overfitting might actually be an optimal solution for this dataset—suggesting that the typical concerns about overfitting may not apply here. Indeed, in this dataset, a deeper tree depth did improve prediction accuracy, particularly in handling the extreme values, where it performed better than the other models.

## LightGBM
Continuing with the ideas developed from our work with XGBoost, in tuning the LightGBM model, we adopted strategies to generate more leaf nodes, increase the number of iterations, and use a lower learning rate. Ultimately, we set the number of leaf nodes to 28.

However, we observed that these leaf nodes often concentrated on specific branches, resulting in submodels that were even deeper than the trees in XGBoost. This also exceeded my expectations for the model. Similar to our findings with XGBoost, does this imply that more complex trees enhance the model's accuracy? Consequently, this has made LightGBM the best-performing single model in our current analysis. Although LightGBM achieved the highest overall accuracy among the four models, it compromised the prediction accuracy at the data extremes.

The success of LightGBM in this context suggests that the model's ability to handle complex patterns and interactions within the data, due to its deeper and more detailed decision paths, provides significant predictive benefits. However, the focus on increasing complexity with more leaf nodes and deeper trees, while beneficial for capturing the general trends and nuances in the majority of the data, may lead to less accurate predictions at the distribution's tails. This could be due to overfitting specific characteristics of the data that do not generalize well to the less frequent or more extreme cases.

This outcome highlights the trade-offs involved in model tuning: achieving high overall accuracy might come at the cost of weaker performance on outlier or extreme values. It underscores the importance of balancing model complexity with the need to maintain robustness across the entire range of data values, particularly in tasks where predictions at the extremes are critical. For future work, it might be beneficial to explore strategies that maintain the model's strength in the central range while improving its performance at the edges, possibly by incorporating techniques that penalize model complexity or by using ensemble methods to stabilize predictions at the extremes.

---

# Conclusion

After investing significant time and effort in feature engineering, parameter tuning, and model fitting improvements, we've reached some impressive conclusions and seen excellent performance in the model rankings. Our analysis led to three main takeaways:

1. Importance of Data Cleaning and Feature Engineering:
Data cleaning is crucial, as it allows us to identify and remove outliers, which can skew the results if unaddressed. The direct use of uncleaned data often leads to suboptimal model performance. Feature engineering, especially after understanding the types of blueberries and their growing regions, has significantly aided our subsequent analyses by creating features that capture essential aspects of the data.

2. Importance of Parameter Adjustment and Model Selection:
Adjusting parameters enhances the adaptability of models to different data characteristics. The choice of model also plays a critical role; while linear models are highly interpretable, they may not perform as well. Random Forest and XGBoost may not be as interpretable but offer more reasonable predictions for data extremes. LightGBM achieves the highest overall accuracy but at the cost of precision at the data extremes. Combining these models into a hybrid approach could potentially improve ranking scores further by leveraging the strengths of each.

3. Learning from Model Tuning:
The experience of adjusting model parameters has been particularly enlightening—akin to the saying, "traveling ten thousand miles is better than reading ten thousand books." Before completing this data analysis, I had not encountered cases where such adjustments could significantly enhance model performance. This process has deepened my understanding of data characteristics and modeling strategies.

**Future Work and Reflections**

Regarding this dataset, one potential approach could be to isolate more anomalies to form a new dataset for separate modeling, which could significantly enhance accuracy. Additionally, experimenting with hybrid models may be worthwhile, but it would require more trials to fine-tune the architecture of the mixed model to achieve better results.

Overall, participating in the Kaggle playground competition has been a highly educational experience. This analysis was a valuable exercise for me. I appreciate everyone who has followed along with this journey, and I look forward to further refining my skills in data analysis to produce even better outcomes.

The process of tackling a Kaggle competition is a vivid demonstration of how theoretical knowledge is tested and expanded in practical, real-world scenarios. Each step—from data cleaning to model optimization—provides insights into the complexities of data science and offers a platform to apply, fail, and learn from those failures.

Moving forward, the integration of more sophisticated modeling techniques and the exploration of new data features will continue to be a focus. The aim is not only to enhance model performance but also to deepen our understanding of the underlying patterns and anomalies within the data. Each dataset, with its unique challenges and opportunities, teaches valuable lessons that contribute to a more nuanced approach to problem-solving in the field of data science. Thank you for your attention, and let's keep pushing the boundaries of what's possible with data.