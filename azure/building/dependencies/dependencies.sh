#!/usr/bin/env bash

# bash shell script to check for dependencies in a set of repos
#
# By Ed ODonnell
# Ver : 2026-01-19
#
# This script finds packages.config files and reads them.  It extracts the dependency library files and makes a CSV out of them.
#
#
#

ROOT_DIR="."
OUTPUT_CSV="packages-report.csv"

# CSV header
echo "FileName,Id,Version,TargetFramework,DevelopmentDependency" > "$OUTPUT_CSV"

# Find all config files
find "$ROOT_DIR" -type f -name "packages.config" | while read -r file; do

    # Count packages in file
    pkg_count=$(xmllint --xpath "count(/packages/package)" "$file" 2>/dev/null)

    # Skip files that are not valid XML
    if [[ -z "$pkg_count" || "$pkg_count" == "0" ]]; then
        continue
    fi

    for ((i=1; i<=pkg_count; i++)); do
        id=$(xmllint --xpath "string(/packages/package[$i]/@id)" "$file")
        version=$(xmllint --xpath "string(/packages/package[$i]/@version)" "$file")
        framework=$(xmllint --xpath "string(/packages/package[$i]/@targetFramework)" "$file")
        devdep=$(xmllint --xpath "string(/packages/package[$i]/@developmentDependency)" "$file")

        # Escape quotes for CSV safety
        printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n" \
            "$file" "$id" "$version" "$framework" "$devdep" \
            >> "$OUTPUT_CSV"
    done
done

echo "CSV created: $OUTPUT_CSV"

