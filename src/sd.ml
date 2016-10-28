open Unix

let main =
  Sundial.read_tab "testtab.json"
  |> List.iter Sundial.run_task
  ;;