open Allocator

(**********************************************)
(*   A mock implementation of allocator       *)
(**********************************************)

module AllocatorImpl : Allocator = struct
  type elem =
    | Ptr of ptr
    | Int of int
    | Str of string
    | Allocated
    | Free

  and ptr =
    | Null
    | NotNull of elem array

  type heap = int ref (* This int records how much space is left in the heap *)

  let make_heap sz = ref sz

  let null _h = Null

  let is_null _h p = p == Null

  let get_array p action =
    match p with
    | Null -> failwith (action ^ " a null pointer")
    | NotNull a ->
      if Array.exists (fun x -> x == Free) a
      then failwith (action ^ " a pointer that was already freed");
      a

  let alloc h size =
    if !h < size
    then failwith "allocated when the heap is full"
    else (
      h := !h - size;
      NotNull (Array.make size Allocated))

  let free h p size =
    let a = get_array p "freed" in
    if size != Array.length a then failwith "freed with the wrong size";
    h := !h + size;
    Array.fill a 0 (Array.length a) Free

  let deref_as (p : ptr) (o : int) : elem =
    let a = get_array p "dereferenced" in
    if o < Array.length a
    then a.(o)
    else failwith "attempt to dereference beyond end of allocation"

  let deref_as_ptr _h p o =
    let elem = deref_as p o in
    match elem with
    | Ptr p -> p
    | _ -> failwith "dereferenced non-pointer as a pointer"

  let deref_as_int _h p o =
    let elem = deref_as p o in
    match elem with
    | Int i -> i
    | _ -> failwith "dereferenced non-pointer as a pointer"

  let deref_as_string _h p o =
    let elem = deref_as p o in
    match elem with
    | Str s -> s
    | _ -> failwith "dereferenced non-pointer as a pointer"

  let assign p o v =
    let a = get_array p "assigned to" in
    if o < Array.length a
    then a.(o) <- v
    else failwith "assigned beyond end of an allocation"

  let assign_ptr _h p o v = assign p o (Ptr v)

  let assign_int _h p o v = assign p o (Int v)

  let assign_string _h p o v = assign p o (Str v)
end
