library(xml2)
library(methods)
library(tidyverse)
library(XML)
library(furrr)
library(stringi)
library(httr)
library(rlang)
library(janitor)
library(paws)
library(aws.s3)
library(tools)
library(pdftools)
library(sys)
if (!require("ppcong")) {
  install.packages("ppcong")
  library(ppcong)
}

#xml_listing <- xml_find_first(current_data, ".//dbo.filer")
#file_number <- 1
# Function to convert all xml listings into a table for each filer
xml_to_table <- function(file_number) {
  xml_listing <- all_listings[[file_number]]
  # Get attributes of filer and office name
  LastName <- xml_attr(xml_listing, "LastName")
  FirstName <- xml_attr(xml_listing, "FirstName")
  OfficeName <- xml_attr(xml_find_first(xml_listing, ".//dbo.Office"), "OfficeName")
  # Create a list of all filings made my the filer
  all_filings <- xml_find_all(xml_listing, ".//dbo.Document")
  traveler_filings <- data.frame()
  #For each filing, extract information and put it in a dataframe
  for(filing_num in 1:length(all_filings)) {
    filing <- all_filings[[filing_num]]
    ReportingYear <- xml_attr(filing, "ReportingYear")
    BeginTravelDate <- xml_attr(filing, "BeginTravelDate")
    EndTravelDate <- xml_attr(filing, "EndTravelDate")
    DateReceived <- xml_attr(filing, "DateReceived")
    TransactionDate <- xml_attr(filing, "TransactionDate")
    Pages <- xml_attr(filing, "Pages")
    ReportTitle <- xml_attr(xml_find_first(filing, ".//dbo.Reports"), "ReportTitle")
    DocURL <- xml_attr(xml_find_first(filing, ".//dbo.Reports"), "DocURL")
    report_data <- c(LastName, FirstName, OfficeName, ReportTitle, ReportingYear, BeginTravelDate, EndTravelDate, DateReceived, TransactionDate, Pages, DocURL)
    traveler_filings <- rbind(traveler_filings, report_data)
  }
  traveler_filings <- setNames(traveler_filings, c("filer_lastname", "filer_firstname", "filer_office", "report_title", "reporting_year", "begin_travel_date", "end_travel_date", "date_received", "transaction_date", "num_pages", "doc_url")) %>% 
    mutate(begin_travel_date = as.Date(begin_travel_date,  "%m/%d/%Y")) %>% 
    mutate(end_travel_date = as.Date(end_travel_date,  "%m/%d/%Y")) %>% 
    mutate(date_received = as.Date(date_received,  "%m/%d/%Y")) %>% 
    mutate(transaction_date = as.Date(transaction_date,  "%m/%d/%Y")) %>% 
    mutate(num_pages = as.double(num_pages)) %>% 
    mutate(reporting_year = as.double(reporting_year)) %>% 
    mutate(doc_url = str_replace(doc_url, "http:", "https:"))
}


# Pulls a list of senate members for given session from ProPublica's API
senate_members <- function(senate_year) {
  senators_session <- ppc_members(congress = senate_year, chamber = "senate")
}

# Expands a dataframe of senators to have one row for each year they were in office
expand_df <- function(senator) {
  senator_info <- senate_problems[senator, ]
  if (senator_info$finitial_lname == "E KENNEDY") {
    num_years <- 2009 - senator_info$first_year
  } else {
    num_years <- senator_info$next_election - senator_info$first_year
  }
  df_senator <- tibble()
  n <- 0
  first_year <- senator_info$first_year
  while (n <= num_years) {
    sen_info <- senator_info %>% 
      mutate(reporting_year = first_year + n)
    df_senator <- rbind(df_senator, sen_info)
    n <- n + 1  
  }
  df_senator
}

download_file_with_retry <- function(url, destination, max_attempts = 10) {
  tryCatch(
    {
      download.file(url, destination, mode = "wb")
      message("File downloaded successfully!")
    },
    error = function(e) {
      if (max_attempts > 0) {
        message("Error occurred:", e)
        message("Retrying download...")
        Sys.sleep(5)  # Wait for 5 seconds before retrying
        download_file_with_retry(url, destination, max_attempts - 1)
      } else {
        message("Max attempts reached. Download failed.")
      }
    }
  )
}

pdf_downloads <- function(row_num) {
  pdf <- new_docs$doc_url[row_num]
  file_name <- new_docs$file_name[row_num]
  pdf_path <- paste0("senate_files/file_download_local/", file_name)
  download_file_with_retry(pdf, pdf_path)
}

make_request <- function(link) {
  print(url <- link)
  
  refresh <- POST("https://accounts.muckrock.com/api/refresh/", body=list(refresh=content(tokens)$refresh))
  
  header <- paste("Bearer", content(refresh)$access)
  response <- GET(url, add_headers(Authorization=header))
  content(response, as="parsed")
  
  if (response$status_code == 403) {
    refresh <- POST("https://accounts.muckrock.com/api/refresh/", body=list(refresh=content(tokens)$refresh))
    header <- paste("Bearer", content(refresh)$access)
    response <- GET(url, add_headers(Authorization=header))
    content(response, as="parsed", encoding=charset)
  } else {
    header <- paste("Bearer", content(refresh)$access)
    response <- GET(url, add_headers(Authorization=header))
    content(response, as="parsed", encoding=charset)
  }
}

# Gets the current senate xml data and converts to a dataframe, then CSV. Each day this is run, you will get three more files in the data folder, so proceed with caution.

# Get the current date
today_date <- Sys.Date()

# Create a file path for the zip to download and download the zip file there
zip_loc <- paste0("senate_files/data/senate_data_original/senate_data_", today_date, ".zip")
#zip_loc <- "data/senate_data_original/senate_data_2023-10-25.zip"
download.file("https://giftrule-disclosure.senate.gov/media/giftruledownloads/giftruledata.zip", zip_loc, mode = "wb")

# Create a filepath for the XML and unzip the file into the data folder
xml_loc <- gsub(".zip", ".xml", zip_loc)
unzip(zip_loc, exdir = "senate_files/data/")

#Rename the unzipped file to follow project convention
file.rename("senate_files/data/giftrule.xml", xml_loc)

#Import XML data into a nested list
current_data <- read_xml(xml_loc)

#Create a list of all the filers and their documents
all_listings <- xml_find_all(current_data, ".//dbo.filer")

# Speedy for loop to get all the information
filer_travel <- map_dfr(c(1:length(all_listings)), xml_to_table) %>% 
  mutate(source = today_date)

filer_travel_clean <- filer_travel %>%
  mutate(office_firstname = str_squish(str_extract(filer_office, "(?<=,).*"))) %>% 
  mutate(office_last_name = str_squish(str_extract(filer_office, "^[^,]+"))) %>% 
  mutate(office_middle_name = str_squish(str_extract(office_firstname, "\\s(.*)"))) %>% 
  mutate(office_first_name = str_squish(str_extract(office_firstname, "^[^\\s]+"))) %>%
  select(filer_lastname, filer_firstname, filer_office, office_first_name, office_middle_name, office_last_name, report_title, reporting_year, begin_travel_date, end_travel_date, date_received, transaction_date, num_pages, doc_url, source)

# Upload data from most recent old data and create a list of all filings, including a column that shows if the row came from new data or old data.

# List all files in the original data folder

most_recent_csv <- "senate_files/data/senate_data_with_propublica/clean_propub_senate_current.csv"

# Get the data and make some cleaning changes for the old csv
last_data <- read_csv(most_recent_csv) %>%
  mutate(begin_travel_date = as.Date(begin_travel_date)) %>% 
  mutate(end_travel_date = as.Date(end_travel_date)) %>% 
  mutate(date_received = as.Date(date_received)) %>% 
  mutate(transaction_date = as.Date(transaction_date))

# Make a list of the filings in data since data collection began on 08 September
all_filings <- filer_travel_clean %>% 
  full_join(last_data, by = c("filer_lastname", "filer_firstname", "filer_office", "report_title", "reporting_year", "begin_travel_date", "end_travel_date", "date_received", "transaction_date", "num_pages", "doc_url", "office_first_name", "office_last_name", "office_middle_name")) %>% 
  mutate(source = case_when(
    is.na(source.x) ~ source.y,
    TRUE~source.x)) %>% 
  select(-source.x, -source.y)

clean_filings <- all_filings %>% 
  filter(is.na(id) & source == today_date & is.na(document_link)) %>% 
  select(-(id:is_member))

old_filings <- all_filings %>% 
  filter(!(is.na(id) & source == today_date & is.na(document_link)))

# Join data with ProPublica API data

ppc_api_key("yfwQJnKLugEVpq3ejDO4IACQ36IFtow9MXphxeJd", set_renv = TRUE)

all_senators <- map_dfr(c(107:118), senate_members)

# Create a dataframe with a column for the last year of office for each senator
senators_last_year <- all_senators %>% 
  arrange(desc(congress)) %>% 
  distinct(id, .keep_all = TRUE) %>% 
  rename(congress_recent = congress) %>%
  mutate(next_election = as.numeric(next_election)) %>% 
  select(id, first_name, middle_name, last_name, congress_recent, next_election)

# Create a dataframe with a column for the earliest relevant year of office for each senator
senators_first_year <- all_senators %>% 
  distinct(id, .keep_all = TRUE) %>% 
  rename(congress_first = congress) %>% 
  mutate(first_year = as.numeric(next_election) - 5) %>% 
  select(id, first_name, middle_name, last_name, congress_first, first_year)

# Clean up propublica data
senators_clean <- senators_first_year %>% 
  inner_join(senators_last_year, by = c("id", "first_name", "middle_name", "last_name")) %>% 
  mutate(office_first_name = stri_trans_general(toupper(first_name), "Latin-ASCII")) %>% 
  mutate(office_middle_name = stri_trans_general(gsub(".", "", toupper(middle_name), fixed = TRUE), "Latin-ASCII")) %>% 
  mutate(office_last_name = stri_trans_general(toupper(last_name), "Latin-ASCII")) %>% 
  select(id, office_first_name, office_middle_name, office_last_name, congress_first, congress_recent, first_year, next_election) %>% 
  mutate(finitial_lname = paste0(substr(office_first_name, 1, 1), " ", office_last_name))

# Join to filings by full name
filings_and_senators_fj <- clean_filings %>% 
  left_join(senators_clean, by = c("office_last_name", "office_middle_name", "office_first_name"))

# Smaller subset of senators
senators_clean_mini <- senators_clean %>% 
  select(-office_first_name, -office_middle_name, -office_last_name)

# Join to filings by first initial, last name
filings_and_senators_sj <- filings_and_senators_fj %>% 
  filter(is.na(congress_first)) %>% 
  select(-congress_first, -congress_recent, -first_year, -next_election, -id) %>% 
  mutate(finitial_lname = paste0(substr(office_first_name, 1, 1), " ", office_last_name)) %>% 
  left_join(senators_clean_mini, by = "finitial_lname")

# Just PP last names
senate_clean_lname <- senators_clean %>% 
  select(-office_first_name, -office_middle_name)

# Join by last name excepting some problem cases
filings_and_senators_tj <- filings_and_senators_sj %>% 
  filter(is.na(congress_first)) %>% 
  select(-congress_first, -congress_recent, -first_year, -next_election, -id, -finitial_lname) %>% 
  filter(!(str_detect(office_last_name, "SCOTT|JOHNSON|KENNEDY|WARNER") | office_last_name == "BROWN" | office_last_name == "SMITH" | office_last_name == "KIRK")) %>% 
  left_join(senate_clean_lname, by = "office_last_name")

# Problem Children: Scott and Sherrod Brown, Tim and Rick Scott, Tim and Ron Johnson, John and Edward Kennedy, Tina and Gordon Smith, John and Mark Warner

# List of problem senators
senate_problems <- senators_clean %>% 
  filter(str_detect(office_last_name, "SCOTT|JOHNSON|KENNEDY|WARNER") | office_last_name == "BROWN" | office_last_name == "SMITH"| office_last_name == "KIRK") %>% 
  select(-office_middle_name)

# List of problem filings
problem_children <- filings_and_senators_sj %>% 
  filter(is.na(congress_first)) %>% 
  select(-congress_first, -congress_recent, -first_year, -next_election, -id, -finitial_lname) %>% 
  filter(str_detect(office_last_name, "SCOTT|JOHNSON|KENNEDY|WARNER") | office_last_name == "BROWN" | office_last_name == "SMITH"| office_last_name == "KIRK")

# Doable: Warner, Smith, Kennedy, Scott < 2019, Johnson < 2011, Brown > 2012
# Create dataframe with all years each problem senator has served
problem_all_years <- map_dfr(c(1:nrow(senate_problems)), expand_df) %>% 
  select(-office_first_name)

# If the senators with the last name did not overlap, Join to PP on last_name and reporting year
no_overlap_senators <- problem_children %>% 
  filter(str_detect(office_last_name, "WARNER|SMITH|KENNEDY") | (office_last_name == "SCOTT" & reporting_year < 2019) | (office_last_name == "JOHNSON" & reporting_year < 2011) | (office_last_name == "BROWN" & reporting_year > 2012) | (office_last_name == "KIRK" & (reporting_year < 2011 | reporting_year > 2012))) %>% 
  left_join(problem_all_years, by = c("office_last_name", "reporting_year"))

# Unclear: Charlie Lyons
# If they did overlap, each filer was googled to find the office. See case_when statement
overlapped_senators <- problem_children %>% 
  filter(!(str_detect(office_last_name, "WARNER|SMITH|KENNEDY") | (office_last_name == "SCOTT" & reporting_year < 2019) | (office_last_name == "JOHNSON" & reporting_year < 2011) | (office_last_name == "BROWN" & reporting_year > 2012) | (office_last_name == "KIRK" & (reporting_year < 2011 | reporting_year > 2012)))) %>% 
  mutate(office_first_name = case_when(
    office_last_name == filer_lastname ~ filer_firstname,
    str_detect(filer_lastname, "ZEBROWSKI|STEELE|SLEVIN|POWDEN|KUEBLER|JAWANDO|HEIMBACH|GLICK|DOWNING|HONEY") ~ "SHERROD",
    str_detect(filer_lastname, "SINDERS") ~ "SCOTT",
    str_detect(filer_lastname, "WEAVER") ~ "RON",
    str_detect(filer_lastname, "SWANSON|SAMUELSON") ~ "TIM",
    str_detect(filer_lastname, "FOLTZ") ~ "RICK",
    str_detect(filer_lastname, "KIRK|GOLDBERG|MCCARTHY|WINTERS|BLUM") ~ "MARK",
    TRUE ~ office_first_name
  )) %>% 
  left_join(senate_problems, by = c("office_last_name", "office_first_name"))

# Join all the filings together
all_filings_matches <- filings_and_senators_fj %>% 
  filter(!is.na(congress_first)) %>% 
  rbind(filings_and_senators_sj) %>% 
  filter(!is.na(congress_first)) %>% 
  rbind(filings_and_senators_tj) %>% 
  rbind(no_overlap_senators) %>% 
  rbind(overlapped_senators)

# Get some more propublica info
senators_ppinfo <- all_senators %>%
  select(id, title, suffix, seniority, date_of_birth, gender, party, state) %>% 
  distinct(id, .keep_all = TRUE)

# Join propublica additional info to filings by id
filings_and_pp <- all_filings_matches %>% 
  left_join(senators_ppinfo) %>%
  mutate(notes = case_when(
    filer_lastname == "LYONS" ~ "Senator Sherrod or Scott Brown, unclear, likely Sherrod. Have contacted legistorm.",
    TRUE~NA)) %>% 
  mutate(is_member = case_when(
    str_detect(report_title, "Member") ~ TRUE,
    TRUE ~ FALSE
  )) %>% 
  mutate(file_name = str_extract(doc_url, "(?<=/)[^/]+\\.pdf")) %>% 
  mutate(document_title = gsub(".pdf", "", file_name)) %>% 
  filter(!is.na(document_title)) %>% 
  select(-(congress_first:seniority)) %>% 
  rbind(old_filings) %>% 
  distinct(filer_lastname, filer_firstname, office_last_name, reporting_year, begin_travel_date, end_travel_date, date_received, transaction_date, id, file_name, .keep_all = TRUE)

duplicates <- filings_and_pp %>% 
  filter(!is.na(file_name)) |> 
  group_by(file_name) |> 
  summarise(count = n()) |> 
  arrange(desc(count)) |> 
  filter(count > 1)

filings_copy <- filings_and_pp %>% 
  inner_join(duplicates, by = "file_name") %>% 
  arrange(source) %>% 
  mutate(filer_lastname = case_when(
    filer_lastname == "GOTTRIED" ~ "GOTTFRIED",
    TRUE ~ filer_lastname
  )) %>% 
  distinct(file_name, .keep_all = TRUE) %>% 
  select(-count)

filings_and_pp <- filings_and_pp %>% 
  anti_join(duplicates, by = "file_name") %>% 
  rbind(filings_copy)
  

# Write joined data

new_docs <- filings_and_pp %>% 
  filter(!is.na(file_name)) %>% 
  filter(is.na(document_link))

if (nrow(new_docs) > 0) {
  for (n in 1:nrow(new_docs)) {
    pdf_downloads(n)
  }
}


files <- list.files(path="senate_files/file_download_local/", pattern="*.pdf", full.names=TRUE, recursive=TRUE)
  
#switch out with files_split, files_nonsplit to upload both sets to DocumentCloud, in next iteration, combine the lists?
for (file in files) {
  
  #getting just the file_name for uploading to DocumentCloud
  file_name <- gsub(".pdf", "", basename(file))
  
  #Authentication
  tokens <- POST("https://accounts.muckrock.com/api/token/", body=list(username="dwillis-umd", password="Zm7Qdm9PGEwH2hj"), encode="json")
  refresh <- POST("https://accounts.muckrock.com/api/refresh/", body=list(refresh=content(tokens)$refresh))
  
  
  #POST request to make empty document
  header <- paste("Bearer", content(refresh)$access)
  
  #Replace "PROJECT_ID" with the ID of the project you want to upload to (Searchable Police Deaths = 210414, Searchable Police Encounters = 209606)
  response <- POST("https://api.www.documentcloud.org/api/documents/", body = list(title=file_name, projects=list("215850"), access="organization"), encode = "json", add_headers(Authorization=header))
  content(response, as="parsed")
  
  #PUT request to assign file path to presigned_url
  id <- content(response)$id
  url <- content(response)$presigned_url
  response <- PUT(url, body = upload_file(file), encode = "json")
  content(response, as="parsed")
  
  #POST request to process documents and upload
  response <- POST(paste("https://api.www.documentcloud.org/api/documents/", id,"/process/", sep=""), body=list(force_ocr=FALSE), encode = "json", add_headers(Authorization=header))
  content(response, as="parsed")
  
  response <- GET(url, add_headers(Authorization=header))
  content(response, as = "parsed")
  
  file.remove(file)
  
}

link <-"https://api.www.documentcloud.org/api/documents/?project=215850"

response <- make_request(link)

next_page <- response$`next`

while (!(is.null(next_page))) {
  next_response <- make_request(next_page)
  response$results <- c(response$results, next_response$results)
  next_page <- next_response$`next`
}

all_documents_ocr_info <- tibble(
  document_id = as.integer(NA),
  document_slug = as.character(NA),
  document_title = as.character(NA),
  page_count = as.integer(NA),
  document_link = as.character(NA),
  created_at = as.character(NA)
) %>%
  remove_empty(which="rows")

for(result in response$results){
  doc_id <- result$id
  slug <- result$slug
  title <- result$title
  num_pages <- result$page_count
  link <- result$canonical_url
  created <- result$created_at
  
  temp <- tibble(
    document_id = NA,
    document_slug = NA,
    document_title = NA,
    page_count = NA,
    document_link = NA,
    created_at = NA
  ) %>%
    mutate(document_id=doc_id) %>%
    mutate(document_slug = slug) %>%
    mutate(document_title=title) %>%
    mutate(page_count=num_pages) %>%
    mutate(document_link=link) %>%
    mutate(created_at=created)
  
  
  all_documents_ocr_info <- all_documents_ocr_info %>%
    bind_rows(unique(temp))
}

doc_links <- all_documents_ocr_info %>% 
  select(document_title, document_link)

filings_and_pp <- filings_and_pp %>% 
  mutate(document_title = gsub(".pdf", "", file_name)) %>%
  left_join(doc_links, by = "document_title") %>% 
  select(-document_link.x) %>% 
  rename(document_link = document_link.y) %>% 
  filter(!is.na(document_title))

write_csv_loc <- paste0("senate_files/data/senate_data_with_propublica/clean_propub_senate_current.csv")
write_csv(filings_and_pp, write_csv_loc)

