job_post_df <- pin_read(board, "job_post_translated") |> 
  mutate(line = row_number(), .before = 1)

armed_forces_job <- ilo_stat_df |> 
  # TODO dropped because ...
  filter(str_starts(ISCO3Code, "0")) |> 
  pull(line)

ilo_stat_df <- pin_read(board, "ilo_stat_df") |> 
  mutate(line = row_number(), .before = 1)

bert_merged <- pin_read(board, "bert_merged") |> 
  mutate(ilo_line = row_number(), .before = 1) |> 
  pivot_longer(
    - ilo_line, 
    names_to = "job_post_line",
    names_transform = as.numeric,
    values_to = "similarity"
  ) |> 
  filter(!ilo_line %in% armed_forces_job)

bert_match_df <- bert_merged |> 
  group_by(job_post_line) |> 
  mutate(
    similarity_rank = rank(- similarity)
  ) |> 
  filter(similarity >= .5 | similarity_rank == 1) |> # filter before merge
  slice_max(similarity, with_ties = FALSE, n = 3) |> 
  ungroup() |> 
  left_join(job_post_df, by = c("job_post_line" = "line")) |> 
  left_join(ilo_stat_df, by = c("ilo_line" = "line")) |> 
  select(Id, ISCO3Label, similarity) # keep only the selected line to reduce memory usage
  
bert_match_df |> 
  pin_write(
    board = board,
    "BERT matching"
  )