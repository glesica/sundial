open Filename
open Sys
open Unix

exception Tab_missing

let tab_filename = "sundial.json"

let get_home_dir () =
  let pw = getpwnam (getlogin ()) in
  pw.pw_dir

let get_tab_path base_dir =
  concat base_dir tab_filename

let get_local_tab_path () =
  get_tab_path ""

let get_home_tab_path () =
  get_tab_path (get_home_dir ())

let get_sys_tab_path () =
  get_tab_path "/etc/"

let get_first_tab_path () =
  let local_path = get_local_tab_path () in
  let home_path = get_home_tab_path () in
  let sys_path = get_sys_tab_path () in
  if file_exists local_path then local_path
  else if file_exists home_path then home_path
  else if file_exists sys_path then sys_path
  else raise Not_found
