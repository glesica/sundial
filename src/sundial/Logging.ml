open Printf
open Unix

let logerr msg =
  let ts = localtime (time ()) in
  fprintf Pervasives.stderr "[%d-%d-%d %d:%d:%d] %s\n"
    (ts.tm_year + 1900) (ts.tm_mon + 1) ts.tm_mday
    ts.tm_hour ts.tm_min ts.tm_sec
    msg;
  flush Pervasives.stderr
