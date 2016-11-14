open Arg
open Printf
open Sys
open Unix

let arg_tab_path = ref ""
let arg_run_title = ref ""

let next_wake base_epoch =
  let base_time = localtime base_epoch in
  let offset = float_of_int (90 - base_time.tm_sec) in
  base_epoch +. offset

let rec process_loop wake_epoch tab =
  let start_epoch = time () in
  if wake_epoch -. start_epoch < 1.0 then
    let start_time = localtime start_epoch in
    tab
    |> List.filter (Tasks.should_run start_time)
    |> List.iter Tasks.run_task;
    process_loop (next_wake start_epoch) tab
  else
    sleep (int_of_float (wake_epoch -. start_epoch));
    process_loop wake_epoch tab

let clean_up _ =
  try let (pid, status) = (waitpid [WNOHANG] (-1)) in
    match status with
    | WEXITED code ->
      Logging.logerr (sprintf "Process %d exited (status %d)" pid code)
    | WSIGNALED signal ->
      Logging.logerr (sprintf "Process %d killed (signal %d)" pid signal)
    | WSTOPPED signal ->
      Logging.logerr (sprintf "Process %d stopped (signal %d)" pid signal)
  with Unix_error (ECHILD, _, _) -> ()

let shut_down status _ =
  exit status

let load_tab () =
  let tab_path = try Tabs.get_first_tab_path !arg_tab_path with
  | Not_found ->
    Logging.logerr "No config file found";
    exit 1 in
  Tasks.read_tab tab_path

let run_task_by_title title =
  let tasks = load_tab () in
  Tasks.run_task_by_title tasks title

let start_up () =
  set_signal sigchld (Signal_handle clean_up);
  set_signal sigint (Signal_handle (shut_down 0));
  let tasks = load_tab () in
  process_loop (next_wake (time ())) tasks

let main =
  parse [
      ("--tab", Set_string arg_tab_path, "Path to the config file.");
      ("--run", Set_string arg_run_title, "Run a single task and exit.");
    ]
    (fun anon -> ())
    "Sundial: sort of like cron?";
  if !arg_run_title <> "" then
    run_task_by_title !arg_run_title
  else
    start_up ()
