library(tidyverse)
library(lubridate)
library(rvest)
library(janitor)

urls <- read_csv("url_csvs/NCAA Women's Soccer - 2022.csv") %>% pull(1) # change this to the year you need

season = "2022" # change this to match the year you are scraping

root_url <- "https://stats.ncaa.org"

urltibble <- tibble(
  school = character(),
  playerstatsurl = character(),
  matchstatsurl = character()
)

urlfilename <- paste0("url_csvs/ncaa_womens_soccer_teamurls_", season, ".csv")

for (i in urls){
  
  schoolpage <- i %>% read_html()
  
  schoolfull <- schoolpage %>% html_nodes(xpath = '//*[@id="contentarea"]/fieldset[1]/legend/a[1]') %>% html_text()
  
  playerstats_url <- schoolpage %>% html_nodes(xpath = '//*[@id="contentarea"]/a[2]') %>% html_attr('href')
  
  matchstats_url <- schoolpage %>% html_nodes(xpath = '//*[@id="contentarea"]/a[3]') %>% html_attr('href')
  
  playerstats <- paste(root_url, playerstats_url, sep="") %>% read_html() %>% html_nodes(xpath = '//*[@id="stat_grid"]') %>% html_table()
  
  urltibble <- urltibble %>% add_row(school = schoolfull, playerstatsurl = paste0(root_url, playerstats_url), matchstatsurl = paste0(root_url, matchstats_url))
  
  message <- paste0("Grabbing urls for ", schoolfull)
  
  print(message)
  
  Sys.sleep(2)
}

write_csv(urltibble, urlfilename)
