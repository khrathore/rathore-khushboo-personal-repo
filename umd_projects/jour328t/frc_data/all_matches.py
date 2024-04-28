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

event_keys = []
with open('frc_events.json', 'r') as events:
    events = json.load(events)
    for event in events:
        event_key = event['key']
        event_keys.append(event_key)

with open('event_matches.json', 'w') as file:
    file.write('[\n')
    for event in event_keys:
        url = base_url + "/event/" + event + "/matches"
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            # Request was successful
            match_data = response.json()
            # Process events_data
        for match in match_data:
                json.dump(match, file)
                if (event == '2024xxmel') & (match == match_data[len(match_data) - 1]):
                     file.write("\n")
                else:
                    file.write(",\n")
    file.write(']')