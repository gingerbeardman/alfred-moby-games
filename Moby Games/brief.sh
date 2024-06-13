#!/usr/bin/env zsh

api_key="${api_key}"

if [[ $api_key ]]
then

	url="https://api.mobygames.com/v1/games"

	json=`curl --get --data-urlencode "format=brief" --data-urlencode "limit=9" --data-urlencode "title=$1" --data-urlencode "api_key=$api_key" $url`

	json=${json:gs/\"games\"\:/\"items\"\:}
	json=${json:gs/"game_id"/"uid"}
	json=${json:gs/"moby_url"/"url"}

	json=`echo -E $json | jq '.items[] |= (. + {subtitle: .url})'`
	json=`echo -E $json | jq '.items[] |= (. + {arg: .url})'`
	
	echo -n $json

fi
