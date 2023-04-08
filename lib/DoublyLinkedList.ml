
open Allocator

(******************************************************)
(* A doubly linked list parameterised by an allocator *)
(******************************************************)


module DoublyLinkedList (A : Allocator) = struct
  open A

  type dll_node = ptr

  let mk_node (heap : heap) (i : int) (s : string) : dll_node = 
      let d = alloc heap 4 in
      assign_int heap d 0 i;
      assign_string heap d 1 s;
      assign_ptr heap d 2 (null heap);
      assign_ptr heap d 3 (null heap);
      d


  let prev (heap : heap) (n : dll_node) : dll_node = 
    deref_as_ptr heap n 2
    

  let next (heap : heap) (n : dll_node) : dll_node = 
    deref_as_ptr heap n 3

  let int_value (heap : heap) (n : dll_node) : int = 
    deref_as_int heap n 0

  let string_value (heap : heap) (n : dll_node) : string = 
    deref_as_string heap n 1

  let insert_after (heap : heap) (n1 : dll_node) (n2 : dll_node) : unit = 
      let n3 = next heap n1 in
      if is_null heap n3 then 
        (assign_ptr heap n1 3 n2 ;
        assign_ptr heap n2 2 n1 )
      else 
        (assign_ptr heap n1 3 n2;
        assign_ptr heap n2 2 n1;
        assign_ptr heap n2 3 n3;
        assign_ptr heap n3 2 n2
        )

  (* Should free the corresponding memory *)
  let remove (heap : heap) (n : dll_node) : unit = 
    let  p = prev heap n and
    c = next heap n in 
    if is_null heap p then 
    (
      if is_null heap c then
      (free heap n 4;)
      else
      (
        assign_ptr heap c 2 (null heap);
        free heap n 4;
      )
      
    )
    else 
    (
      if is_null heap c then 
      (
        assign_ptr heap p 3 (null heap);
        free heap n 4;
      ) 
      else
      (
        assign_ptr heap p 3 c;
        assign_ptr heap c 2 p;
        free heap n 4 ;
      ) 
    )


  let print_from_node (heap : heap) (n : dll_node) : unit = 
    let i  = deref_as_int heap n 0 and 
    s = deref_as_string heap n 1 in
    Printf.printf "(%d, %s)"i s;
end
