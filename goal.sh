#!/usr/bin/env sh

rm -f /tmp/goal.json

./garminexport/cli/goal.py \
    --log-level DEBUG \
    --jwt_fgp 49738b9e-cb6a-4e51-b3c0-cc7a355d9b7e \
    --token eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRpLW9hdXRoLXNpZ25lci1wcm9kLTIwMjQtcTEifQ.eyJzY29wZSI6WyJDT01NVU5JVFlfQ09VUlNFX1JFQUQiLCJHT0xGX0FQSV9SRUFEIiwiR0hTX0hJRCIsIkFUUF9SRUFEIiwiR0hTX1NBTUQiLCJJTlNJR0hUU19SRUFEIiwiRElWRV9BUElfUkVBRCIsIkRJVkVfQVBJX0lNQUdFX1BSRVZJRVciLCJDT01NVU5JVFlfQ09VUlNFX1dSSVRFIiwiQ09OTkVDVF9XUklURSIsIkRJVkVfU0hBUkVEX1JFQUQiLCJHSFNfUkVHSVNUUkFUSU9OIiwiRFRfQ0xJRU5UX0FOQUxZVElDU19XUklURSIsIkdPTEZfQVBJX1dSSVRFIiwiSU5TSUdIVFNfV1JJVEUiLCJQUk9EVUNUX1NFQVJDSF9SRUFEIiwiR09MRl9TSEFSRURfUkVBRCIsIk9NVF9DQU1QQUlHTl9SRUFEIiwiQ09OTkVDVF9OT05fU09DSUFMX1NIQVJFRF9SRUFEIiwiQ09OTkVDVF9SRUFEIiwiQVRQX1dSSVRFIl0sImlzcyI6Imh0dHBzOi8vZGlhdXRoLmdhcm1pbi5jb20iLCJtZmEiOnRydWUsInJldm9jYXRpb25fZWxpZ2liaWxpdHkiOlsiR0xPQkFMX1NJR05PVVQiXSwiY2xpZW50X3R5cGUiOiJVTkRFRklORUQiLCJleHAiOjE3MjE1NzY2NjQsImlhdCI6MTcyMTU3MzA2NCwiZ2FybWluX2d1aWQiOiJmODE5MDMzMC1mZWM2LTRkYjItOTEyNy1iYmRmNDcxYWM3ZjkiLCJqdGkiOiJkYjVlZjNmOC05MGQwLTQyOTItODBiMS1iNzNkZjI0NmVmYjgiLCJjbGllbnRfaWQiOiJDT05ORUNUX1dFQiIsImZncCI6IjNiNjRmY2Y1MGZjZDRhMzc4NjA4ODYyMmE1MDU3YzRjNWY3MzVjM2RlMzFlYzVlYzhjZWZhNjYwMDg2NTgyM2YifQ.FoI2cVzyRX42nKD3NhlB8uAgivyGeRtb2iMmaP-QJI1OcxUekLrBX2cOAMWBug4uFTmwVz0B_D_O9P6W7QkvluMHTu1gv823c5IEdq93dydyjTI_auXis2tzwQgn47ijpV_eNQ_670I2tPyCG0dLiyzh7Jn7Gov6LE1O6Zd-cIZaUUTYJ1WnhHvoRSCFzS4kaOhH5JbYD1758KMIMumC6c_nUR65RfPbZXKWr7s9D1faYOzU35Lgy4BqK8CNjSCILYbUsUmvwUD8zp5Wvt7HyRvMX9TkjGdwf2n_lWq4amHQ79QSS1K4KRPdKg9QDoTAPV372ssKHVIv7Ph0SXp3uA \
    jakub@tymejczyk.pl

steps=$(jq '.data.userDailySummaryV2Scalar.data[0].movement.steps | .value,.goal' /tmp/goal.json | tr '\n' '/' | sed '$s/\/$/\n/' | bc -l)
floors=$(jq '.data.userDailySummaryV2Scalar.data[0].movement.floorsAscended | .value,.goal' /tmp/goal.json | tr '\n' '/' | sed '$s/\/$/\n/' | bc -l)

steps=$(echo "$steps >= 1" | bc -l)
floors=$(echo "$floors >= 1" | bc -l)

rc=1
if [ $steps -eq 1 -a $floors -eq 1 ]; then
    rc=0
fi

rm -f /tmp/goal.json

exit $rc
