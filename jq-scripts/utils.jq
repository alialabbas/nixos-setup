
#
# Reusable jq helper functions.
#

# Converts a path array (e.g., ["a", "b", 0]) to a dot-notation string (e.g., "a.b[0]").
def format_path:
  reduce .[] as $item ("";
    if $item | type == "number" then
      . + "[" + ($item|tostring) + "]"
    else
      if . == "" then $item else . + "." + $item end
    end
  );

# Flattens a single JSON object.
def flatten:
  [paths(scalars) as $path | {key: ($path | format_path), value: getpath($path)}] | from_entries;

# Checks if an object contains nested structures.
def is_nested:
  if type == "object" then
    ([paths(scalars) | length] | max) > 1
  else
    false
  end;
