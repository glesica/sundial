open Filename
open Sys
open Unix

exception Tab_missing

let tab_filename = "sundial.json"

let get_home_dir () =
  let pw = getpwuid (getuid ()) in
  pw.pw_dir

let get_tab_path ?(filename=tab_filename) base_dir =
  concat base_dir filename

let get_local_tab_path () =
  get_tab_path ""

let get_home_tab_path is_hidden =
  let filename = if is_hidden then
    Printf.sprintf ".%s" tab_filename
  else
    tab_filename in
  get_tab_path ~filename:filename (get_home_dir ())

let get_sys_tab_path () =
  get_tab_path "/etc/"

let get_first_tab_path override =
  let local_path = get_local_tab_path () in
  let hidden_home_path = get_home_tab_path true in
  let home_path = get_home_tab_path false in
  let sys_path = get_sys_tab_path () in
  if override <> "" then
    if file_exists override then
      override
    else
      raise Not_found
  else if file_exists local_path then local_path
  else if file_exists hidden_home_path then hidden_home_path
  else if file_exists home_path then home_path
  else if file_exists sys_path then sys_path
  else raise Not_found
