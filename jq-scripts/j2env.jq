# to_entries converts an object to an array of {"key":..., "value":...} objects.
# .[] iterates through that array.
# The final string is constructed using interpolation with 'export'.
(if type == "array" and length > 0 then .[0] else . end) |
to_entries[] | "export \(.key)=\"\(.value)\""