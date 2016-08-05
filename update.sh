#!/bin/bash
set -e

current="$(HEAD -E 'https://cloud.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.ubuntu1604.deb' | grep '^Location:' | tail -n1 | cut -d_ -f2)"

set -x
sed -ri 's/^(ENV MMS_VERSION) .*/\1 '"$current"'/' Dockerfile
