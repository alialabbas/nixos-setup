
# This script expects one argument: the key to analyze (passed as $key).

# 1. The input is a single array (from the -s slurp flag).
# 2. Extract the key from the first positional argument.
($ARGS.positional[0] // .[1] // "value") as $key |
# 3. Extract numbers by iterating over the objects and then accessing the key.
[ (.[0][] | .[$key]?) | select(type == "number") ] as $numbers
|
# 3. Construct the final output object with the computed stats.
{
  "count": ($numbers | length),
  "sum": ($numbers | add),
  "min": ($numbers | min),
  "max": ($numbers | max),
  "mean": (if ($numbers | length) == 0 then null else ($numbers | add / length) end)
}
