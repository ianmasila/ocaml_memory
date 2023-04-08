open Allocator
open ArrayUtil

(**********************************************)
(*   A concrete implementation of allocator   *)
(**********************************************)

module AllocatorImpl : Allocator = struct
  type ptr = int (* position *) * int (* allocated length *) (* length is just a check *)

  type elem =
    | Ptr of ptr
    | Int of int
    | Str of string
    | Allocated
    | Free

  type heap = elem array

  let make_heap sz = Array.make sz Free

  let null _ = (-1, 0)

  let is_null h p = p = (null h)

  let alloc h size =  
    (* Find "size" contiguous Free slots in heap *)
    let len = Array.length h in
    let free_indices_array = Array.make len (-1) in
    for i = 0 to len - 1 do
      if h.(i) = Free 
      then free_indices_array.(i) <- i;
      (* Printf.printf "free_indices_array.(%d) = %d\n" i free_indices_array.(i); *)
    done;
    let free_indices_list = array_to_list free_indices_array in

    let rec find_contiguous_segment acc lst =
      if List.length acc = size 
      then 
        let finish = List.hd acc in
        let start = finish - size + 1 in
        (* let start = List.hd (List.rev acc) in *)
        start, finish, true
      else
        match lst with
        | [] -> -1, -1, false
        | [x] -> 
          let acc' = if x = -1 then acc else x :: acc in
          find_contiguous_segment acc' [] 
        | x :: (y :: _ as t) ->
          find_contiguous_segment (if y - x = 1 || (y = -1 && x <> -1) then x :: acc else []) t
    in let start, _, success = find_contiguous_segment [] free_indices_list in
    if success 
    then (
      let result = start, size in
      (* Mark contiguous Free slots as "Allocated" *)
      Array.fill h start size Allocated;
      (* Printf.printf "Allocation successful.\n"; *)
      (* Return pointer *)
      result
    )
    else (
      failwith "Out-of-Memory"
    )

  let free h p size =
    let lo = fst p in
    let p_size = snd p in
    if size > p_size then failwith "freed with the wrong size" 
    else (
      (* Printf.printf "Freeing size: %d lo: %d\n" size lo; *)
      Array.fill h lo size Free;
      (* Printf.printf "Freeing successful.\n"; *)
    )

  let deref_as_ptr h p o = 
    if o > (snd p) then failwith "attempt to dereference beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      let target = h.(target_index) in
      match target with
      | Ptr v -> (
        (* Printf.printf "Pointer %d, %d\n" start length;   *)
        v
      )
      | _ -> failwith "dereferenced non-pointer as a pointer"
    )

  let deref_as_int h p o =
    if o >= (snd p) then failwith "attempt to dereference beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      let target = h.(target_index) in
      match target with
      | Int i -> (
        (* Printf.printf "Integer %d\n" i;  *)
        i
      )
      | _ -> failwith "dereferenced non-integer as an integer"
    )

  let deref_as_string h p o = 
    if o >= (snd p) then failwith "attempt to dereference beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      let target = h.(target_index) in
      match target with
      | Str s -> (
        (* Printf.printf "String %s\n" s; *)
        s
      )
      | _ -> failwith "dereferenced non-string as a string"
    )

  let assign_ptr h p o v =
    if o >= (snd p) then failwith "attempt to assign beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      if h.(target_index) = Free then failwith "attempt to assign to free memory"
      else (
      h.(target_index) <- Ptr(v)
      )
    )

  let assign_int h p o v = 
    if o >= (snd p) then failwith "attempt to assign beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      if h.(target_index) = Free then failwith "attempt to assign to free memory"
      else (
      h.(target_index) <- Int(v)
      )
    )

  let assign_string h p o v =
    if o >= (snd p) then failwith "attempt to assign beyond end of allocation"
    else (
      let target_index = (fst p) + o in
      if h.(target_index) = Free then failwith "attempt to assign to free memory"
      else (
      h.(target_index) <- Str(v)
      )
    )

end
