shape <- st_read("sau_adm_gadm_20210525_shp/sau_admbnda_adm1_gadm_20210525.shp") %>% 
  mutate(
    ADM1_EN = str_replace(ADM1_EN, "`Asir", "Aseer"),
    ADM1_EN = str_replace(ADM1_EN, "Jawf", "Jowf"),
    ADM1_EN = str_replace(ADM1_EN,  "Ar Riyad", "Riyadh"),
    ADM1_EN = str_replace(ADM1_EN, "Jizan", "Jazan" ),
    ADM1_EN = str_replace(ADM1_EN, "Ha'il", "Hail"),
    ADM1_EN = str_replace(ADM1_EN,  "Al Quassim", "Al Qassim"),
    ADM1_EN = str_replace(ADM1_EN, "Al Hudud ash Shamaliyah", "Northern Borders"),
    ADM1_EN = str_replace(ADM1_EN, "Ash Sharqiyah", "Eastern"),
    ADM1_EN = str_c(ADM1_EN, " Province"),
  )

centroids <- shape %>% 
  mutate(
    centroid = sf::st_centroid(geometry)
  ) %>% 
  select(ADM1_EN, centroid)

st_distance <- st_distance(centroids$centroid, centroids$centroid) %>% 
  data.frame() |> 
  tibble() %>% 
  set_names(shape$ADM1_EN) |> 
  mutate(from = shape$ADM1_EN, .before = 1) %>% 
  pivot_longer(-1, names_to = "to", values_to = "distance") %>% 
  mutate(distance = as.numeric(distance))

calculate_distance <- function(.from = "NULL", .to = "NULL"){
  if (.from %in% c("NULL", "Unspecified") | .to %in% c("NULL", "Unspecified")){
    distance <- 1 # TODO NA?
  } else {
    distance <- st_distance %>% 
      filter(from == .from, to == .to) %>% 
      pull(distance)
  }
  
  distance
}

distance_df <- crossing(
  pin_read(board, "unemployed_df") |> 
    distinct(Region),
  pin_read(board, "job_post_translated") |> 
    distinct(Region) |> 
    rename(req_Region = Region)
) |> 
  rowwise() |> 
  mutate(distance = calculate_distance(Region, req_Region)) |> 
  ungroup()

board |> 
  pin_write(
    distance_df, 
    "distance_df"
  )

