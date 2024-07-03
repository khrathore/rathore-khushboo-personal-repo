import time
from bs4 import BeautifulSoup
from selenium import webdriver
from pprint import pprint
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException
import csv

driver = webdriver.Chrome()

def click_next_button(driver, max_retries=3):
    retries = 0
    while retries < max_retries:
        try:
            # Wait for the next button to be clickable
            next_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//button[contains(text(), 'Next')]"))
            )
            # Scroll to the next button
            driver.execute_script("arguments[0].scrollIntoView();", next_button)
            
            # Click the next button
            next_button.click()
            
            # If click succeeds, exit the loop
            return True
        
        except (TimeoutException, ElementClickInterceptedException) as e:
            print(f"Attempt {retries + 1} failed: {str(e)}")
            retries += 1
            time.sleep(2)  # Wait a bit before retrying
    
    # If max retries reached without success
    print("Maximum retries reached. Could not click Next button.")
    return False

# start on the all facilities page
url = 'https://childcarefinder.wisconsin.gov/SearchResults?CCF=Y&UserSessionId=0be9f13d-6843-4f4b-b911-9b7f46698752&Distance=5'
driver.get(url)

time.sleep(15)
page_num = 0


cc_header = ["provider_type", "facility_name", "provider_link", "rating", "address"]
with open ('list_of_facilities.csv', mode='a', newline = "") as basiccsv:
    bline_writer = csv.writer(basiccsv)
    bline_writer.writerow(cc_header)

while page_num < 3:
    page_source = driver.page_source
    soup = BeautifulSoup(page_source, 'html.parser')
    table = soup.find_all('tbody')[1]
    with open ('list_of_facilities.csv', mode='a', newline = "") as basiccsv:
        bline_writer = csv.writer(basiccsv)
        for row in table.find_all('tr'):
            list_of_cells = []
            for cell in row.find_all('td'):
                if cell.find('a'):
                    list_of_cells.append(cell.text.strip())
                    list_of_cells.append('https://childcarefinder.wisconsin.gov/'+cell.find('a')['href'])
                elif cell.find(class_='text-nowrap'):
                    title_div = cell.find('div').get('title')
                    list_of_cells.append(title_div)
                elif cell.text.strip() != '':
                    list_of_cells.append(cell.text.strip())
                elif cell.text.strip() == '':
                    continue
            bline_writer.writerow(list_of_cells)
    click_next_button(driver)
    page_num = page_num + 1

        
        

#pprint(list_of_rows)
#print(detail_rows)


