+++
authors = ["Cheng-Han Shih"]
title = "MOVIELENS 100K RECOMMENDER SYSTEM"
date = "2022-12-21"
description = ""
categories = [
    "data-science"
]
tags = [
    "r",
    "machine-learning",
    "modeling"
]
# series = ["Theme Demo"]
+++

Watching movies and series is one of the many leisure activities of modern people, and how to recommend a show that satisfies users has become a new battleground for various applications in the era of advanced technology. Our lives are filled with shadows of recommender systems, be it shopping websites, social media, or even search engines. Driven by my curiosity in this field and considering my master's thesis research might reference this knowledge, I took an elective course on recommender systems in the computer science department this semester. This final report stemmed from that course, where all reports were uniformly based on the MovieLens 100k dataset due to the professor's course planning. This report received the highest grade in the course.

# Data Introduction (Induction)

This dataset comes from the [grouplens](http://grouplens.org/datasets/movielens/) website, containing a total of 100,000 ratings from 943 users on 1682 movies. The data is divided into three parts: user-related data, movie-related data, and user ratings of movies. Let’s introduce each part we used.

1. User data:

    * user_id

    * age: User's age

    * gender

    * occupation: User's occupation

2. Movie data:

    * movie_id

    * movie_title

    * release_date: Movie release date

    * unknown ~ Western: There are 19 movie genres, each a binary variable (0 or 1) indicating whether the movie belongs to that genre.

3. User ratings of movies:

    * user_id

    * movie_id

    * rating

    * timestamp: The time the user rated the movie

Our ultimate goal is to use parts of this data to build a movie recommender system.

---

# Exploratory Data Analysis (EDA)

## Movie and User Data

We didn’t find much from the user data, but you can see the [user charts here](/html/MovieLens_100k_Recommender_System.html#User). Our analysis will focus on the movie data.

First, we performed a preliminary analysis of the movie release dates. By splitting the data into years and dates, we found an explosive growth in movie releases after 1993. Upon investigation, we discovered the following events that likely contributed to this surge:

1. CGI in "Jurassic Park": Directed by Steven Spielberg, this film marked a significant leap in CGI technology. The use of innovative computer-generated imagery to create realistic dinosaurs was unprecedented at the time. This pushed the boundaries of visual effects and changed the way future films were made.

2. Digital sound and Dolby SR-D sound system: 1993 also witnessed advancements in sound technology. Dolby SR-D (now known as Dolby Digital) was the first digital sound system available in commercial cinemas, first applied in "Jurassic Park", providing clearer and more dynamic sound experiences.

3. Kodak’s Cineon digital imaging system: Launched commercially in 1993, this system had a significant impact on the digital post-production sector of the film industry. Cineon allowed high-quality scanning, processing, and output of film, marking a crucial transition from traditional film processing to digital workflows.

We speculate that the reduced production costs and technical barriers, along with the public's renewed interest in movies following the release of "Jurassic Park", led to the prolific production of new films using these technologies.

![](/images/R_recommender/Rplot03.png)

However, upon further analysis, we found a significant issue with the release dates: over 60% of the movies were allegedly released on January 1st, which is clearly unreasonable. Consequently, we didn’t further explore the date-related information.

![](/images/R_recommender/Rplot04.png)

Next, we focused on movie genres, curious about the hidden information in this discrete and sparse matrix. We examined the number of movies in each genre, finding that Drama, Comedy, Action, Thriller, and Romance were the top five genres.

![](/images/R_recommender/Rplot.png)

Since each movie can belong to multiple genres, we observed the distribution of the number of genres per movie, finding that about 80% of the data had one to two genres, with three or more genres being rare. Due to the need for further processing for visualization, we used Jaccard and PCA methods for a deeper analysis.

![](/images/R_recommender/Rplot02.png)

## Jaccard

The Jaccard method, used to calculate the similarity between two sets \( U \) and \( V \), is defined as:

$$
J(U,V) = \frac{|U \cap V|}{|U \cup V|}
$$

To explain it more intuitively, let’s consider an example:

Suppose \( U \) and \( V \) are two customers entering a store. We want to know how similar their purchases are. If \( U \) buys water and chips, and \( V \) buys soda and chips, their intersection \( U \cap V \) is chips, and their union \( U \cup V \) is water, soda, and chips. Thus, their Jaccard similarity is \( \frac{1}{3} \). If they buy exactly the same items, their similarity is 1; if they buy no common items, their similarity is 0.

The Jaccard distance, a complementary concept, is:

$$
d_J(U,V) = 1 - \frac{|U \cap V|}{|U \cup V|}
$$

If two people buy exactly the same items, their distance is 0; if they buy no common items, their distance is 1.

Below are the original sparse matrix and the distance matrix obtained by transforming it using Jaccard. This transformation enhances subsequent dimensionality reduction and visualization.

![](/images/R_recommender/plot1.png)

![](/images/R_recommender/plot2.png)

Due to space limitations, I won't detail Principal Component Analysis (PCA) and t-Distributed Stochastic Neighbor Embedding (t-SNE) here, but I will add detailed explanations of these algorithms later.

## Dimension Reduction

Next, let’s visualize the movie genre data. Since a 3D space better illustrates the relationships, I also created an [interactive web link](/html/MovieLens_100k_Recommender_System.html#Dimension_Reduction) with original code and zoomable, rotatable images for better understanding.

In the first image, the top left three points represent Romance, Comedy, and Drama, which are closer to each other compared to other genres, indicating similar themes. The three points in the middle-right represent Action, Adventure, and Sci-Fi.

![](/images/R_recommender/Rplot05_enus.png)

The lower group requires rotation for better observation. In the second image, the three points at the bottom are Music, Animation, and Children.

![](/images/R_recommender/Rplot06_enus.png)

Finally, we can roughly divide the remaining points into three blocks: Thriller and Horror, Western and Documentary, and Film-Noir Crime movies.

![](/images/R_recommender/Rplot07_enus.png)

These images clarify the relationships between movie genres, and their distances can be reasonably explained. Due to time constraints, we didn’t include this visual information in subsequent models, but this data exploration was a new attempt at data processing with good classification results.

---

# Recommender System

Before building the recommender system, we reduced the data. We believed that for a rating to be used in constructing the recommender system, it needed to meet two conditions:

1. The user must have rated enough movies to ensure their ratings are based on a sufficient sample size, making their scores more reliable than those who rated only one or two movies.

2. The movie must have received enough ratings to be used in training the model.

After comparing different parameter settings, we decided to use users who had rated at least 50 movies and movies that had received at least 50 ratings as our training data. This reduced the ratings to 73,544, with 568 users and 603 movies from the original 943 users and 1682 movies.

We defined that a user rating a movie 4 or above was a positive review and used K-Fold Cross Validation (K=5) to ensure the model wouldn't overfit. Next, let’s briefly introduce the methods used in this analysis. The original code and recommended results are linked under each recommender system heading.

---

## [User-Based Collaborative Filtering](/html/MovieLens_100k_Recommender_System.html#User_Base_CF)

User-Based Collaborative Filtering (User-Based CF) is a recommendation method based on user similarity. It assumes that if two users rate similar items similarly, they are likely to rate other items similarly. The goal is to recommend items liked by users with similar rating behaviors to the target user.

Its advantages are ease of understanding and implementation, and good recommendation performance with a large amount of user rating data. However, as the number of users grows, the computational cost of calculating similarities becomes significant, leading to inefficiency. It also faces the cold start problem, where the system cannot define similarities for new items due to insufficient data.

---

## [Item-Based Collaborative Filtering](/html/MovieLens_100k_Recommender_System.html#Item_Base_CF)

Item-Based Collaborative Filtering (Item-Based CF) is a recommendation method based on item similarity. It assumes that if a user likes an item, they may like similar items. Therefore, by finding items similar to the target item, we can recommend these similar items to the user.

Its advantages are higher computational efficiency when the number of items is relatively stable and easier handling of user cold start problems. However, when the number of items is large, the computational cost of calculating similarities is still high, and it still faces the cold start problem when recommending new items.

## [FunkSVD](/html/MovieLens_100k_Recommender_System.html#FunkSVD)

FunkSVD is a recommendation algorithm based on matrix factorization, using Singular Value Decomposition (SVD) to decompose the user-item rating matrix. It maps users and items to a common latent feature space and makes recommendations based on these linearly combined latent features.

Its advantages are capturing implicit features of users and items, performing well on sparse matrices, and handling large-scale data. However, the training process is slow, especially with large datasets.

Below is the ROC curve showing the performance of different recommender systems when recommending various numbers of movies. FunkSVD provides more accurate recommendations than the other models, but the other two models also perform better than random recommendations, making them viable options with lower construction costs.

![](/images/R_recommender/Rplot08.png)

To visualize the differences in recommendation accuracy, we also plotted charts comparing model errors with actual ratings.

![](/images/R_recommender/Rplot09.png)

---
# Conclusion

In this data analysis, we attempted different models for various targets, and our models showed different effectiveness on this movie data. The suitable data types for these methods also vary, but they all performed well in this modeling process. We also visualized the movie genres using PCA to obtain feature vectors, which clarified the relationships between movies and facilitated subsequent FunkSVD model construction.

**Future Work and Reflections**

Regarding this data, we might consider creating ShinyApps to link it online for better result presentation. We could also try to optimize the model by further refining the extracted features. This report provided me with valuable experience in the recommender system field, encouraging me to explore various problems in data analysis.