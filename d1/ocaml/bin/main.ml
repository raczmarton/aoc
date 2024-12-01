let file = "./input"
let split_list lst =
  let rec aux lst acc1 acc2 =
    match lst with
    | [] -> (List.rev acc1, List.rev acc2)
    | hd :: tl ->
      (match String.split_on_char ' ' hd |> List.filter (fun x -> x <> "") with
       | [str1; str2] -> aux tl (str1 :: acc1) (str2 :: acc2)
       | _ -> failwith "That don't look rite chief")
  in
  aux lst [] []


let read_file file : string list = 
    let ic = open_in file in
    let try_read () = 
        try Some (input_line ic) with End_of_file -> None in
    let rec reader acc = match try_read () with 
        | Some l -> reader (l :: acc)
        | None -> close_in ic; List.rev acc in
    reader []

let () = 
    let lines = read_file file in
    let (list1, list2) = split_list lines in
    let int_l1 = List.map int_of_string list1  in
    let int_l2 = List.map int_of_string list2 in
    let sorted_l1 = List.sort compare int_l1 in
    let sorted_le = List.sort compare int_l2 in
    let distances = List.map2( - ) sorted_l1 sorted_le |> List.map Int.abs in
    let dist = List.fold_left ( + ) 0 distances in
    let out = string_of_int dist in
    let dbg = String.concat " ; " (List.map string_of_int sorted_l1) in
    let _u = print_endline dbg in
    print_endline  out
