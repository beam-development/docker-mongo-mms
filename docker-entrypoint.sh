#!/bin/bash
set -e

if [ ! "$MMS_API_KEY" ]; then
	{
		echo 'error: MMS_API_KEY was not specified'
		echo 'try something like: docker run -e MMS_API_KEY=... ...'
		echo '(see https://mms.mongodb.com/settings/monitoring-agent for your mmsApiKey)'
		echo
		echo 'Other variables:'
		echo ' - MMS_GROUP_ID='"$MMS_GROUP_ID"
	} >&2
	exit 1
fi

if [ ! "$MMS_GROUP_ID" ]; then
	{
		echo 'error: MMS_GROUP_ID was not specified'
		echo 'try something like: docker run -e MMS_GROUP_ID=... ...'
		echo '(see https://mms.mongodb.com/settings/monitoring-agent for your mmsApiKey)'
		echo
		echo 'Other variables:'
		echo ' - MMS_API_KEY='"$MMS_API_KEY"
	} >&2
	exit 1
fi

# "sed -i" can't operate on the file directly, and it tries to make a copy in the same directory, which our user can't do
config_tmp="$(mktemp)"
cat /etc/mongodb-mms/automation-agent.config > "$config_tmp"

set_config() {
	key="$1"
	value="$2"
	sed_escaped_value="$(echo "$value" | sed 's/[\/&]/\\&/g')"
	sed -ri "s/^($key)[ ]*=.*$/\1 = $sed_escaped_value/" "$config_tmp"
}

set_config mmsApiKey "$MMS_API_KEY"
set_config mmsGroupId "$MMS_GROUP_ID"

cat "$config_tmp" > /etc/mongodb-mms/automation-agent.config
rm "$config_tmp"

trap "echo TRAPed signal" HUP INT QUIT TERM

exec "$@"

echo "[hit enter key to exit] or run 'docker stop <container>'"
read

echo "exited $0"