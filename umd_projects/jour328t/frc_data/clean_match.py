import json

# Function to remove "score_breakdown" category
def remove_score_breakdown(data):
    for item in data:
        if 'score_breakdown' in item:
            del item['score_breakdown']
    return data

# Read JSON data from file
input_file_path = 'event_matches.json'  # Specify the path to your input file
output_file_path = 'event_results.json'  # Specify the path to your output file

with open(input_file_path, 'r') as file:
    json_data = json.load(file)

# Remove "score_breakdown"
cleaned_data = remove_score_breakdown(json_data)

# Write cleaned data to a new file
with open(output_file_path, 'w') as file:
    json.dump(cleaned_data, file, indent=4)

print("Cleaning and writing completed successfully.")
