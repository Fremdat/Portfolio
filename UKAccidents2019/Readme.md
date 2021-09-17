# Readme for UKAccidents2019

This is an example of a short exploratory data analysis in R.

## Short Summary:

I use a dataset containing information about individual accidents that happend in the UK in 2019. After selecting a subset of the available variables and creating a month variable, I use *filtering, grouping and arranging* to investigate the connection between speed limits and casualities. 

Next, I visualize with bar plots and scatter plots to investigate further connections between speed limit and other variables but also between the number of vehicles involved and the number of casualties. 

Finally, I create a map for all accidents that happend in January where the speed limit was 70 (the maximum). The color of the marker indicates the number of casualties and clicking on the marker displays a popup with further information.

## Files:

- **Accidents2019.csv:** Csv-file containing the raw data
- **UK Accidents 2019.pdf:** presentation of proceedings and results
- **UKAccidents2019.R:** Acutal R code with which the analysis was conducted

## Skills used:

- Base R:
    - sapply()
    - for loop
- dplyr:
    - select()
    - filter()
    - arrange()
    - rename()
    - mutate()
    - group_by()
    - summariese()
    - glimpse()

- ggplot:
    - geom_bar()
    - geom_point()
    - geom_smooth()

- leaflet 

