suppressPackageStartupMessages({
  library(magrittr)
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(knitr)
  library(broom)
  library(DT)
  library(granatlib) # < github
  library(countrycode)
  library(patchwork)
  options(dplyr.summarise.inform = FALSE)
  options(todor_extra = c("qmd", "md", "txt", "r"))
})

theme_set(
  theme_minimal() + 
    theme(
      legend.position = "bottom"
    )
)
