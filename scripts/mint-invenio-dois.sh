#!/bin/bash
# InvenioRDM: Create or update DOIs for a record and its parent
# https://support.datacite.org/docs/api-create-dois

if [[ -z "${DATACITE_BASIC_CREDS}" ]]; then
    echo "please export DATACITE_BASIC_CREDS in the shape <user>:<password>"
    exit 1
fi

doi_prefix="10.3217"
hostname="repository.tugraz.at"
datacite_hostname="api.datacite.org"
while getopts "d:h:p:" opt; do
    case "$opt" in
        d)
            datacite_hostname="${OPTARG}"
            if [[ "${datacite_hostname}" != "api.test.datacite.org" && "${datacite_hostname}" != "api.datacite.org" ]]; then
                echo >&2 "DATACITE_HOSTNAME must be either 'api.test.datacite.org' or 'api.datacite.org'"
                exit 1
            fi
            ;;
        h)
            hostname="${OPTARG}"
            ;;
        p)
            doi_prefix="${OPTARG}"
            ;;
        *)
            echo >&2 "usage: ${0} [-h HOSTNAME] [-p PREFIX] [-d DATACITE_HOSTNAME] RECID"
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

recid="${1}"
if [[ -z "${recid}" ]]; then
    echo >&2 "error: no recid supplied"
    exit 1
fi

echo "minting DOI: datacite_hostname=${datacite_hostname} hostname=${hostname} doi_prefix=${doi_prefix} recid=${recid}"

# get the general metadata, with parent record information
record_json="$(curl -s "https://${hostname}/api/records/${recid}")"
record_url="$(echo "${record_json}" | jq -r '.links.self_doi_html')"
parent_url="$(echo "${record_json}" | jq -r '.links.parent_doi_html')"
parent_recid="$(echo "${record_json}" | jq -r '.parent.id')"

# get the DC-formatted metadata
record_dc_json="$(curl -s "https://${hostname}/api/records/${recid}" -H "Accept: application/vnd.datacite.datacite+json")"
parent_dc_json="$(curl -s "https://${hostname}/api/records/${recid}/versions/latest" -LH "Accept: application/vnd.datacite.datacite+json")"

# use `jq` to massage the raw JSON-DC MD into the actually expected shape
# (note that with the "doi" key we specify the DOI we want to mint/update)
record_dc_json_payload="$(
  echo "${record_dc_json}" | jq \
    --arg doi "${doi_prefix}/${recid}" \
    --arg url "${record_url}" \
    '{
      "data": {
        "type": "dois",
        "attributes": (. + {
          "event": "publish",
          "doi": $doi,
          "url": $url
        })
      }
    }'
)"

parent_dc_json_payload="$(
  echo "${parent_dc_json}" | jq \
    --arg doi "${doi_prefix}/${parent_recid}" \
    --arg url "${parent_url}" \
    '{
      "data": {
        "type": "dois",
        "attributes": (. + {
          "event": "publish",
          "doi": $doi,
          "url": $url
        })
      }
    }'
)"

# actually mint/update the DOIs
curl -X PUT -H "Content-Type: application/vnd.api+json" --user "${DATACITE_BASIC_CREDS}" -d "${record_dc_json_payload}" "https://${datacite_hostname}/dois/${doi_prefix}/${recid}"
curl -X PUT -H "Content-Type: application/vnd.api+json" --user "${DATACITE_BASIC_CREDS}" -d "${parent_dc_json_payload}" "https://${datacite_hostname}/dois/${doi_prefix}/${parent_recid}"
