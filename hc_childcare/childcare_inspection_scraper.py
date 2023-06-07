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

driver = webdriver.Chrome()

response_deep = driver.get('https://www.checkccmd.org/default.aspx')
driver.find_element(By.PARTIAL_LINK_TEXT, "view all open providers").click()
driver.implicitly_wait(5)

soup = BeautifulSoup(driver.page_source, 'lxml')

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
