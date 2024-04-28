install.packages("tidyverse")
install.packages("jsonlite")

library(tidyverse)
library(jsonlite)

current_teams <- fromJSON("frc_allcurrent.json")
all_teams <- fromJSON("frc_allteams.json")

dead_teams <- all_teams %>% 
  anti_join(current_teams)

write_json(dead_teams, "frc_deadteams.json")
