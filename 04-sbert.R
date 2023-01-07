tictoc::tic("bert")

db <- pin_read(board, "job_post_translated") |> 
  transmute(text = JobDescription, doc_id = row_number()) |> 
  mutate(
    text = str_remove_all(text, "[^a-zA-Z 0-9(),.'-=!?:’%&]")
  ) |> 
  data.frame()

board |> 
  pin_write(
    db, 
    "bert_job_post"
  )

ilo_stat_df <- pin_read(board, "ilo_stat_df")

ilo_stat_df <- ilo_stat_df |> 
  mutate(
    across(everything(), ~ str_replace(., "NULL", "")),
    ISCO3_merged = str_c(ISCO3Tasks, " ", ISCO3Description),
    ISCO1Code = str_sub(ISCO2Code, end = 1)
  ) |> 
  left_join(
    iscoCrosswalks::isco |> 
      tibble() |> 
      rename(ISCO2Label = preferredLabel),
    by = c("ISCO2Code" = "code")
  ) |> 
  left_join(
    iscoCrosswalks::isco |> 
      tibble() |> 
      rename(ISCO1Label = preferredLabel),
    by = c("ISCO1Code" = "code")
  )

reticulate::source_python('04-sbert.py')

bert_task <- py$bert_task |> 
  tibble() %>%
  set_names(., 1:ncol(.)) # manage 0 index

bert_desc <- py$bert_desc |> 
  tibble() %>%
  set_names(., 1:ncol(.))

bert_merged <- py$bert_merged |> 
  tibble() %>%
  set_names(., 1:ncol(.))

granatlib::stoc()

board |> 
  pin_write(
    bert_task,
    "bert_task"
  )

board |> 
  pin_write(
    bert_desc,
    "bert_desc"
  )

board |> 
  pin_write(
    bert_merged,
    "bert_merged"
  )