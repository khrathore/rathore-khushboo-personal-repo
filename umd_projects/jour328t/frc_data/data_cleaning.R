install.packages("tidyverse")
install.packages("jsonlite")

library(tidyverse)
library(jsonlite)
library(dplyr)

column_names <- c("team_key", "alliance_color", "comp_level", "event_key", "key", "winning_alliance", "blue_score", "red_scoare")
data_by_team <- data.frame(matrix(ncol = length(column_names), nrow = 0))

matchdata = 1
expand_df = function(matchdata) {
  match_info <- matches_clean[matchdata, ]
  red_teams <- unlist(match_info$alliances.red.team_keys)
  blue_teams <- unlist(match_info$alliances.blue.team_keys)
  all_teams <- c(red_teams, blue_teams)
  length(all_teams)
  print(all_teams)
  if (length(all_teams) == 4) {
    colors <- c("red", "red", "blue", "blue")
  } else if (length(all_teams) == 6) {
    colors <- c("red", "red", "red", "blue", "blue", "blue")
  }
  for (n in 1:nrow(all_teams)) {
    data <- c(all_teams[n], colors[n], alliancematchdata['comp_level'], matchdata['event_key'], matchdata['key'], matchdata['winning_alliance'], matchdata['alliances.blue.score'], matchdata['alliances.red.score'])
    data_by_team <- rbind(data_by_team, data)
  }
  
}

current_teams <- fromJSON("frc_allcurrent.json")
all_teams <- fromJSON("frc_allteams.json")

dead_teams <- all_teams %>% 
  anti_join(current_teams)

write_json(dead_teams, "frc_deadteams.json")

all_matches <- fromJSON("event_results.json")

matches_clean <- all_matches %>% 
  select(alliances:match_number, winning_alliance) %>% 
  flatten() %>% 
  select(comp_level, event_key, key, winning_alliance, alliances.blue.score, alliances.blue.team_keys, alliances.red.score, alliances.red.team_keys)

team_scores <- lapply(1:nrow(matches_clean), expand_df)

