#!/bin/sh

generate_mappings_source() {
	local site=$1
  	local old_homepage=$2
  	local new_homepage=$3
	local path="$(pwd)/data/mappings"
	mkdir -p $path
	cat > "${path}/${site}.csv" <<EOF
Old Url,Status,New Url,Archive Link
$old_homepage,301,https://www.gov.uk/$new_homepage,
EOF

}