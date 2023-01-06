foreign_language_df <- job_post_data_df %>% 
  distinct(JobDescription) %>% 
  unnest_tokens(output = "text", JobDescription, token = "sentences") %>% 
  filter(str_detect(str_sub(text, start = 3), "^[^a-zA-Z 0-9().,'-=!?:’%&]"))


board |> 
  pin_write(
    x = foreign_language_df,
    name = "foreign_language"
  )
  
write.csv(foreign_language_df, "foreign_language.csv")