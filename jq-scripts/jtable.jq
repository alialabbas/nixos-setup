
# Import the helper functions from our utils library.
import "utils" as utils;

# ----- Main Logic -----

# 1. Normalize input and handle different JSON structures.
(if (.[0]? | type) == "array" then add else . end) as $raw_data
|
# 2. Conditionally flatten each object.
($raw_data | map(if . | utils::is_nested then . | utils::flatten else . end)) as $data
|
# 3. Gather all keys, preserving the order from the first object.
(
  ($data | map(if type=="object" then keys_unsorted else [] end)) as $key_lists
  | ($key_lists[0]? + ((($key_lists | add | unique) - $key_lists[0]?)))
) as $headers
|
# 4. Output headers and data rows.
$headers,
(
  $data[]
  | select(type == "object")
  | [.[($headers[])]]
  | map(if . == null then "" else . end)
)
|
# 5. Format as Tab-Separated Values.
@tsv
