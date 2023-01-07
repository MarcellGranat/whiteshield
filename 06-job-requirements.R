job_post_sentences <- pin_read(board, "job_post_translated") |> 
  transmute(line = row_number(), JobDescription) |> 
  mutate(
    JobDescription = str_replace_all(JobDescription, "[.]{2}", "."),
    # .. caused by remerging after translation >> incorrect tokenizing for senteces
    JobDescription = str_replace_all(JobDescription, "[.]", ". "), # ensure tokenizing
    JobDescription = str_replace_all(JobDescription, "[.]  ", ". "), 
    JobDescription = str_replace_all(JobDescription, " {2,}", " "),
    # upper case after .
    JobDescription = str_replace_all(JobDescription, set_names(str_c(". ", LETTERS), str_c("[.] ", letters))) 
  ) |> 
  unnest_tokens("sentence", JobDescription, token = "sentences") 

examples_l <- list()

find_requirement <- function(x, example_lines = 1:3) {
  
  requirement <- x[[1]]
  pattern_for_sentence <- str_flatten(x[[2]], "|")
  pattern <- str_flatten(x[[3]], "|")
  
  detected <- job_post_sentences |> 
    filter(str_detect(sentence, pattern_for_sentence)) |> 
    filter(str_detect(sentence, pattern))
  
  
  examples_l[[length(examples_l) + 1]] <<- list(
    pattern_for_sentence,
    pattern, 
    example = detected |> 
      slice(example_lines) |> 
      pull(sentence)
  )
  
  detected |> 
    transmute(
      line, 
      requirement = x[[1]],
      pattern_for_sentence = str_flatten(x[[2]], collapse = " or "),
      pattern = str_flatten(x[[3]], collapse = " or "),
      value = str_extract(sentence, pattern)
    )
  
}

find_requirement(list("experience", "experience", "\\d{1,2}"))

examples_l |> 
  last() |> 
  str_view_all(example$example, pattern = example[[2]])


requirement_l <- list(
  list("experience", "experience", "\\d{1,2}"),
  list("female", "only female", "female")
) |> 
  progress_map(find_requirement)


