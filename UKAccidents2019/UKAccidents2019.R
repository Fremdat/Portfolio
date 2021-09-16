###

# This is an examplatory analysis of a dataset containing information about
# accidents in the UK in 2019


# Data Source:
# https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data
# File Name: "Road Safety Data - Accidents 2019.csv"


# SKills used:

#   base r:
#     for loop
#     sapply()

#   dplyr:
#     select() 
#     filter()
#     arrange()
#     rename()
#     mutate()
#     glimpse()

#   ggplot:
#       geom_bar(),geom_point(), geom_smooth(), geom_col()

#   leaflet()

###############
## Structure ##
###############

#   1. Setup
#       1.1 Load Packages
#       1.2 Read Data

#   2. EDA
#       2.1 Missing Values
#       2.2 Filtering and Arranging
#       2.3 Visualizations

#   3. Creating a Map


#########################
####### 1. Setup ####### 
#########################

## 1.1 Load Packages
####################


library(tidyverse)
library(scales)
library(leaflet)


##  1.2 Read Data
#################

dff <- read_csv("Data/Accidents2019.csv", guess_max = 31185) # without guess_max
# some columns will receive the wrong data type
# This initial data frame contains many variables. We will only look at a selection

columns = c("Accident_Index", "Longitude", "Latitude", "Accident_Severity", 
            "Number_of_Vehicles", "Number_of_Casualties", "Date", "Time", 
            "Road_Type", "Speed_limit", "Light_Conditions", "Weather_Conditions", 
            "Did_Police_Officer_Attend_Scene_of_Accident")

df <- select(dff, columns)

# The last variable name is very long and unhandy
df <-rename(df, Police_Attendance = Did_Police_Officer_Attend_Scene_of_Accident )

# For visualizations it will be helpful to have a column only indicating the month
df <- mutate(df, month = substr(df$Date,4,5))


glimpse(df)
# We have 117k observations with 13 variables
# There are many variables that received a numeric type but are actually categorical
# variables



categ <- c("Accident_Severity", "Road_Type", "Speed_limit", "Light_Conditions",
           "Weather_Conditions", "Police_Attendance", "month")



for (i in categ){
  
    df[,i] <- tibble(as.factor(pull(df, i))) #pull is necessary since using df[,i] returns NAs
}


##########################
######### 2. EDA ######### 
##########################


## 2.1 Missing Values
#####################


sum(is.na(df)) # There are 119 missing values in total


sapply(df, function(x) sum(is.na(x)))
# Latitude and Longitude miss 28 values each
# Time has 63 missing values
# There is no way to impute these values


## 2.2 Filtering and Arranging
##############################


# Let's look only at observations where at least 10 vehicles are involved
mass_acc <- filter(df, Number_of_Vehicles >= 10)
arrange(mass_acc, Number_of_Vehicles)
# only 9 accidents involved at least 10 cars


#Which speed limits are there?
unique(df$Speed_limit)
# It seems tehre is a missing value since -1 does not make sense
df %>%
  filter(Speed_limit == -1)
# There are 80 observations that have a speed limit value of -1


# What is the highest number of casualties if the speed limit was 70?
df %>%
  filter(Speed_limit == 70) %>%
  arrange(desc(Number_of_Casualties) ) %>%
  select(Accident_Severity,Number_of_Vehicles,Number_of_Casualties, Speed_limit)
# Answer: 13  


# What is the highest number of casualties if the speed limit was 30?
df %>%
  filter(Speed_limit == 30) %>%
  arrange(desc(Number_of_Casualties) ) %>%
  select(Accident_Severity,Number_of_Vehicles,Number_of_Casualties, Speed_limit)
# Answer: 16


#What is the average number of casualties in an accident given the speed limit?
df %>% group_by(Speed_limit) %>%
  summarise(avg_Casualties = mean(Number_of_Casualties))


## 2.3 Visualizations
#####################


## Scatter Plots ##


# Ploting Number of Vehicles involved vs Number of Casualties
ggplot(df) +
  geom_point(aes(x = Number_of_Vehicles, y = Number_of_Casualties))
# There is one outlier which has a very high number of casualties. Let's Remove it.
# Also, there may be many points overlapping, which might be misleading


df %>%
  filter(Number_of_Casualties < 40) %>%
  ggplot(aes(x = Number_of_Vehicles, y = Number_of_Casualties))+
  geom_point(position = "jitter")
# most accidents seem to involve up to 5 Casualties and 5 Vehicles. However, the 
# relationship between both variables is not very clear from the plot
# Let's add a regression line

df %>%
  filter(Number_of_Casualties < 40) %>%
  ggplot(aes(x = Number_of_Vehicles, y = Number_of_Casualties))+
  geom_point(position = "jitter") +
  geom_smooth(method = 'lm')
# adding a regression line, there seems to be a positive correlation between
# number of vehicles and casualties, which makes intuitive sense


## Bar Plots ##


# How comon is each speed limit?
ggplot(df) +
  geom_bar(aes(x = Speed_limit))
# Most accidents seem to happen in places where the speed limit is 30

# When do the most accidents happen?
ggplot(df)+
  geom_bar(aes(x = month))
# most accidents happen in November

ggplot(df)+
  geom_bar(aes(x = month, fill = Accident_Severity), position = "dodge")

# There Seem to be different patterns for accidents by month when accounting for severity
# Let's investigate this further

sum_severity <- table(df$Accident_Severity)

pivot_abs <- df %>%
  select(month, Accident_Severity) %>%
  group_by(month) %>%
  table()

pivot_rel <- df %>%
  select(month, Accident_Severity) %>%
  group_by(month) %>%
  table()

for (i in c(1,2,3)) {
  for (j in seq(1,12)) {
    pivot_rel[j,i] <- round(pivot_rel[j,i]/sum_severity[i],3)
  }
}

pivot_abs
pivot_rel

as.data.frame(pivot_rel) %>%
  ggplot(aes(factor(month), Freq, fill = factor(Accident_Severity))) +
  geom_col(width = 0.6, position = position_dodge(0.6)) +
  scale_fill_manual(values = c("red", "green", "blue")) +
  scale_y_continuous(labels = percent_format()) +
  xlab("Month") +
  guides(fill = guide_legend(title = "Accident Severity"))

# Month where most accidents of a given severity level happen:
# 3 - November
# 2 - September
# 1 - January

## Alternative approach:

tbl <- xtabs( ~ month + Accident_Severity, df) # equals pivot_abs

t(tbl)/colSums(tbl) # equal pivot_rel

as.data.frame(t(tbl)/colSums(tbl)) %>%
  ggplot(aes(factor(month), Freq, fill = factor(Accident_Severity))) +
  geom_col(width = 0.6, position = position_dodge(0.6)) +
  scale_fill_manual(values = c("red", "green", "blue")) +
  scale_y_continuous(labels = percent_format()) +
  xlab("Month") +
  guides(fill = guide_legend(title = "Accident Severity"))



#####################################
######### 3. Creating a Map ######### 
##################################### 


# Since we had many observations let us just visualize a subset

df_map = filter(df, month == "01", Speed_limit == 70)

# Let's also add a column which will be used for the popup info displayed
df_map = mutate(df_map, pop_info = paste(Accident_Index,"<br/>","Date: ",Date,
                                         "<br/>","Number of Casualties: ", Number_of_Casualties))

# To be used for the coloring of the markers
colors <- c("yellow","red")
pal <- colorFactor(colors, df_map$Number_of_Casualties)


# Create a map for all accidents in january where the speed limit was 70
# The darker the circle the more casualties are involved
leaflet() %>% addTiles() %>% addCircleMarkers(data = df_map, lat = ~Latitude, 
                                              lng = ~ Longitude, radius = ~ 3,
                                              popup = ~ pop_info,
                                              color = ~pal(Number_of_Casualties))
