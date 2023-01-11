bert_skills <- pin_read(board, "bert_skills")

db_sentence <- pin_read(board, "db_sentence")

maximum_similarity_df <- db_sentence |> 
  select(doc_id) |> 
  bind_cols(bert_skills) |> 
  sample_n(1e3) |> 
  group_by(doc_id) |> 
  summarise_all(.funs = list(max = max))

best_skill_df <- maximum_similarity_df |>
  rowwise() |> 
  (\(x) summarise(x, best_skills = names(x)[which.max(c_across(- doc_id)) + 1])) () |> 
  ungroup() |> 
  bind_cols(maximum_similarity_df["doc_id"])

best_skill_df |> 
  pin_write(
    board = board, 
    "Best skill"
  )

maximum_similarity_df |> 
  select(- doc_id) |> 
  pivot_longer(everything()) |> 
  sample_n(1e4) |> 
  ggplot() + 
  aes(value, color = name) + 
  stat_ecdf()
