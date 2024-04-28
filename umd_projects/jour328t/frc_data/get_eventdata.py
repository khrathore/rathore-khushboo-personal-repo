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

years_list = [year for year in range(1992, 2025)]

with open('frc_events.json', 'w') as file:
    file.write('[\n')
    for year in years_list:
        url = base_url + "/events/" + str(year)
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            # Request was successful
            events_data = response.json()
            # Process events_data
        for event in events_data:
                json.dump(event, file)
                if (year == 2024) & (event == events_data[len(events_data) - 1]):
                     file.write("\n")
                else:
                    file.write(",\n")
    file.write(']')









