# If the input is an array (slurp mode), take the first element.
(if type == "array" and length > 0 then .[0] else . end) |
# If that element is also an array, iterate through it.
(if type == "array" then .[] else . end) |
select(type == "object") |
keys_unsorted[]