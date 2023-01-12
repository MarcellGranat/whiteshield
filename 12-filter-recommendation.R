library(furrr)

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

distance_df <- pin_read(board, "distance_df")

supply_side_df <- pin_read(board, "BERT matching") |> 
  left_join(
    pin_read(board, "job_post_translated") |> 
      transmute(line = row_number(), Id, Region), 
    by = "Id") |> 
  left_join(
    pin_read(board, "Requirements for the job"), 
    by = "line") |> 
  select(
    job_id = Id,
    ISCO3Label, 
    similarity,
    req_Region = Region,
    req_min_degree = min_degree,
    req_age_from_exp = age_from_exp,
    age_min,
    req_gender = gender
  )

job_to_unemployed <- function(x) {
  unemployed_df |> 
    slice(x) |> 
    left_join(supply_side_df, by = c("MajorStudy" = "ISCO3Label")) |> 
    filter(
      (is.na(req_gender) | req_gender == Gender),
      # no requirement or the potential applicant should pass
      (is.na(req_min_degree) | Education >= req_min_degree),
      (is.na(age_min) | Age >= age_min),
      Age >= req_age_from_exp, # req age inference from the req experience
    ) |> 
    left_join(distance_df, by = c("Region", "req_Region")) |> 
    arrange(distance, desc(similarity)) |> 
    # as closest as possible or more similar or a more fitting job
    slice(min(1, n()):min(10, n())) |> # best 10 maximum
    select(unemployed_id, job_id) # save memory
}

plan(multisession(workers = min(parallel::detectCores(), 6)))

tictoc::tic("filter-matching")
filtered_match <- future_map(seq(nrow(unemployed_df)), job_to_unemployed, .progress = TRUE) |> 
  bind_rows()
stoc()

plan("default")

filtered_match |> 
  pin_write(
    board = board,
    "Filtered match"
  )

