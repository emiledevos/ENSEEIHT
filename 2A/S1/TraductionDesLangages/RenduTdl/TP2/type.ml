type typ = Bool | Int | Rat | Pointeur of typ | Undefined 

let rec string_of_type t = 
  match t with
  | Bool ->  "Bool"
  | Int  ->  "Int"
  | Rat  ->  "Rat"
  |Pointeur t -> "Pointeur "^string_of_type t (*modifier pour l'affichage des pointeurs*)
  | Undefined -> "Undefined"


let rec est_compatible t1 t2 =  (*MOdifier pour vérifier la cohérence de deux pointeur*)
  match t1, t2 with
  | Bool, Bool -> true
  | Int, Int -> true
  | Rat, Rat -> true 
  | Pointeur a, Pointeur b -> (match a, b with 
                                  |Undefined, _ -> true
                                  |_, Undefined -> true 
                                  |_,_ -> (est_compatible a b))
  | _ -> false 

let%test _ = est_compatible Bool Bool
let%test _ = est_compatible Int Int
let%test _ = est_compatible Rat Rat
let%test _ = est_compatible (Pointeur Int) (Pointeur Int)
let%test _ = est_compatible (Pointeur Rat) (Pointeur Rat)
let%test _ = not (est_compatible Int Bool)
let%test _ = not (est_compatible Bool Int)
let%test _ = not (est_compatible Int Rat)
let%test _ = not (est_compatible Rat Int)
let%test _ = not (est_compatible Bool Rat)
let%test _ = not (est_compatible Rat Bool)
let%test _ = not (est_compatible Undefined Int)
let%test _ = not (est_compatible Int Undefined)
let%test _ = not (est_compatible Rat Undefined)
let%test _ = not (est_compatible Bool Undefined)
let%test _ = not (est_compatible Undefined Int)
let%test _ = not (est_compatible Undefined Rat)
let%test _ = not (est_compatible Undefined Bool)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Bool)
let%test _ = not (est_compatible (Pointeur Int) (Pointeur Bool))
let%test _ = not (est_compatible (Pointeur Rat) (Pointeur Bool))
let%test _ = not (est_compatible (Pointeur Int) (Pointeur Rat))

let est_compatible_list lt1 lt2 =
  try
    List.for_all2 est_compatible lt1 lt2
  with Invalid_argument _ -> false

let%test _ = est_compatible_list [] []
let%test _ = est_compatible_list [Int ; Rat] [Int ; Rat]
let%test _ = est_compatible_list [Bool ; Rat ; Bool] [Bool ; Rat ; Bool]
let%test _ = not (est_compatible_list [Int] [Int ; Rat])
let%test _ = not (est_compatible_list [Int] [Rat ; Int])
let%test _ = not (est_compatible_list [Int ; Rat] [Rat ; Int])
let%test _ = not (est_compatible_list [Bool ; Rat ; Bool] [Bool ; Rat ; Bool ; Int])
let%test _ = est_compatible_list [(Pointeur Int) ; (Pointeur Rat)] [(Pointeur Int) ; (Pointeur Rat)]
let rec getTaille t = (*Modifier pour dire que la taille d'un pointeur et de 1*)
  match t with
  | Int -> 1
  | Bool -> 1
  | Rat -> 2
  | Pointeur t -> getTaille t
  | Undefined -> 0

  
let%test _ = getTaille Int = 1
let%test _ = getTaille Bool = 1
let%test _ = getTaille Rat = 2
let%test _ = getTaille (Pointeur Rat) = 2
