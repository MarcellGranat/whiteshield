suppressPackageStartupMessages({
  library(magrittr)
  library(tidyverse)
  library(tidytext)
  library(lubridate)
  library(pins)
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

od <- Microsoft365R::get_business_onedrive(tenant = "common")
# use `Microsoft365R::get_personal_onedrive()` 
# if you want to access the data with it

board <- board_ms365(
  drive = od, 
  path = "whiteshield"
)
