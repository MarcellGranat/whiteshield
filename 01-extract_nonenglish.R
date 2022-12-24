language_df <- job_post_data_df %>% 
  distinct(JobDescription) %>% 
  unnest_tokens(output = "text", JobDescription, token = "sentences") %>% 
  splitted_mutate(split_number = 1000,
    language = textcat::textcat(text)
  )

write.csv(language_df, file = "language.csv")