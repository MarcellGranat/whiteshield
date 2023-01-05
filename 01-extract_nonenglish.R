foreign_language_df <- job_post_data_df %>% 
  distinct(JobDescription) %>% 
  unnest_tokens(output = "text", JobDescription, token = "sentences") %>% 
  filter(str_detect(str_sub(text, start = 3), "^[^a-zA-Z 0-9().,'-=!?:’%&]"))

foreign_language_df |> 
  mutate(text = str_remove_all(text, "\u00100")) |> 
  mutate(line = ((row_number() - 1) / n()) %/% .5 + 1, .before = everything()) |> 
  group_by(line) |> 
  group_walk(~ {
    .x |> 
      select(- line) |> 
      openxlsx::write.xlsx(str_c("foreign_language_", first(.x$line), ".xlsx"))
  }, .keep = TRUE)

write.csv(foreign_language_df, "foreign_language.csv")

