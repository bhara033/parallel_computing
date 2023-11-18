# reproducible example using "flights" dataset
# https://multidplyr.tidyverse.org/articles/multidplyr.html 
if(!require("pacman")) install.packages("pacman")
pacman::p_load(magrittr, dplyr, multidplyr, nycflights13)

cluster <- new_cluster(parallel::detectCores())
data(flights)

flights1 <- flights %>% group_by(dest) %>% partition(cluster)

mean_var <- select(flights, ends_with("_delay")) %>% names()

# next 2 lines of code are not shown in the tutorial (multidplyr.tidyverse.org) but are required to execute the code in parallel without any errors
cluster_assign(cluster, mean_var = mean_var)
cluster_library(cluster, c("dplyr","magrittr","multidplyr","nycflights13"))

# using .groups = "drop" results in error (only required if the data has more than one level of grouping)
# the workaround is to run the below code and ungroup the data afterwards
flights_final <- flights1 %>% 
  summarise(across(all_of(mean_var), mean, .names = "mean_{.col}")) %>% collect()

flights_final <- flights_final %>% ungroup()