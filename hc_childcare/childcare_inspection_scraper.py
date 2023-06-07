import requests
from bs4 import BeautifulSoup
from pprint import pprint
import requests_html

url = 'https://www.checkccmd.org/SearchResults.aspx?ft=&fn=&sn=&z=&c=&co='
response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
html = response.content
# print(html)

soup = BeautifulSoup(html, features="html.parser")
table = soup.find('tbody')
# print(table.prettify())

list_of_rows = []
for row in table.find_all('tr'):
    list_of_cells = []
    for cell in row.find_all('td'):
        list_of_cells.append(text)
    list_of_rows.append(list_of_cells)

print(list_of_rows)

#cell.text.find('a')['href']

from bs4 import BeautifulSoup
from pprint import pprint
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Chrome()
wait = WebDriverWait(driver, 10) 

driver.get('https://www.checkccmd.org/default.aspx')
full_list = driver.find_element(By.PARTIAL_LINK_TEXT, "view all open providers")
full_list.click()
element_present = EC.presence_of_element_located((By.PARTIAL_LINK_TEXT , 'A-Level'))
wait.until(element_present)
page_source = driver.page_source

soup = BeautifulSoup(page_source, 'html.parser')
print(soup)
table = soup.find('tbody')
print(table.prettify())

list_of_rows = []
for row in table.find_all('tr'):
    list_of_cells = []
    for cell in row.find_all('td'):
        list_of_cells.append(cell.text)
    list_of_rows.append(list_of_cells)

print(table.prettify())

list_of_rows = []
for row in table.find_all('tr'):
    list_of_cells = []
    for cell in row.find_all('td'):
        text = cell.text.strip()
        list_of_cells.append(text)
    list_of_rows.append(list_of_cells)

print(list_of_rows)

#print(response_deep)
html_deep = response_deep.html.find('li', first=True)
pprint(html_deep.text)

soup_deep = BeautifulSoup(html_deep, features="html.parser")
table_deep = soup_deep.find_all("li")
pprint(table_deep)
