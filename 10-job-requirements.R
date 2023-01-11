job_post_translated <- pin_read(board, "job_post_translated")

around <- \(x) str_c("\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}", x ,"\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}\\w{0,}\\W{0,}")

job_post_translated %>% 
  transmute(
    line = row_number(),
    text = str_remove_all(JobDescription, "\\t|\\n")
  ) |> 
  head(5) |> 
  mutate(
    experience_sent = str_extract(text, around("experience")),
    experience_num = map(experience_sent, ~ str_extract_all(., pattern = "\\d{1,2}")[[1]]),
    experience_min = map2_dbl(experience_num, experience_sent, function(num, sent) {
      if (length(num) > 0) {
        as.numeric(num[1])
      } else {
        NA
      }
    }
    ),
    experience_min = ifelse(experience_min > 30, NA, experience_min)
  )

job_post_translated |> 
  sample_n(1000) |> 
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
  mutate(
    value = str_extract(value, "\\d{1,2}"),
    value = ifelse(value < 20 | value > 60, NA, value)
  )

