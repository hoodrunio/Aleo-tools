#!/bin/bash

# File with list of delegators one per line
delegators_file="delegators.txt"
# Transaction information will be saved to this JSON file
output_file="transaction_history.json"
# Failed transactions will be saved to this file
failed_output_file="failed_transactions.json"

if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
    echo "[]" > "$output_file"
fi

if [ ! -f "$failed_output_file" ] || [ ! -s "$failed_output_file" ]; then
    echo "[]" > "$failed_output_file"
fi

echo -e "Private key: "
read PRIVKEY

echo "Starting unbound all deleagtors..."

while IFS= read -r ADDRESS; do
    # Execute the command for each address and capture the output
    output=$(snarkos developer execute credits.aleo unbond_delegator_as_validator $ADDRESS --private-key $PRIVKEY --query "https://api.explorer.aleo.org/v1" --broadcast "https://api.explorer.aleo.org/v1/testnet3/transaction/broadcast")

    if echo "$output" | grep -q " has been broadcast to"; then
        TXHASH=$(echo "$output" | tail -n1)

        jq --arg address "$ADDRESS" --arg txhash "$TXHASH" '. += [{"address":$address, "txhash":$txhash}]' "$output_file" > temp.json && mv temp.json "$output_file"

        echo -e "Transaction successfully recorded: Address: \033[32m$ADDRESS\033[0m, TXHASH: \033[32m$TXHASH\033[0m"
        echo -e "\033[36mDetails saved to $output_file\033[0m"
    else
        jq --arg address "$ADDRESS" --arg output "$output" '. += [{"address":$address, "output":$output}]' "$failed_output_file" > temp_failed.json && mv temp_failed.json "$failed_output_file"

        echo -e "\033[31mTransaction failed for address $ADDRESS. Output:\033[0m"
        echo "$output"
        echo -e "\033[31mDetails saved to $failed_output_file\033[0m"
    fi
done < $delegators_file

echo "Script exited successfully."
