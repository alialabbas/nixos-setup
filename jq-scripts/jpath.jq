
# Import the helper functions.
import "utils" as utils;

# The `paths` built-in generates all paths as arrays.
# We pipe each path array to our formatter function.
(if type == "array" and length > 0 then .[0] else . end) | paths | utils::format_path
