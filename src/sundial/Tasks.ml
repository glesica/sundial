open Printf
open Unix

type kind =
| Log
| Shell

exception Invalid_kind of string

let kind_of_string kind_str =
  match (String.lowercase_ascii kind_str) with
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
  task_kind  : kind;
  task_title : string;
  task_data  : string;
  task_yr    : freq;
  task_mo    : freq;
  task_day   : freq;
  task_hr    : freq;
  task_min   : freq;
}

exception Invalid_task of string

let freq_matches sched actual =
  match sched with
    | All          -> true
    | One sched_val -> sched_val = actual
    | Some sched_vals -> List.mem actual sched_vals

let should_run {tm_year; tm_mon; tm_mday; tm_hour; tm_min}
    {task_yr; task_mo; task_day; task_hr; task_min} =
  let yr_match = freq_matches task_yr (tm_year + 1900) in
  let mo_match = freq_matches task_mo (tm_mon + 1) in
  let day_match = freq_matches task_day tm_mday in
  let hr_match = freq_matches task_hr tm_hour in
  let min_match = freq_matches task_min tm_min in
  yr_match && mo_match && day_match && hr_match && min_match

let run_task {task_kind; task_data} =
  match task_kind with
  | Log ->
    print_endline task_data;
    Logging.logerr (sprintf "Logged (%s)" task_data)
  | Shell ->
    match fork () with
    | 0 ->
      let outlog = openfile "stdout.log"
        [O_WRONLY; O_APPEND; O_CREAT] 0o640 in
      let errlog = openfile "stderr.log"
        [O_WRONLY; O_APPEND; O_CREAT] 0o640 in
      dup2 outlog stdout;
      dup2 errlog stderr;
      execv "/bin/sh" [|"/bin/sh"; "-c"; (Printf.sprintf "%s" task_data)|]
    | pid ->
      Logging.logerr (sprintf "Process %d started (%s)" pid task_data)

let run_task_by_title tasks title =
  let task = match List.filter
    (fun task -> String.equal task.task_title title) tasks with
  | [t] ->
    t
  | t :: _ ->
    (* TODO: More than one with the same title should be an error. *)
    t
  | [] ->
    raise Not_found in
  run_task task

let task_from_json json =
  let open Yojson.Basic.Util in
  {
    task_kind = member "kind" json |> to_string |> kind_of_string;
    task_title = member "title" json |> to_string;
    task_data = member "data" json |> to_string;
    task_yr = member "yr" json |> to_string |> freq_of_string;
    task_mo = member "mo" json |> to_string |> freq_of_string;
    task_day = member "day" json |> to_string |> freq_of_string;
    task_hr = member "hr" json |> to_string |> freq_of_string;
    task_min = member "min" json |> to_string |> freq_of_string;
  }

let read_tab filename =
  let open Yojson.Basic in
  let open Yojson.Basic.Util in
  from_file filename
  |> member "tasks"
  |> to_list
  |> List.map task_from_json
  ;;
