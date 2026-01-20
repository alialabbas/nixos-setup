#
# A recursive, deterministic JSON sorting and cleaning engine.
# This version sorts the entire document.
#

# The main recursive sorting function.
def deep_sort:
  # If input is an array, filter it and then sort it.
  if type == "array" then
    # 1. Filter out null and empty object entries.
    map(select(. != null and . != {}))
    # 2. Recursively sort every element remaining in the array.
    | map(deep_sort)
    # 3. Then, sort the array itself.
    | sort_by(if type == "object" then (to_entries | sort_by(.key) | map(.value)) else . end)

  # If input is an object, sort its keys and recurse on its values.
  elif type == "object" then
    to_entries | sort_by(.key) | from_entries | map_values(deep_sort)

  # If input is a primitive, return it unchanged.
  else
    .
  end;

# --- Main Entry Point ---

# Apply the sort to the entire document.

(if type == "array" and length > 0 then .[0] else . end) | deep_sort
