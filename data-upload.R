ilo_stat_df <- read_csv("Datascience_competition/ILO Stat.csv")
job_post_data_df <- read_csv("Datascience_competition/JobPostData.csv")
unemployed1_df <- read_csv("Datascience_competition/UnemployedData1.csv")
unemployed2_df <- read_csv("Datascience_competition/UnemployedData2.csv")
unemployed_df <- bind_rows(unemployed1_df, unemployed2_df) 

od <- Microsoft365R::get_business_onedrive(tenant = "common")

board <- board_ms365(
  drive = od, 
  path = "whiteshield"
)

pin_write(board, ilo_stat_df, name = "ilo_stat_df", description = "Source: Enclosed file")
pin_write(board, job_post_data_df, name = "job_post_data_df", description = "Source: Enclosed file")
pin_write(board, unemployed_df, name = "unemployed_df", description = "Source: Enclosed file")

odb$get_item("whiteshield")$create_share_link("edit", expiry = "90 days")
