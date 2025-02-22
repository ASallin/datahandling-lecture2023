#######################################################################
# Project Lecture 8: Data Analytics
#
# This script is the main script for lecture 8 of Data Handling.
# 
# A. Sallin, St. Gallen, 2023
#######################################################################


# Set up ------------------------------------------------------------------

# Load packages (install if needed)
library(tidyverse) # tidyverse contains dplyr, readr, tibble, and all other packages from the tidyverse universe. 


# Initiate data frame on persons' spending
df_c <- data.frame(id = c(1:3,1:3),
                   money_spent= c(1000, 2000, 6000, 1500, 3000, 5500),
                   currency = c("CHF", "CHF", "USD", "EUR", "CHF", "USD"),
                   year=c(2017,2017,2017,2018,2018,2018))
df_c

# Initiate data frame on persons' characteristics
df_p <- data.frame(id = 1:4,
                   first_name = c("Anna", "Betty", "Claire", "Diane"),
                   profession = c("Economist", "Data Scientist",
                                  "Data Scientist", "Economist"))
df_p



# Preparatory steps: combine/merge data frames ------------------------------------------

# Outer join/Full join
df_merged <- merge(df_p, df_c, by="id", all = TRUE)
df_merged <- full_join(df_p, df_c, by = "id")

# Left join
lj <- merge(df_p, df_c, by = "id", all.x = TRUE)
lj <- left_join(df_p, df_c, by = "id")
lj

# Right join
rj <- merge(df_p, df_c, by = "id", all.y = TRUE)
rj <- right_join(df_p, df_c, by = "id")

# Cross join
merge(df_p, df_c, by = NULL)

# Anti join
anti_join(df_p, df_c, by = "id")


# Data summary ------------------------------------------------------------

# summary statistics for each variable
summary(df_merged)

# cross-tabulation (categorical variables)
table(df_merged$year)
table(df_merged$year, df_merged$profession)

# Use "count" from dplyr
count(df_merged, year)

count(df_merged, year) |> 
  mutate(pct = n()/sum(n))



# Selecting subsets (select columns) ------------------------------------------

df_selection <- select(df_merged, id, year, money_spent, currency)
df_selection



# Filtering datasets (filter rows based on variable values) ------------------------------------------

# one filtering condition
filter(df_selection, year == 2018)

# several filtering conditions
filter(df_selection, 
       year == 2018, 
       money_spent < 5000, 
       currency=="EUR")





# Mutating datasets (add/change values/columns) ------------------------------------------

# initiate an exchange-rate data frame
exchange_rates <- data.frame(exchange_rate= c(0.9, 1, 1.2),
                             currency=c("USD", "CHF", "EUR"), 
                             stringsAsFactors = FALSE)

# join the exchange-rate with the main dataset
df_selection <- merge(df_selection, exchange_rates, by="currency")

# add the new variable with money spent in CHF
df_mutated <- mutate(df_selection, money_spent_chf = money_spent * exchange_rate)
df_mutated

# use across 
df_mutated %>%
  mutate(across(c(money_spent, money_spent_chf), function(x) {x-10}))

df_mutated %>%
  mutate(across(c(everything()), function(x) {as.character(x)}))



# Summary statistics and aggregation -------------------------------------------

# generate a simple descriptive statistics table
summarise(df_mutated,
          mean = mean(money_spent_chf),
          standard_deviation = sd(money_spent_chf),
          median = median(money_spent_chf),
          N = n())


# summarize by groups of observations ("split-apply-combine")

# split into year-groups
# apply statistics functions, and combine results in one table

by_year <- df_mutated |> 
  group_by(year) |> 
  summarise(mean = mean(money_spent_chf),
            standard_deviation = sd(money_spent_chf),
            median = median(money_spent_chf),
            N = n()) 

df_mutated |> 
  group_by(year) |> 
  summarise(across(.cols = c(money_spent_chf),
                   .fns = list(mean = mean, 
                               standard_deviation = sd, 
                               median = median)))


# Use skimr
library(skimr) # install if needed
skim(df_mutated)


# apply-type functions for data summaries

# load data
data("swiss")

# compute the mean for each variable (column)
apply(swiss, 1, mean)
apply(swiss, 2, mean)



