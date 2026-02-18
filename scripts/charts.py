import os
from copy import deepcopy

import requests
import numpy as np
import matplotlib.pyplot as plt

def aggregations() -> None:
    # Plot and save figures for aggregations types

    records_data = requests.get("https://repository.tugraz.at/api/records").json()
    aggr = records_data["aggregations"]

    figure_titles = []
    types = []
    values = []

    for title in aggr:
        figure_titles.append(title)
        local_types = []
        local_values = []
        for type_obj in aggr[title]["buckets"]:
            local_types.append(type_obj["key"])
            local_values.append(type_obj["doc_count"])
        types.append(deepcopy(local_types))
        values.append(deepcopy(local_values))

        local_types.clear()
        local_values.clear()

    for i in range(len(figure_titles)):
        if figure_titles[i] == "resource_type":
            plt.figure(figsize=(15, 10))
        else:
            plt.figure(figsize=(10, 10))
        plt.bar(types[i], values[i])
        plt.xlabel('Type')
        plt.ylabel('Count')
        plt.title(figure_titles[i])
        plt.savefig(os.path.join(os.getcwd(), figure_titles[i] + ".jpg"))
        plt.close()

def records_info() -> None:
    # Plot and save figure for file sizes histogram and licenses used bar chart

    page_idx = 1
    page_size = 50
    file_sizes = []
    rights = {}
    while True:
        records_data = requests.get(f"https://repository.tugraz.at/api/records?size={page_size}&page={page_idx}").json()
        records = records_data["hits"]["hits"]

        for record in records:
            if record["access"]["record"] == "restricted" or \
                record["access"]["files"] == "restricted":
                continue
            try:
                record_files_obj = record["files"]
                if record_files_obj["enabled"]:
                    file_sizes.append(record_files_obj["total_bytes"] / 10**6)

                record_files_rights = record["metadata"].get("rights")
                if record_files_rights is None and rights.get("None") is None:
                    rights["None"] = 1
                elif record_files_rights is None:
                    rights["None"] += 1
                else:
                    for r in record_files_rights:
                        try:
                            if r["id"] not in rights:
                                rights[r["id"]] = 1
                            else:
                                rights[r["id"]] += 1
                        except KeyError:
                            title = r["title"].get("en") or r["title"].get("de")
                            if title not in rights:
                                rights[title] = 1
                            else:
                                rights[title] += 1

            except Exception as e:
                print(f"Record {record["id"]} with exception: {e}")

        if len(records) < 50:
            break

        page_idx += 1

    bins = np.logspace(
        np.log10(min(file_sizes)),
        np.log10(max(file_sizes)),
        100
    )

    plt.figure(figsize=(10, 10))
    plt.hist(file_sizes, bins=bins, edgecolor="black", linewidth=0.5)
    plt.xscale("log")
    plt.title("File sizes")
    plt.xlabel("File size (MB)")
    plt.ylabel("Record count")
    plt.savefig(os.path.join(os.getcwd(), "file_sizes.jpg"))
    plt.close()

    plt.figure(figsize=(10, 14))
    plt.bar(rights.keys(), rights.values())
    plt.xlabel('License')
    plt.xticks(rotation=45, ha="right")
    plt.ylabel('Count')
    plt.title("Licenses diagram")
    plt.savefig(os.path.join(os.getcwd(), "licenses.jpg"))
    plt.close()


def main():
    aggregations()
    records_info()

if __name__ == "__main__":
    main()
