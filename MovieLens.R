rm(list=ls())

################################
# Create edx set, validation set
################################

# Note: this process could take a couple of minutes

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")

# MovieLens 10M dataset:
# https://grouplens.org/datasets/movielens/10m/
# http://files.grouplens.org/datasets/movielens/ml-10m.zip

dl <- tempfile()
download.file("http://files.grouplens.org/datasets/movielens/ml-10m.zip", dl)

ratings <- fread(text = gsub("::", "\t", readLines(unzip(dl, "ml-10M100K/ratings.dat"))),
                 col.names = c("userId", "movieId", "rating", "timestamp"))

movies <- str_split_fixed(readLines(unzip(dl, "ml-10M100K/movies.dat")), "\\::", 3)
colnames(movies) <- c("movieId", "title", "genres")
movies <- as.data.frame(movies) %>% mutate(movieId = as.numeric(levels(movieId))[movieId],
                                           title = as.character(title),
                                           genres = as.character(genres))

movielens <- left_join(ratings, movies, by = "movieId")

# Validation set will be 10% of MovieLens data

set.seed(1, sample.kind="Rounding")
test_index <- createDataPartition(y = movielens$rating, times = 1, p = 0.1, list = FALSE)
edx <- movielens[-test_index,]
temp <- movielens[test_index,]

# Make sure userId and movieId in validation set are also in edx set

validation <- temp %>% 
  semi_join(edx, by = "movieId") %>%
  semi_join(edx, by = "userId")

# Add rows removed from validation set back into edx set

removed <- anti_join(temp, validation, by = c("userId", "movieId", "rating", "timestamp", "title", "genres"))
edx <- rbind(edx, removed)

rm(dl, ratings, movies, test_index, temp, movielens, removed)

# How many rows and columns are there in the edx dataset?
dim(edx)
nrow(edx)
ncol(edx)

# How many zeros were given as ratings in the edx dataset?
sum(edx$rating==0)
edx %>% filter(rating == 0) %>% tally()

# How many threes were given as ratings in the edx dataset?
sum(edx$rating==3)
edx %>% filter(rating == 3) %>% tally()

# How many different movies are in the edx dataset?
length(unique(edx$movieId))
n_distinct(edx$movieId)

# How many different users are in the edx dataset?
n_distinct(edx$userId)

# Most active users
edx %>% group_by(userId) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>% head(n=5)

# Distribution of number of ratings given by users
edx %>% group_by(userId) %>%
  summarize(count = n()) %>%
  filter(count <= 500) %>%
  ggplot(aes(count)) +
  geom_histogram(binwidth = 5)

# How many movie ratings are in each of the following genres in the edx dataset?
edx %>% filter(genres %like% "Drama") %>% count()
edx %>% separate_rows(genres, sep = "\\|") %>%
  group_by(genres) %>%
  summarize(count = n()) %>%
  arrange(desc(count))

# Most rated genres
edx %>% group_by(genres) %>% summarize(count = n()) %>% 
  arrange(desc(count)) %>% head(n=10)

# Which movie has the greatest number of ratings?
edx %>% group_by(movieId, title) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>% head(n=5)

# What are the five most given ratings in order from most to least?
edx %>% group_by(rating) %>% summarize(count = n()) %>% top_n(5) %>%
  arrange(desc(count))

# Distribution of given ratings
edx %>% ggplot(aes(rating)) + geom_bar()

# True or False: In general, half star ratings are less common than whole star ratings (e.g., there are fewer ratings of 3.5 than there are ratings of 3 or 4, etc.).
edx %>%
  group_by(rating) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = rating, y = count)) +
  geom_line()



### Simplest model: the same rating for all films (average rating)
mu_hat <- mean(edx$rating)
naive_rmse <- RMSE(validation$rating, mu_hat)
#calculate RMSE

# Create a table with results of each model
rmse_results <- tibble(method = "Just the average", RMSE = naive_rmse)
rmse_results %>% knitr::kable()


## Accounting for movie effect (average rating for each movie)
mu <- mean(edx$rating)
movie_avgs <- edx %>% group_by(movieId) %>% summarize(b_i = mean(rating - mu))
predicted_ratings <- validation %>% left_join(movie_avgs, by="movieId") %>%
  mutate(pred = mu + b_i) %>% .$pred
model_1_rmse <- RMSE(predicted_ratings, validation$rating)

rmse_results <- bind_rows(rmse_results, tibble(method = "Movie Effect Model", RMSE = model_1_rmse))
rmse_results %>% knitr::kable()


## Accounting for user effect (average rating for each user)
user_avgs <- edx %>% left_join(movie_avgs, by="movieId") %>% group_by(userId) %>%
  summarize(b_u = mean(rating - mu - b_i))
predicted_ratings <- validation %>% left_join(movie_avgs, by="movieId") %>%
  left_join(user_avgs, by="userId") %>% mutate(pred = mu + b_i + b_u) %>% .$pred
model_2_rmse <- RMSE(predicted_ratings, validation$rating)
rmse_results <- bind_rows(rmse_results, tibble(method = "Movie + User Effects Model", RMSE = model_2_rmse))
rmse_results %>% knitr::kable()


## Regularization - penalty for large estimates that come from small sample sizes
lambdas <- seq(0, 30, 0.5)

# Calculating RMSE for each lambda from a given range - lambda is a penalty
rmses <- sapply(lambdas, function(l){
  
  mu <- mean(edx$rating)
  
  b_i <- edx %>% group_by(movieId) %>%
    summarize(b_i = sum(rating - mu)/(n() + l))
  
  b_u <- edx %>% left_join(b_i, by="movieId") %>% group_by(userId) %>% 
    summarize(b_u = sum(rating - b_i - mu)/(n() + l))
  
  predicted_ratings <- validation %>% left_join(b_i, by="movieId") %>% 
    left_join(b_u, by="userId") %>%
    mutate(pred = mu + b_i + b_u) %>% .$pred
  
  return(RMSE(predicted_ratings, validation$rating))
})

# Choose lambda with the lowest RMSE (the best model)
lambda <- lambdas[which.min(rmses)]

# Calculate model with the best lambda
b_i <- edx %>% group_by(movieId) %>%
  summarize(b_i = sum(rating - mu)/(n() + lambda))
b_u <- edx %>% left_join(b_i, by="movieId") %>% group_by(userId) %>% 
  summarize(b_u = sum(rating - b_i - mu)/(n() + lambda))
predicted_ratings <- validation %>% left_join(b_i, by="movieId") %>% 
  left_join(b_u, by="userId") %>%
  mutate(pred = mu + b_i + b_u) %>% .$pred
model_3_rmse <- RMSE(predicted_ratings, validation$rating)
rmse_results <- bind_rows(rmse_results, tibble(method = "Regularized Movie + User Effects Model", RMSE = model_3_rmse))

# Table presenting results of all models
rmse_results %>% knitr::kable()
#the final model has RMSE lower than 0.8649 - BINGO!!!

# Exemplary comparison of predicted ratings and true ratings
validation$pred <- validation %>% left_join(b_i, by="movieId") %>% 
  left_join(b_u, by="userId") %>%
  mutate(pred = mu + b_i + b_u) %>% .$pred
validation %>% select(rating, pred) %>% head(n=20)
