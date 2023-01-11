source("05-bert_matching.R")

bert_merged <- bert_match("bert_merged", 0.5, ISCO3Code, job_post_line, JobDescription, similarity) |> 
  group_by(job_post_line) |> 
  slice_max(similarity, n = 1, with_ties = FALSE)

cleaned_text_data <- bert_merged |> 
  ungroup() |> 
  group_by(ISCO3Code) |> 
  transmute(JobDescription, ISCO3Code, n = n()) |> 
  ungroup() |> 
  mutate(line = row_number()) %>%
  unnest_tokens(word, JobDescription) %>% 
  select(line, ISCO3Code, word, n) |> 
  filter(!grepl('[0-9]', word)) %>%  # remove numbers
  filter(!str_detect(word, "[^a-zA-Z 0-9(),.'-=!?:’%&]")) |> 
  filter(nchar(word) > 1) %>% 
  anti_join(tidytext::get_stopwords(), by = "word") |> 
  drop_na()

sparse <- cleaned_text_data %>%
  count(line, word) %>%
  cast_sparse(line, word, n)

covariates <- cleaned_text_data |> 
  distinct(line, .keep_all = TRUE) |> 
  select(- word) |> 
  mutate(ISCO2Code = str_sub(ISCO3Code, end = 2)) |> 
  select(- ISCO3Code)

for (k in 2:20) {
  
  message("Fitting topic model w ", crayon::blue(k), " topics started. ", crayon::magenta(str_c("(", Sys.time(), ")")))
  
  tictoc::tic()
  
  topic_model <- stm(sparse, 
                     K = k, 
                     prevalence = ~ ISCO2Code,
                     data = covariates,
                     verbose = FALSE, 
                     max.em.its = 5,
                     init.type = "Spectral")
  
  runtime <- capture.output(tictoc::toc())
  
  board |> 
    pin_write(
      x = list(topic_model, runtime), 
      type = "rds",
      name = str_c("stm_", k)
    )
  
}
