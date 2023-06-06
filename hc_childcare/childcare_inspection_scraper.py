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
        if cell.find('a'):
            
        text = cell.text.strip()
        list_of_cells.append(text)
    list_of_rows.append(list_of_cells)

print(list_of_rows)

#cell.text.find('a')['href']

import requests
from bs4 import BeautifulSoup
from pprint import pprint
import requests_html as r_html

session = r_html.HTMLSession()

deep_url = 'https://www.checkccmd.org/FacilityDetail.aspx?ft=&fn=&sn=&z=&c=&co=&fi=463466'
response_deep = session.r_html.get(deep_url)
table_deep = response_deep.r_html.find_all("li")
pprint(table_deep)
