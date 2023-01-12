library(furrr)
plan(multisession(workers = parallel::detectCores()))

source("08-distance.R")

bert_match_df <- pin_read(board, "BERT matching")

job_ids <- pin_read(board, "job_post_translated") |> 
  transmute(line = row_number(), Id, Region)

requirements_df <- pin_read(board, "Requirements for the job")

unemployed_df <- pin_read(board, "unemployed_df") |> 
  filter(Status == 1) |> 
  transmute(
    unemployed_id = Id,
    Gender,
    Region,
    Age,
    Education = factor(Education, levels = c("Diploma", "Bachelor", "Master", "Doctorate"), ordered = TRUE),
    MajorStudy
  )

supply_side_df <- bert_match_df |> 
  left_join(job_ids, by = "Id") |> 
  inner_join(requirements_df, by = "line") |> 
  select(
    job_id = Id,
    ISCO3Label, 
    similarity,
    req_Region = Region,
    req_min_degree = min_degree,
    req_age_from_exp = age_from_exp,
    req_gender = gender
  )

distance_df <- crossing(
  unemployed_df |> 
    distinct(Region),
  supply_side_df |> 
    distinct(req_Region)
) |> 
  rowwise() |> 
  mutate(distance = calculate_distance(Region, req_Region)) |> 
  ungroup()

job_to_unemployed <- function(x) {
  unemployed_df |> 
    slice(x) |> 
    left_join(supply_side_df, by = c("MajorStudy" = "ISCO3Label")) |> 
    filter(
      (is.na(req_gender) | req_gender == Gender),
      (is.na(req_min_degree) | Education >= req_min_degree),
      Age >= req_age_from_exp,
      Age >= min_age
    ) |> 
    left_join(distance_df, by = c("Region", "req_Region")) |> 
    arrange(distance, desc(similarity)) |> 
    slice(max(1, n()):min(10, n())) |> 
    select(unemployed_id, job_id)
}

tictoc::tic("filter-matching")
filtered_match <- future_map_dfr(seq(nrow(unemployed_df)), job_to_unemployed, .progress = TRUE)
stoc()

filtered_match |> 
  pin_write(
    board = board,
    "Filtered match"
  )

plan("default")
