# The `..` operator recursively descends into the JSON structure.
# If in slurp mode, start from the first element.
(if type == "array" and length > 0 then .[0] else . end) |
.. | scalars