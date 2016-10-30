open Unix

type kind =
  | Log
  | Shell

exception Invalid_kind of string

let kind_of_string kind_str =
  match (String.lowercase kind_str) with
    | "log" -> Log
    | "shell" -> Shell
    | _ -> raise (Invalid_kind kind_str)

type freq =
  | All
  | One  of int
  | Some of int list

exception Invalid_freq of string

let freq_of_string freq_str =
  match freq_str with
    | "*" -> All
    | _ -> One (int_of_string freq_str)

type task = {
  kind  : kind;
  title : string;
  data  : string;
  yr    : freq;
  mo    : freq;
  day   : freq;
  hr    : freq;
  min   : freq;
}

exception Invalid_task of string

let freq_matches sched actual =
  match sched with
    | All          -> true
    | One sched_val -> sched_val = actual
    | Some sched_vals -> List.mem actual sched_vals

let should_run {tm_year; tm_mon; tm_mday; tm_hour; tm_min} {yr; mo; day; hr; min} =
  let yr_match = freq_matches yr tm_year in
  let mo_match = freq_matches mo tm_mon in
  let day_match = freq_matches day tm_mday in
  let hr_match = freq_matches hr tm_hour in
  let min_match = freq_matches min tm_min in
  yr_match && mo_match && day_match && hr_match && min_match

let run_task {kind; data} =
  match kind with
    | Log ->
      print_endline data;
    | Shell ->
      let pid = Unix.fork () in
      if pid = 0 then
        let shell = "/bin/sh" in
        let args = [|"-c"; (Printf.sprintf "'%s'" data)|] in
        Unix.execv shell args
      else
        ()

let task_from_json json =
  let open Yojson.Basic.Util in
  {
    kind = member "kind" json |> to_string |> kind_of_string;
    title = member "title" json |> to_string;
    data = member "data" json |> to_string;
    yr = member "yr" json |> to_string |> freq_of_string;
    mo = member "mo" json |> to_string |> freq_of_string;
    day = member "day" json |> to_string |> freq_of_string;
    hr = member "hr" json |> to_string |> freq_of_string;
    min = member "min" json |> to_string |> freq_of_string;
  }

let read_tab filename =
  let open Yojson.Basic in
  let open Yojson.Basic.Util in
  from_file filename
  |> member "tasks"
  |> to_list
  |> List.map task_from_json
  ;;
