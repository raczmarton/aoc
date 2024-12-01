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

module IntMap = Map.Make(Int)
let read_file file : string list = 
    let ic = open_in file in
    let try_read () = 
        try Some (input_line ic) with End_of_file -> None in
    let rec reader acc = match try_read () with 
        | Some l -> reader (l :: acc)
        | None -> close_in ic; List.rev acc in
    reader []


let sort_split_lines lines : int list * int list =
    let (list1, list2) = split_list lines in
    let int_l1 = List.map int_of_string list1  in
    let int_l2 = List.map int_of_string list2 in
    let sorted_l1 = List.sort compare int_l1 in
    let sorted_le = List.sort compare int_l2 in
    (sorted_l1, sorted_le)

let find_distance sorted_l1 sorted_l2 : int = 
    let distances = List.map2( - ) sorted_l1 sorted_l2 |> List.map Int.abs in
    let dist = List.fold_left ( + ) 0 distances in
    (dist)

let similarity sorted_l1 sorted_l2 : int = 
   let scores = List.fold_left (fun acc v -> (IntMap.update v (fun mape -> 
    match mape with 
    | Some opt -> Some(opt+1)
    | None -> Some(1)) acc )) IntMap.empty sorted_l2 in

   let result =  (List.fold_left (fun acc v -> 
        match IntMap.find_opt v scores with 
    | Some opt -> acc + (opt * v)
    | None -> acc
    ) 0 sorted_l1) in
   (result)


let () =
    let lines = read_file file in
    let (sorted_l1, sorted_l2) = sort_split_lines lines in
    let sim = similarity sorted_l1 sorted_l2 in
    let abs_dist = find_distance sorted_l1 sorted_l2 in
    let fmt = format_of_string "Similarity: %d \nAbsolute distance: %d \n" in
    let formatted_string = Printf.sprintf fmt sim abs_dist in
    print_endline formatted_string
    
