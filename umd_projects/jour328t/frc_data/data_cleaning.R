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
  for (n in 1:length(all_teams)) {
    team_key <- all_teams[n]
    alliance_color <- colors[n]
    data <- data.frame(c(team_key = team_key, alliance_color = alliance_color, match_info['comp_level'], match_info['event_key'], match_info['key'], match_info['winning_alliance'], match_info['alliances.blue.score'], match_info['alliances.red.score'])) %>% 
      rename(blue_score = alliances.blue.score, red_score = alliances.red.score)
    match_data <- rbind(match_data, data)
  }
  return(match_data)
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
for (row in 1:rows) {
  new_data <- expand_df(row)
  data_by_team <- rbind(data_by_team, new_data)
  print(row)
}

write_csv(data_by_team, "team_match_data.csv")




