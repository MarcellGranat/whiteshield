foreign_language_df <- pin_read(board, "foreign_language")
job_post_data_df <- pin_read(board, "job_post_data_df")

translation_df <- list.files("translation/", full.names = TRUE) |> 
  enframe(name = NULL, value = "file_name") |> 
  arrange(parse_number(file_name)) |> 
  transmute(
    data = map(file_name, read_csv)
  ) |> 
  pull(data) |> 
  bind_rows()

replace_sentences_df <- foreign_language_df |> 
  head(nrow(translation_df)) |> 
  bind_cols(translation_df) |> 
  tibble()

job_post_translated_df <- job_post_data_df |> 
  transmute(line = row_number(), JobDescription) |> 
  unnest_tokens(output = "text", JobDescription, token = "sentences") |> 
  left_join(replace_sentences_df, by = "text") |> 
  transmute(
    line,
    text = ifelse(is.na(translation), text, translation),
    # replace if the sentence was needed to translate to English
  ) |> 
  group_by(line) |> 
  summarise(JobDescription = str_flatten(text, collapse = ". ")) |> 
  select(- line) |> # n_obs are the same as in `job_post_data_df`
  bind_cols(
    job_post_data_df |> 
      select(- JobDescription)
  )

board |> 
  pin_write(
    job_post_translated_df,
    name = "job_post_translated"
  )



