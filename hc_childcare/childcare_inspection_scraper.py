from bs4 import BeautifulSoup
from pprint import pprint
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import re

driver = webdriver.Chrome()
wait = WebDriverWait(driver, 10)

# start on the all facilities page
url = 'https://www.checkccmd.org/SearchResults.aspx?ft=&fn=&sn=&z=&c=&co='
driver.get(url)
page_source = driver.page_source
soup = BeautifulSoup(page_source, 'html.parser')

#Scrape, then click on each link and collect details, then hit back button and go to next

list_of_rows = []
detail_rows = [] 
for index, page in enumerate(range(1,2)):
    if page == 8:
        next_page = driver.find_element(By.LINK_TEXT, '...').click()
    elif page == 1:
        page = 1
    elif page % 7 == 1:
        next_page = driver.find_elements(By.LINK_TEXT, '...')[1].click()
    else:
        next_page = driver.find_element(By.LINK_TEXT, str(page)).click()
    page_source = driver.page_source
    soup = BeautifulSoup(page_source, 'html.parser')
    table = soup.find('tbody')
    for row in table.find_all('tr')[1:]:
        list_of_cells = []
        for cell in row.find_all('td'):
            if cell.find('a'):
                list_of_cells.append(cell.text.strip())
                list_of_cells.append('https://www.checkccmd.org/'+cell.find('a')['href'])
            elif cell.text.strip() != '':
                list_of_cells.append(cell.text.strip())
        list_of_rows.append(list_of_cells)
    a_tags = driver.find_elements(By.TAG_NAME, "a")
    facilities = [x for x in a_tags if "FacilityDetail" in x.get_attribute('href')]
    for facility in facilities:
        facility.click()
        dict_facility = {}
        page_source = driver.page_source
        soup = BeautifulSoup(page_source, 'html.parser')
        detail_lists = (soup.find_all('ul'))[0:2]
        # get the information for each place
        for columns in detail_lists:
            entries = columns.find_all('li')      
            for entry in entries:
                #entry = entries[0]
                if entry.find(class_='Excelslogo'):
                    key = "Maryland Excels Level"
                    value = entry.find(class_ = "detailLevelText").text.strip()
                    dict_facility[key] = value
                elif entry.text.strip() != '':
                    key = entry.find(class_='labelForm').text.strip()
                    value = entry.find(class_='detailText').text.strip()
                    dict_facility[key] = value
                else:
                    next
        detail_rows.append(dict_facility)
        soup.find(id_="MainContent_LinkBack").click()
        

pprint(list_of_rows)
print(detail_rows)