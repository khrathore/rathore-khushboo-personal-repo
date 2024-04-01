from bs4 import BeautifulSoup
from selenium import webdriver
from pprint import pprint
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import csv
import requests
import tabula

# start on the all facilities page
download_url = 'https://checkccmd.org/PublicReports/OpenProviderReport.aspx?ft='
response = requests.get(download_url)

pdf_list = "childcare_providers.pdf"

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Open a file in binary write mode to save the zip file
    with open(pdf_list, 'wb') as data:
        # Write the content of the response to the file
        data.write(response.content)

childcare_dfs = tabula.read_pdf("childcare_providers.pdf", pages='all')


