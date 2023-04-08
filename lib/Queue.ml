open Allocator
open DoublyLinkedList

(* A queue interface *)
module type Queue = sig
  type t

  val mk_queue : int -> t

  val is_empty : t -> bool

  val is_full : t -> bool

  val enqueue : t -> int * string -> unit

  val dequeue : t -> (int * string) option

  val queue_to_list : t -> (int * string) list
end

(******************************************************)
(*        A queue based on doubly linked lists        *)
(******************************************************)

module HeapDLLQueue (A : Allocator) : Queue = struct
  module DLL = DoublyLinkedList (A)
  open A
  open DLL

  (* Opaque queue type *)
  type t = {
    heap: heap;
    mutable head: dll_node;
    mutable tail: dll_node;
  }

  let mk_queue sz = 
    let heap = make_heap (sz * 4) in
    {
    heap = heap;
    head = null heap;
    tail = null heap;
    }

  let is_empty q = q.head = null q.heap

  (* DLL-based queue can grow indefinitely*)
  let is_full _ = false

  let enqueue q (k, v) = 
    let node_ptr = mk_node q.heap k v in
    (if q.head = null q.heap then q.head <- node_ptr);
    (if q.tail != null q.heap 
    then insert_after q.heap q.tail node_ptr);
    q.tail <- node_ptr

  let dequeue q = 
    if is_empty q then None
    else (
      let result = (int_value q.heap q.head, string_value q.heap q.head) in
      let old_head = q.head in
      let next_head = next q.heap q.head in
      q.head <- next_head;
      remove q.heap old_head;
      Some(result)
    )

  let queue_to_list q = 
    if is_empty q then []
    else (
      let rec to_list_from n acc = 
        if n = null q.heap
        then acc
        else (
          let current_payload = (int_value q.heap n, string_value q.heap n) in
          let next_node = next q.heap n in
          to_list_from next_node (current_payload :: acc)
        )
      in List.rev (to_list_from q.head [])
    )

end
