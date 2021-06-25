# MovieLens Project

## Introduction

The aim of this project is to create a movie recommendation system based on the MovieLens dataset. The system should find movies appropriate for a given user that he or she has not seen yet. The system will predict a rating that a user would give to a chosen film.

The data used in the project is just a subset of a dataset with millions of ratings. The dataset contains information about movie ID, user ID, movie title, given rating, timestamp and genres of the movie.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table1.jpg" alt="Table 1" width="600"/>

First of all, the dataset was examined and it was split into training and test set. Then, basic visualizations were created to better understand the data. Finally, the recommendation system was built step by step, starting from simple average rating and adding additional effects. The system was assessed using RMSE calculated on the test set.


## Methods

Firstly, the dataset was split into training and test set. The test set accounted for 10% of the original dataset. The training set contained over 9 M observations of 6 variables.

Secondly, through data visualization the data was checked for outliers and mistakes. The distribution of given ratings is presented on a graph below:

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/image1.jpg" alt="Plot 1" width="600"/>

Given ratings ranged from 0.5 to 5 and users were more likely to give whole star ratings than half star ratings. Users most often gave 4 as a rating.

Most rated genres included Drama and Comedy, however, some movies were categorized into a few genres.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table2.jpg" alt="Table 2" width="600"/>

Users most often rated movies such as Pulp Fiction, Forrest Gump and The Silence of the Lambs.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table3.jpg" alt="Table 3" width="600"/>

The most active users rated over 6000 movies.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table4.jpg" alt="Table 4" width="600"/>

However, the majority of users rated fewer than 100 movies.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/image2.jpg" alt="Plot 2" width="600"/>

Finally, the predictive model was built in 4 steps:

* giving average rating (the same for all films)
* adding average rating for each movie (accounting for movie effect)
* adding average rating for each use (accounting for user effect)
* adding penalty for large estimates that come from small sample sizes (regularization)

This approach allows to see whether the model is improving with every consecutive step and by how much.
In the first step every movie is given the average rating from the whole dataset.
Then, new averages are calculated for each movie, as in general we have better movies and worse movies.
Later, averages are calculated for each user as well, because some of the users are more critical, meanwhile others appreciate most of watched movies.
Finally, a penalty is added not to overtrust some predictions coming from very small subsamples (e.g. movie which was rated only 3 times), as they are burdened with high errors.


## Results

The table below presents the RMSEs for each model with the RMSE of the final model equal to 0.8648.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table5.jpg" alt="Table 5" width="600"/>

As mentioned before, the final models includes a prediction based on general average rating, average rating for each movie, average rating for each user and penalty for overtrusting small subsamples.

The RMSE was calculated on a test set. The final model is burdened with 86.48% error in comparison with the true rating a user would give to a given movie. It is a huge improvement compared to the primary model that was burdened with more than 100% error.

Comparison of exemplary predicted ratings and true ratings is presented below.

<img src="https://github.com/ASledziewska/MovieLens_project/blob/master/images/Table6.jpg" alt="Table 6" width="600"/>


## Conclusion

This project intented to build a movie recommendation system based on the MovieLens dataset. The data was examined, cleaned and visualized. When assigning a predicted rating a user would give to a movie, the final model took into account an average rating in the dataset, an average rating given by a user, an average rating given to a movie and a penalty for large estimates coming from small sample sizes. Eventually, the error of the predicted rating compared to the true rating was 86.48%.

Moreover, more indepth knowledge about the user and his/her preferences would allow to build even better model. Some additional information about the user or the movie would be facilitative. For example, an information about leading actors in a movie could impact the user's rating (he/she can favor some actors and rate the movies higher). In addition, the average for each genre could be calculated too, probably some of the genres are rated higher than the others. However, some of the movies are classified to more than one genre, so it can be quite misleading.

The model attained in this project is satisfactory, nevertheless, there is still some potential for improvement and better understanding of a user's movie taste.
