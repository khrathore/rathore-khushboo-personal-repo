import requests
import os
import tbaapiv3client
import yaml
import pprint
import json

base_url = "https://www.thebluealliance.com/api/v3"

headers = {
    'X-TBA-Auth-Key': os.environ.get('TBA_API')
}

pages_list = [page for page in range(0, 20)]

with open('frc_allcurrent.json', 'w') as file:
    file.write('[\n')
    for page in pages_list:
        url = base_url + "/teams/2024/" + str(page)
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            # Request was successful
            team_data = response.json()
            # Process events_data
        for team in team_data:
                json.dump(team, file)
                if (page == 19) & (team == team_data[len(team_data) - 1]):
                     file.write("\n")
                else:
                    file.write(",\n")
    file.write(']')