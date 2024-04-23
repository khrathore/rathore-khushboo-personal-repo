library(tidyverse)
library(janitor)
library(lubridate)

state_employee <- read_csv("State_of_Iowa_Salary_Book.csv")
all_income <- read_csv("Annual_Personal_Income_for_State_of_Iowa_by_County.csv")

all_income_clean <- all_income %>% 
  clean_names() %>% 
  mutate(date = mdy(date)) %>% 
  mutate(year = year(date)) %>% 
  filter(year >= 2007) %>% 
  filter(variable_code == "CAINC1-3") %>% 
  select(name, year, value)

all_counties <- all_income %>% 
  clean_names() %>% 
  distinct(name, geography_id)

state_employee_clean <- state_employee %>% 
  clean_names() %>% 
  select(total_salary_paid, fiscal_year, place_of_residence, base_salary) %>% 
  mutate(name = str_to_sentence(place_of_residence)) %>% 
  inner_join(all_counties, by = "name") %>%
  mutate(base_salary = as.double(gsub("[^0-9.]", "", base_salary))) %>%
  mutate(base_salary = case_when(
    is.na(base_salary) ~ 0,
    TRUE ~ base_salary
  )) %>% 
  mutate(total_salary_paid = case_when(
    is.na(total_salary_paid) ~ base_salary,
    total_salary_paid == 0 ~ base_salary,
    TRUE ~ total_salary_paid
  )) %>% 
  rename(year = fiscal_year) %>% 
  filter(year < 2023) %>% 
  group_by(name, year) %>% 
  summarize(
    count_salary_employee = n(),
    median_salary_employee = median(total_salary_paid),
    mean_salary_employee = mean(total_salary_paid)
  )

employee_overall <- all_income_clean %>% 
  full_join(state_employee_clean, by = c("name", "year")) %>% 
  mutate(mean_diff = value - mean_salary_employee) %>% 
  mutate(median_diff = value - median_salary_employee) %>% 
  left_join(all_counties, by = "name")

write_csv(employee_overall, "employment_comparison.csv")
  
  
