from bs4 import BeautifulSoup
from selenium import webdriver
from pprint import pprint
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import csv

driver = webdriver.Chrome()
wait = WebDriverWait(driver, 60)

# start on the all facilities page
url = 'https://www.checkccmd.org/SearchResults.aspx?ft=&fn=&sn=&z=&c=&co='
driver.get(url)
page_source = driver.page_source
soup = BeautifulSoup(page_source, 'html.parser')


#Scrape, then click on each link and collect details, then hit back button and go to next
list_of_rows = []
detail_rows = []

for page in enumerate(range(1,8)):
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
    num_rows = 0
    with open ('checkcc_basic.csv', mode='a', newline = "") as basiccsv:
        bline_writer = csv.writer(basiccsv)
        for row in table.find_all('tr')[1:]:
            list_of_cells = []
            for cell in row.find_all('td'):
                if cell.find('a'):
                    list_of_cells.append(cell.text.strip())
                    list_of_cells.append('https://www.checkccmd.org/'+cell.find('a')['href'])
                elif cell.text.strip() != '':
                    list_of_cells.append(cell.text.strip())
            list_of_rows.append(list_of_cells)
            bline_writer.writerow(list_of_cells)
            num_rows = num_rows + 1
    n = 0
    # While n is less than the number of rows on the page:
    # generate atags
    # get the facility href
    # click, process, click back
    # go back to top of loop
    while n < num_rows:
        wait
        a_tags = driver.find_elements(By.TAG_NAME, "a")
        facility = [x for x in a_tags if "FacilityDetail" in x.get_attribute('href')][n]
        #print(facility)
        #print(len(facilities))
        facility.click()
        #print("new facility")
        dict_facility = {}
        page_source = driver.page_source
        soup = BeautifulSoup(page_source, 'html.parser')
        detail_lists = soup.find_all('ul')[0:2]
        with open ('checkcc_complex.csv', mode='a', newline = "") as complexcsv:
            for columns in detail_lists:
                entries = columns.find_all('li')
                for entry in entries:
                    if entry.find(class_='Excelslogo'):
                        key = "Maryland Excels Level"
                        value = entry.find(class_ = "detailLevelText").text.strip()
                        dict_facility[key] = value
                    elif entry.text.strip() != '':
                        try:
                            key = entry.find(class_='labelForm').text.strip()
                            value = entry.find(class_='detailText').text.strip()
                        except AttributeError:
                            key = "none"
                            value = "none"
                        dict_facility[key] = value
                    else:
                        next
            fieldnames = dict_facility.keys()
            dict_writer = csv.DictWriter(complexcsv, fieldnames=fieldnames)
            #dict_writer.writeheader()  # Write the header row (optional)
            dict_writer.writerow(dict_facility)
            detail_rows.append(dict_facility)
        #link = driver.find_element(By.ID, 'MainContent_LinkBack')
        #link.click()
        n = n + 1
        driver.back()
        
        

pprint(list_of_rows)
print(detail_rows)


