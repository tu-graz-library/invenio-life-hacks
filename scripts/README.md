# Useful scripts for an invenioRDM instance

## charts.py
Displays various statistics charts from TU Graz repository.

### Prerequisites

* `matplotlib`
* `numpy`

### Example usage
`python charts.py`

## mint-invenio-dois.sh

**Note:** script taken from TU Wien: https://gitlab.tuwien.ac.at/crdm/invenio-utilities/-/tree/master/dois?ref_type=heads

Simple shell script for minting DOIs for an InvenioRDM record and its parent.

### Prerequisites

* `curl`
* `jq`


### Example usage

```bash
DATACITE_BASIC_CREDS="tudata:iloveinvenio" ./mint-invenio-dois.sh -h repository.tugraz.at -p 10.3217 -d api.datacite.org 9j8ad-z2q11
```


