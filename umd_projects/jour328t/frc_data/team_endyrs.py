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

old_team_keys = []
with open('frc_deadteams.json', 'r') as dead:
    dead_teams = json.load(dead)
    for team in dead_teams:
         key = team['key']
         old_team_keys.append(key)

with open('frc_endyears.json', 'w') as file:
    file.write('[\n')
    for team in old_team_keys:
        url = base_url + "/team/" + team + "/years_participated"
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            # Request was successful
            team_data = response.json()
            # Process events_data
        team_dict = {}
        team_dict['key'] = team
        print(team)
        if len(team_data) > 0:
            team_dict['last_year'] = team_data[len(team_data)-1]
        else:
            team_dict['last_year'] = None
        json.dump(team_dict, file)
        if team == old_team_keys[len(old_team_keys) - 1]:
            file.write("\n")
        else:
            file.write(",\n")
    file.write(']')