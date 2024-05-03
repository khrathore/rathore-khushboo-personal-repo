install.packages("tidyverse")
install.packages("jsonlite")

library(tidyverse)
library(jsonlite)
library(dplyr)



expand_df <- function(matchdata) {
  match_data <- data.frame(matrix(ncol = length(column_names), nrow = 0))
  match_info <- matches_clean[matchdata, ]
  red_teams <- str_split(match_info$alliances.red.team_keys[[1]], " ")
  blue_teams <- str_split(match_info$alliances.blue.team_keys[[1]], " ")
  all_teams <- c(red_teams, blue_teams)
  if (length(all_teams) == 4) {
    colors <- c("red", "red", "blue", "blue")
  } else if (length(all_teams) == 6) {
    colors <- c("red", "red", "red", "blue", "blue", "blue")
  }
  if (length(all_teams) == 0) {
    return(invisible()) 
  } else {
    for (n in 1:length(all_teams)) {
      team_key <- all_teams[1]
      alliance_color <- colors[1]
      data <- data.frame(c(team_key = team_key, alliance_color = alliance_color, match_info['comp_level'], match_info['event_key'], match_info['key'], match_info['winning_alliance'], match_info['alliances.blue.score'], match_info['alliances.red.score'])) %>% 
      rename(blue_score = alliances.blue.score, red_score = alliances.red.score)
      match_data <- rbind(match_data, data)
    }
    return(match_data)
  }
  
}

current_teams <- fromJSON("frc_allcurrent.json")
all_teams <- fromJSON("frc_allteams.json")
all_events <- fromJSON("frc_events.json")

dead_teams <- all_teams %>% 
  anti_join(current_teams)

write_json(dead_teams, "frc_deadteams.json")

team_ends <- fromJSON("frc_endyears.json")

all_matches <- fromJSON("event_results.json")

matches_clean <- all_matches %>% 
  select(alliances:match_number, winning_alliance) %>% 
  flatten() %>% 
  select(comp_level, event_key, key, winning_alliance, alliances.blue.score, alliances.blue.team_keys, alliances.red.score, alliances.red.team_keys)

column_names <- c("team_key", "alliance_color", "comp_level", "event_key", "key", "winning_alliance", "blue_score", "red_scoare")
data_by_team <- data.frame(matrix(ncol = length(column_names), nrow = 0))

rows <- nrow(matches_clean)
for (row in c(1:rows)) {
  new_data <- expand_df(row)
  data_by_team <- rbind(data_by_team, new_data)
  print(row)
}

write_csv(data_by_team, "team_match_data.csv")

data_by_team <- read_csv("team_match_data.csv")

max_pts <- data_by_team %>% 
  mutate(year = substr(event_key, start = 1, stop = 4)) %>% 
  group_by(year) %>% 
  summarize(
    max_blue = max(blue_score),
    max_red = max(red_score),
    max_overall = max(max_blue:max_red)
  ) %>% 
  select(year, max_overall)

team_pts <- data_by_team %>% 
  mutate(year = substr(event_key, start = 1, stop = 4)) %>% 
  inner_join(max_pts, by = "year") %>% 
  inner_join(current_teams, by = c("team_key" = "key")) %>% 
  mutate(score = case_when(
    alliance_color == "red" ~ red_score,
    alliance_color == "blue" ~ blue_score,
    TRUE ~ NA
  )) %>% 
  select(team_key, team_number, rookie_year, score, max_overall, year) %>% 
  group_by(team_key, year) %>% 
  summarize(
    med_score = median(score),
    mean_score = mean(score),
    mean_max = round(mean_score/max_overall*100, 2),
    med_max = round(med_score/max_overall*100, 2),
    years_active = 2025-rookie_year,
  ) %>% 
  distinct(team_key, year, .keep_all = TRUE) %>% 
  group_by(team_key) %>% 
  summarize(
    mean_med = round(mean(med_max),2),
    mean_mean = round(mean(mean_max),2),
    med_med = round(median(med_max),2),
    med_mean = round(median(mean_max),2),
    years_active = years_active
  ) %>% 
  distinct(team_key, .keep_all = TRUE)

champs_appearances <- data_by_team %>% 
  left_join(all_events, by = c("event_key" = "key")) %>% 
  filter(str_detect(event_type_string, "^Championship D.*")) %>% 
  distinct(team_key, event_key, .keep_all = TRUE) %>% 
  group_by(team_key) %>% 
  summarize(
    count = n()
  )

team_info_pts <- team_pts %>% 
  left_join(current_teams, by = c("team_key" = "key")) %>% 
  select(team_key:years_active, team_number, country, nickname) %>% 
  left_join(champs_appearances) %>% 
  mutate(country_groups = case_when(
    str_detect(country, "Brazil|Dominican|Colombia|Mexico|Belize|Panama") ~ "Central/South America",
    str_detect(country, "France|United Kingdom|Netherlands|Poland|Czech|Switzerland|Croatia|Romania|Bulgaria|Sweden") ~ "Europe",
    str_detect(country, "India|Chin|Singapore|Azerbaijan|Philippines|Japan") ~ "Asia/Pacific Islands",
    str_detect(country, "kiye|Israel") ~ "Middle East",
    TRUE ~ country
  )) %>% 
  mutate(percent = case_when(
    is.na(count) ~ 0,
    TRUE ~ round(count/years_active*100,2)
  )) %>% 
  mutate(years_active = case_when(
    years_active == 0 ~ 1,
    TRUE ~ years_active
  )) %>% 
  filter(percent > 0) %>% 
  filter(years_active > 2)

write_csv(team_info_pts, "scatter_data.csv")




