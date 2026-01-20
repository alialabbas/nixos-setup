# Import the helper functions.
import "utils" as utils;

#
# A semantic JSON diffing engine.
#

def get_keys($val):
  if ($val | type) == "object" then $val | keys_unsorted
  elif ($val | type) == "array" then [range(0; $val|length)]
  else []
  end;

# The main recursive diff function.
def diff_recursive($a; $b; $path; $array_mode; $id_key):
  if $a == $b then empty
  else
    if ([$a, $b] | map(type) | unique | length) > 1 then
      {path: $path, change: "type", old: ($a|type), new: ($b|type)}
    elif ($a|type) == "object" then
      ((get_keys($a) + get_keys($b) | unique) as $keys
       | $keys[] as $key
       | diff_recursive($a[$key]?; $b[$key]?; ($path + [$key]); $array_mode; $id_key))
    elif ($a|type) == "array" then
      if $array_mode == "set" then
        if ($a[0]|type) == "object" and ($b[0]|type) == "object" and $id_key != null and $id_key != "null" then
          ( ($a | map({key: (.[$id_key]? // "null" | tostring), value: .}) | from_entries) as $a_idx
            | ($b | map({key: (.[$id_key]? // "null" | tostring), value: .}) | from_entries) as $b_idx
            | (get_keys($a_idx) + get_keys($b_idx) | unique) as $keys
            | $keys[] as $key
            | diff_recursive($a_idx[$key]?; $b_idx[$key]?; ($path + [$key]); $array_mode; $id_key)
          )
        else
          (({path: $path, removed: (if $a|type=="array" then $a else [] end - if $b|type=="array" then $b else [] end)}) | select(.removed | length > 0)),
          (({path: $path, added: (if $b|type=="array" then $b else [] end - if $a|type=="array" then $a else [] end)}) | select(.added | length > 0))
        end
      else
        ((([$a|length, $b|length] | max) // 0) as $len
         | range(0; $len) as $i
         | diff_recursive($a[$i]?; $b[$i]?; ($path + [$i]); $array_mode; $id_key))
      end
    else
      {path: $path, old: $a, new: $b}
    end
  end;

# --- Main Entry Point ---
if type != "array" or length < 2 then
  "Error: jdiff requires at least two JSON inputs (slurp mode)" | halt_error(1)
else
  ($ARGS.named.array_mode // "positional") as $am |
  ($ARGS.named.id_key // "null") as $id |
  diff_recursive(.[0]; .[1]; []; $am; $id)
  | .path |= utils::format_path
end