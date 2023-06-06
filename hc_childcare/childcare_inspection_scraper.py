import requests
from bs4 import BeautifulSoup

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
        if cell.find('a'):
            
        text = cell.text.strip()
        list_of_cells.append(text)
    list_of_rows.append(list_of_cells)

print(list_of_rows)

#cell.text.find('a')['href']

import requests
from bs4 import BeautifulSoup
deep_url = 'https://www.checkccmd.org/FacilityDetail.aspx?ft=&fn=&sn=&z=&c=&co=&fi=463466'
response_deep = requests.get(deep_url, headers={'User-Agent': 'Mozilla/5.0'})
html_deep = response_deep.content
print(html_deep)

soup_deep = BeautifulSoup(html_deep, features="html.parser")
print(soup_deep.prettify())
table_deep = soup_deep.find(class_= 'detailRow')
print(table_deep)
