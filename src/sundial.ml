open Unix

type task =
  | ShellTask of string
  | LogTask of string

exception InvalidTask of string

let log_exit code =
  print_string "process exited with return code ";
  print_int code;
  print_string "\n"
  ;;

let log_signal num =
  print_string "process received signal ";
  print_int num;
  print_string "\n"
  ;;

let log_result result =
  match result with
  | WEXITED code ->
    log_exit code
  | WSIGNALED num ->
    log_signal num
  | WSTOPPED num ->
    log_signal num
  ;;

let run_task task =
  match task with
  | ShellTask cmd ->
    log_result (system cmd)
  | LogTask msg ->
    print_string msg
  ;;

let read_tab filename =
  let open Yojson.Basic in
  let open Yojson.Basic.Util in
  from_file filename
    |> member "tasks"
    |> to_list
    |> List.map (fun json -> (member "type" json |> to_string,
                              member "content" json |> to_string))
    |> List.map (fun (tasktype, taskstr) -> match tasktype with
      | "shell" ->
        ShellTask taskstr
      | "log" ->
        LogTask taskstr
      | invalid ->
        raise (InvalidTask invalid))
  ;;

    
