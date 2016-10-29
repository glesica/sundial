# Sundial

## Schedule a task

The JSON version of a task looks like the following:

```json
{
  "kind": "shell",
  "title": "directory listing",
  "data": "ls -la",
  "yr": "*",
  "mo": "*",
  "day": "*",
  "hr": "*",
  "min": "30"
}
```

The task above will do a directory listing on the current working
directory every hour at half past the hour.

The format for a schedule is `YYYY-MM-DD HH:MM`. Any of the fields
may be replaced with a wildcard `*` to indicate that all values of
the field should always be considered a match for the current
time. For example, to run a task every day at 4AM you would specify
`*-*-* 04:00`. This task would run every (or any, depending on how
you think about it) year, every month, every day, at 4AM.

It is also possible to specify a list of values that should match
for a specific field. For example, to run a task every day at 4AM
and also at 4PM you would specify `*-*-* 04,16:00`.

The leading zeros in both of the above schedule strings are
optional.
