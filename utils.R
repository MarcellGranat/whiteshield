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
  library(sf)
  library(reticulate)
  library(stm)
  options(dplyr.summarise.inform = FALSE)
  options(todor_extra = c("qmd", "md", "txt", "r"))
})

theme_set(
  theme_minimal() + 
    theme(
      legend.position = "bottom"
    )
)

board <- board_ms365(
  drive = Microsoft365R::get_business_onedrive(tenant = "common"), 
  # use `Microsoft365R::get_personal_onedrive()` for non business account
  path = "whiteshield"
)
