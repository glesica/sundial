# Sundial

https://github.com/glesica/sundial

## Development

I'm still learning OCaml, so I'm just doing what the Internet
told me to do. Critiques welcome. For now, things are pretty
simple.

1. Install [OCaml >=4.03](https://ocaml.org/docs/install.html)
2. Install [OPAM](https://opam.ocaml.org/doc/Install.html)
3. `./scripts/init.sh` to install dependencies
4. `make` to build the program
5. `./Main.native` to run the program

## Schedule a task

See the file `testtab.json` for an example.

For now, the JSON version of a task looks like the following:

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

Right now, tasks are contained inside a JSON object under the
"tasks" key, like so:

```json
{
  "tasks": [
    ...
  ]
}
```

**Note:** I haven't fully implemented the format below yet. Take
a look at `testtab.json` for an example of how it works right now.

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

## Output

Task output goes into the files `stdout.log` and `stderr.log` for
now. Eventually I'll come up with something better. Tasks run in
parallel, so output may be interleaved.

Useful messages are printed to the standard out and standard error
of the main process.
