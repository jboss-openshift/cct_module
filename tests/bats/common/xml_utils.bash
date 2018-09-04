function assert_xml() {
  local file=$1
  local xpath=$2
  local expected=$3
  local xml=$(xmllint --xpath "$xpath" $file)
  diff <(echo $xml | xmllint --format -) <(xmllint --format $expected)
}

function assert_xml_value() {
  local file=$1
  local xpath=$2
  local expected=$3
  local actual=$(xmllint --xpath $xpath $file)
  echo $xpath > /tmp/xml
  [[ $actual =~ $expected ]]
}
