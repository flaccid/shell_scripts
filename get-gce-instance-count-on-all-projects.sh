#!/bin/bash -e

projects="$(gcloud projects list --format=json)"
running_count=0

for row in $(echo "${projects}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  echo "$(_jq '.name') ($(_jq '.projectId')/$(_jq '.projectNumber'))"

  instances=$(gcloud compute instances list --filter status=running --format=json --project "$(_jq '.projectId')")
  count="$(echo $instances | jq length)"
  if [ $count -gt 0 ]; then
    gcloud compute instances list --filter status=running --project "$(_jq '.projectId')"
  fi
  echo "    > total: $count"
  echo ''

  running_count=$((running_count + $count))
done

echo ">> total running: $running_count"
