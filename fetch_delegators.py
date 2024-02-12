import requests
import json
import re

api_url = "https://explorer.hamp.app/api/v1/mapping/list_program_mapping_values/credits.aleo/bonded"

response = requests.get(api_url)

if response.status_code == 200:
    data = response.json()

    validator_address = "<YOUR-VAL-ADDRESS>"

    filtered_delegators = []
    for key, item in data.items():
        corrected_value_str = re.sub(r'(\w+):', r'"\1":', item['value'])
        corrected_value_str = corrected_value_str.replace('u64', '')
        corrected_value_str = corrected_value_str.replace('validator:', '"validator":').replace(', microcredits:', ', "microcredits":')
        corrected_value_str = re.sub(r'aleo1\w+', lambda x: '"' + x.group(0) + '"', corrected_value_str)

        try:
            value_dict = json.loads(corrected_value_str)
            if value_dict.get('validator') == validator_address:
                filtered_delegators.append(item["key"])
        except json.JSONDecodeError as e:
            print(f"JSON decode error: {e}")
            print(f"Corrected string: {corrected_value_str}")

    with open("delegators.txt", "w") as f:
        for delegator in filtered_delegators:
            f.write(delegator + "\n")

    print("Filtered Delegators have been written to delegators.txt")
else:
    error_message = response.text
    print(f"Failed to fetch data. Status code: {response.status_code}. Error message: {error_message}")
