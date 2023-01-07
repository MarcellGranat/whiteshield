bert_match <- function(.match_type = "bert_merged", .limit = 0, ...) {
  # load the required frames, filter and merge to avoid high memory objects
  # the merged tables without filter is 4 GB! >> filter before merge
job_post_df <- pin_read(board, "job_post_translated") |> 
  mutate(line = row_number(), .before = 1)

ilo_stat_df <- pin_read(board, "ilo_stat_df") |> 
  mutate(line = row_number(), .before = 1)

pin_read(board, .match_type) |> 
  mutate(ilo_line = row_number(), .before = 1) |> 
  pivot_longer(
    - ilo_line, 
    names_to = "job_post_line",
    names_transform = as.numeric,
    values_to = "similarity"
  ) |> 
  filter(similarity >= .limit) |> # filter before merge
  left_join(ilo_stat_df, by = c("ilo_line" = "line")) |> 
  left_join(job_post_df, by = c("job_post_line" = "line")) |> 
  select(...) # keep only the selected line to reduce memory usage

}
