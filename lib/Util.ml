(*********************************************)
(*     Useful functions and data types       *)
(*********************************************)

let is_min (ls : 'a list) (min : 'a) : bool = List.for_all (fun e -> min <= e) ls

(* Measuring execution time *)
let time (f : 'a -> 'b) (x : 'a) : 'b =
  let t = Sys.time () in
  let fx = f x in
  Printf.printf "Execution elapsed time: %f sec\n" (Sys.time () -. t);
  fx
