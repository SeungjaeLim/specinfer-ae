#! /usr/bin/env bash
set -e
set -x

# Cd into directory holding this script
cd "${BASH_SOURCE[0]%/*}"

cd FlexFlow
rm -rf inference/prompt || true
mkdir -p inference/prompt
cd inference/prompt
wget https://specinfer.s3.us-east-2.amazonaws.com/prompts/chatgpt.json

python - <<END
import json

# Read the original JSON file
with open('chatgpt.json', 'r') as f:
    original_list = json.load(f)

for i in (1,2,4,8,16):
    new_list = []
    for string in original_list:
        new_list += [string] * i  # Create a list with 3 copies of the string and concatenate it

    # Write the new list to a new JSON file
    with open(f'chatgpt_{i}.json', 'w') as f:
        json.dump(new_list, f)
END

rm chatgpt.json
