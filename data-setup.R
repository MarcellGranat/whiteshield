od <- Microsoft365R::get_business_onedrive(tenant = "common")
# use `Microsoft365R::get_personal_onedrive()` 
# if you want to access the data with it

if (od$properties$owner$user$displayName == "Granát Marcell Péter") {
  board <- board_ms365(
    drive = od, 
    path = "whiteshield"
  )
} else {
  shared_items <- od$list_shared_files()
  folder_to_board <- shared_items$remoteItem[[which(shared_items$name == "whiteshield")]]
  if (!exists("folder_to_board")) message("You need access to the data")
  board <- board_ms365(od, folder_to_board)
}

ilo_stat_df <- pin_read(board, "ilo_stat_df")
job_post_data_df <- pin_read(board, "job_post_data_df")
unemployed_df <- pin_read(board, "unemployed_df")

save(
  ilo_stat_df,
  job_post_data_df,
  unemployed_df,
  file = "raw_data.RData"
)

