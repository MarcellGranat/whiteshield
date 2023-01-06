ilo_stat_df <- pin_read(board, "ilo_stat_df")
job_post_data_df <- pin_read(board, "job_post_data_df")
unemployed_df <- pin_read(board, "unemployed_df")

save(
  ilo_stat_df,
  job_post_data_df,
  unemployed_df,
  file = "raw_data.RData"
)

