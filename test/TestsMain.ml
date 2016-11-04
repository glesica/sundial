open OUnit2
open Tasks
open Unix

let test_kind_of_string ctx =
  assert_equal ~msg:"log -> Log" (kind_of_string "log") Log;
  assert_equal ~msg:"LOG -> Log" (kind_of_string "LOG") Log;
  assert_equal ~msg:"lOg -> Log" (kind_of_string "lOg") Log;
  assert_equal ~msg:"shell -> Shell" (kind_of_string "shell") Shell;
  assert_raises ~msg:"invalid kind"
    (Invalid_kind ".invalid.")
    (fun () -> kind_of_string ".invalid.")

let test_freq_of_string ctx =
  assert_equal ~msg:"* -> All" (freq_of_string "*") All;
  assert_equal ~msg:"0 -> One 0" (freq_of_string "0") (One 0);
  assert_equal ~msg:"30 -> One 30" (freq_of_string "30") (One 30)

let test_freq_matches_all ctx =
  assert_equal ~msg:"All 0" (freq_matches All 0) true;
  assert_equal ~msg:"All 30" (freq_matches All 30) true

let test_freq_matches_one ctx =
  assert_equal ~msg:"One 0 0" (freq_matches (One 0) 0) true;
  assert_equal ~msg:"One 30 30" (freq_matches (One 30) 30) true;
  assert_equal ~msg:"One 0 30" (freq_matches (One 0) 30) false;
  assert_equal ~msg:"One 30 0" (freq_matches (One 30) 0) false

let test_freq_matches_some ctx =
  assert_equal ~msg:"Some [0; 30] 0" (freq_matches (Some [0; 30]) 0) true;
  assert_equal ~msg:"Some [0] 0" (freq_matches (Some [0]) 0) true;
  assert_equal ~msg:"Some [30] 30" (freq_matches (Some [30]) 30) true;
  assert_equal ~msg:"Some [30] 0" (freq_matches (Some [30]) 0) false;
  assert_equal ~msg:"Some [0] 30" (freq_matches (Some [0]) 30) false;
  assert_equal ~msg:"Some [0; 30] 15" (freq_matches (Some [0; 30]) 15) false

let test_should_run ctx =
  let ts = {
    tm_year = 100;
    tm_mon = 0;
    tm_mday = 1;
    tm_wday = 0;
    tm_yday = 0;
    tm_hour = 0;
    tm_min = 0;
    tm_sec = 0;
    tm_isdst = true;
  } in
  let tts yr mo day hr min = {
    kind = Shell;
    title = "title";
    data = "ls";
    yr = yr;
    mo = mo;
    day = day;
    hr = hr;
    min = min;
  } in
  assert_equal ~msg:"* * * * *"
    (should_run ts (tts All All All All All))
    true;
  assert_equal ~msg:"* * * * 0"
    (should_run ts (tts All All All All (One 0)))
    true;
  assert_equal ~msg:"* * * * 30"
    (should_run ts (tts All All All All (One 30)))
    false;
  assert_equal ~msg:"* * * 0 *"
    (should_run ts (tts All All All (One 0) All))
    true;
  assert_equal ~msg:"* * * 30 *"
    (should_run ts (tts All All All (One 30) All))
    false;
  assert_equal ~msg:"* * 1 * *"
    (should_run ts (tts All All (One 1) All All))
    true;
  assert_equal ~msg:"* * 15 * *"
    (should_run ts (tts All All (One 15) All All))
    false;
  assert_equal ~msg:"* 1 * * *"
    (should_run ts (tts All (One 1) All All All))
    true;
  assert_equal ~msg:"* 12 * * *"
    (should_run ts (tts All (One 12) All All All))
    false;
  assert_equal ~msg:"2000 * * * *"
    (should_run ts (tts (One 2000) All All All All))
    true;
  assert_equal ~msg:"2010 * * * *"
    (should_run ts (tts (One 2010) All All All All))
    false;
  assert_equal ~msg:"2000 1 * * 0"
    (should_run ts (tts (One 2000) (One 1) All All (One 0)))
    true;
  assert_equal ~msg:"2010 1 * * 0"
    (should_run ts (tts (One 2010) (One 1) All All (One 0)))
    false

let freq_matches_tests =
  "Tasks">:::
    [
      "kind_of_string">:: test_kind_of_string;
      "freq_of_string">:: test_freq_of_string;
      "freq_matches -> All">:: test_freq_matches_all;
      "freq_matches -> One">:: test_freq_matches_one;
      "freq_matches -> Some">:: test_freq_matches_some;
      "should_run">:: test_should_run;
    ]

let () =
  run_test_tt_main freq_matches_tests;
