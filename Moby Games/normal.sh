#!/usr/bin/env zsh

api_key="${moby_games_api_key}"

if [[ $api_key ]]
then

	url="https://api.mobygames.com/v1/games"

	json=`curl --get --data-urlencode "format=normal" --data-urlencode "limit=9" --data-urlencode "title=$1" --data-urlencode "api_key=$api_key" $url`

	json=${json:gs/\"games\"\:/\"items\"\:}
	json=${json:gs/"game_id"/"uid"}
	json=${json:gs/"moby_url"/"url"}

	# remove description to speed things up
	json=`echo -E $json | jq '.items |= map(del(.description))'`

	# add arg which is the URL we will pass to Open URL
	json=`echo -E $json | jq '.items[] |= (. + {arg: .url})'`

 	# add platforms and release years as subtitle
	json=`echo -E $json | jq '.items |= map(. + {subtitle: (.platforms | map("\(.platform_name) (\(.first_release_date[0:4]))") | join(", "))})'`

	# cmd for Moby Games URL, cmd+shift for Official URL
	json=`echo -E $json | jq '.items |= map(if .official_url then
								. + {mods: {
									cmd: {valid: true, arg: .url, subtitle: .url},
									"shift+cmd": {valid: true, arg: .official_url, subtitle: .official_url}
								}}
							else
								. + {mods: {
									cmd: {valid: true, arg: .url, subtitle: .url}
								}}
							end)'`

	echo -n $json

fi
