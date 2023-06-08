from bs4 import BeautifulSoup
from pprint import pprint
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Chrome()
wait = WebDriverWait(driver, 10)

# start on the all facilities page
url = 'https://www.checkccmd.org/SearchResults.aspx?ft=&fn=&sn=&z=&c=&co='
driver.get(url)
page_source = driver.page_source
soup = BeautifulSoup(page_source, 'html.parser')

# get the listings
table = soup.find('tbody')
list_of_rows = []
# skip the first row because it's a header
for row in table.find_all('tr')[1:]:
    list_of_cells = []
    for cell in row.find_all('td'):
        if cell.find('a'):
                list_of_cells.append(cell.text.strip())
                list_of_cells.append('https://www.checkccmd.org/'+cell.find('a')['href'])
                detail_page = 'https://www.checkccmd.org/'+cell.find('a')['href']
        elif cell.text.strip() != '':
            list_of_cells.append(cell.text.strip())
        driver.find_element(By.XPATH, )
    list_of_rows.append(list_of_cells)


for index, page in enumerate(range(2,501)):
    print(page)
    if page == 8:
        next_page = driver.find_element(By.LINK_TEXT, '...').click()
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
                driver.execute_script('''window.open("https://www.checkccmd.org/'+cell.find('a')['href']", "_blank");''')
            elif cell.text.strip() != '':
                list_of_cells.append(cell.text.strip())
        list_of_rows.append(list_of_cells)

pprint(list_of_rows)

