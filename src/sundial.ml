open Unix

type task =
  | Shell_task of string
  | Log_task of string

exception Invalid_task of string

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
  | Shell_task cmd ->
    log_result (system cmd)
  | Log_task msg ->
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
      Shell_task taskstr
    | "log" ->
      Log_task taskstr
    | invalid ->
      raise (Invalid_task invalid))
  ;;
