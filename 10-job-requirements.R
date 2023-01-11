job_post_translated <- pin_read(board, "job_post_translated")

# Age minimum -------------------------------------------------

age_minimum_df <- job_post_translated |> 
  transmute(
    line = row_number(),
    text = str_remove_all(JobDescription, "\\t|\\n")
  ) |> 
  mutate(
    age_1 = str_extract(text, "[0-9]{2} years[ A-z]* age"),
    age_2 = str_extract(text, "[0-9]{2} years old and below"),
    age_5 = str_extract(text, "[Ll]ess than [0-9]{2} years"),
    age_3 = str_extract(text, "[0-9]{2}[- A-z]+[0-9]{2} years old"),
    age_4 = str_extract(text, " [Aa]ge[: ]+[A-z: ]*[0-9]{2}[- A-z]*[0-9]{2}"),
  ) |> 
  select(- text) |> 
  pivot_longer(-1) |> 
  drop_na() |> 
  transmute(
    line,
    age_min = str_extract(value, "\\d{1,2}"),
    age_min = as.numeric(age_min),
    age_min = ifelse(age_min < 20 | age_min > 60, NA, age_min)
  )

# Experience, degree ------------------------------------------

around <- \(x) str_c("\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}", x ,"\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}")

titles <- pin_read(board, "unemployed_df") |> 
  pull(Education) |> 
  unique()

requirements_df <- job_post_translated |> 
  mutate(
    line = row_number(),
    text = str_remove_all(JobDescription, "\\t|\\n")
  ) |> 
  left_join(age_minimum_df, by = "line") |> 
  splitted_transmute(split_number = 100,
    line,
    experience_sent = str_extract(text, around("experience")),
    experience_min = map_dbl(experience_sent, function(sent) {
      num = str_extract_all(sent, pattern = "\\d{1,2}")[[1]]
      
      if (length(num) > 0) {
        as.numeric(num[1])
      } else {
        NA
      }
    }
    ),
    experience_min = ifelse(experience_min > 30, NA, experience_min),
    experience_min = case_when(
      !is.na(experience_min) ~ as.numeric(experience_min),
      Experience == "Internship" ~ 0,
      Experience == "Entry level" ~ 2,
      Experience == "Associate" ~ 5,
      Experience == "Director" ~ 15,
      Experience == "Executive" ~ 20,
      TRUE ~ 0
    ),
    degree = str_extract(text, "[ A-z]+ [A-z]+ degree [ A-z]+ "),
    degree_title = str_extract(
      degree, 
      paste("(?i)", c(titles, " ba "," ma ", " mba", "bsc", "undergraduate", "university", "college"), sep = "", collapse = "|")
    ),
    min_degree = case_when(
      str_detect(degree_title, paste(c("(?i)diploma"), sep = "", collapse = "|")) ~ "Diploma",
      str_detect(degree_title, paste(c("(?i)bachelor", "(?i)ba", "(?i)bsc", "university", "undergraduate", "college"), sep = "", collapse = "|")) ~ "Bachelor",
      str_detect(degree_title, paste(c("(?i)master", "(?i)ma", "(?i)msc", "(?i)mba"), sep = "", collapse = "|")) ~ "Master",
      str_detect(degree_title, paste(c("(?i)doctorate", "(?i)phd"), sep = "", collapse = "|")) ~ "Doctorate",
      TRUE ~ NA_character_
    ),
    min_degree = ifelse(is.na(min_degree), Degree, min_degree),
    min_degree = ifelse(min_degree == "NULL", NA, min_degree),
    min_degree = factor(min_degree, levels = c("Diploma", "Bachelor", "Master", "Doctorate"), ordered = TRUE),
    degree_year = case_when(
      min_degree == "Diploma" ~ 2,
      min_degree == "Bachelor" ~ 3,
      min_degree == "Master" ~ 5,
      min_degree == "Doctorate" ~ 8,
      TRUE ~ 0
    ),
    age_from_exp = 18 + experience_min + degree_year,
    gender = case_when(
      str_detect(text, "[Ff]emale") ~ "Female",
      str_detect(text, "[ /][Mm]ale") ~ "Male",
      TRUE ~ NA_character_
    )
  )

requirements_df |> 
  pin_write(
    board = board,
    "Requirements for the job"
  )


