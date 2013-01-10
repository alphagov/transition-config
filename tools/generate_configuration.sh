#!/bin/sh

generate_mappings_source() {
	local name=$1
  local old_department_homepage=$2
  local new_department_homepage=$3
	local path="$(pwd)/data/mappings"
	mkdir -p $path
	cat > "${path}/${name}.csv" <<EOF
Old Url,Status,New Url,Archive Link
$old_department_homepage,301,https://www.gov.uk/$new_department_homepage,
EOF

}