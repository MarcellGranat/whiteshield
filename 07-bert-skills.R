tictoc::tic("bert-skill")

skills <- c("Analytical thinking and innovation", 
            "Complex problem-solving",
            "Critical thinking and analysis",
            "Active learning and learning strategies",
            "Creativity, originality and initiative",
            "Attention to detail, trustworthiness",
            "Emotional intelligence",
            "Reasoning, problem-solving and ideation",
            "Leadership and social influence",
            "Coordination and time management",
            "Technology design and programming",
            "Systems analysis and evaluation.") 

skills_words <- skills |> 
  map(str_split_1, " and |, ") |> 
  reduce(c) |> 
  tolower() |> 
  str_remove_all("[.]")

db_sentence <- pin_read(board, "bert_job_post") |> 
  tibble() |> 
  unnest_tokens("sentence", input = text, token = "sentences") |> 
  mutate(
    sentence = str_remove_all(sentence, "[^A-z ]"),
    sentence = str_trim(sentence)
    ) |> 
  distinct(doc_id, sentence) |> 
  filter(str_count(sentence, " ") >= 2) |> 
  mutate(line = row_number(), .before = 1)

board |> 
  pin_write(
    db_sentence,
    "db_sentence"
  )

reticulate::source_python('07-best-skills.py')

bert_skills <- py$bert_skills |> 
  tibble() |> 
  set_names(skills_words) # manage 0 index

bert_skills |> 
  mutate(line = row_number(), .before = 1) |> 
  pivot_longer(- line) |> 
  group_by(name) |> 
  slice_max(value) |> 
  left_join(db_sentence)

granatlib::stoc()

board |> 
  pin_write(
    bert_skills,
    "bert_skills"
  )
  

