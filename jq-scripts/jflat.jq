
# Import the helper functions.
import "utils" as utils;

# The main filter is just a call to the flatten function.
(if type == "array" and length > 0 then .[0] else . end) | utils::flatten
