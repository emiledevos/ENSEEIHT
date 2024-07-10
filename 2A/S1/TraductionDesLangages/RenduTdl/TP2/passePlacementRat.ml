open Tds
open Exceptions
open Ast
open AstType
open AstPlacement
open Type

type t1 = Ast.AstType.programme
type t2 = Ast.AstPlacement.programme


let rec somme l =
  match l with 
  |[]->0
  |t::q -> t+somme q

(*analyse_placement_instruction: Astinstruction*)
let rec analyse_placement_instruction instructions ind pile =
  match instructions with
  |AstType.Affectation(a, e) -> (AstPlacement.Affectation(a,e),0)  (*a priori pas de traitement spécial pour l'affectation, lettre changé de i en a pour mon cerveau. Le type est cohérent car on a mis Placement.Affectable=Type.Affectable*)
  |AstType.AffichageRat(e)->(AstPlacement.AffichageRat(e),0)
  |AstType.AffichageInt(e)->(AstPlacement.AffichageInt(e),0)
  |AstType.AffichageBool(e)->(AstPlacement.AffichageBool(e),0)
  |AstType.Declaration(i,e) -> (match info_ast_to_info i with 
                                  |InfoVar(n,t,_,_) ->modifier_adresse_variable ind pile i; (AstPlacement.Declaration(i, e), getTaille t)
                                  |_ -> failwith "Ocamel crie")
  |AstType.TantQue(c,b) -> let blocMem = analyse_placement_bloc b ind pile in (AstPlacement.TantQue(c,blocMem),0)
  |AstType.Conditionnelle(c,b1,b2) -> let blocMem1 = analyse_placement_bloc b1 ind pile in let blocMem2 = analyse_placement_bloc b2 ind pile in (AstPlacement.Conditionnelle(c,blocMem1,blocMem2),0)
  |AstType.Empty -> (AstPlacement.Empty, 0)
  |AstType.Retour(e,i) -> (match info_ast_to_info i with 
                          |InfoFun(_,t,lt) -> (AstPlacement.Retour(e, getTaille t, somme (List.map getTaille lt)), getTaille t)
                          |_ -> failwith "Ocamel crie")
  |AstType.Pour(i,e1,e2,e3,b) ->modifier_adresse_variable ind pile i; (AstPlacement.Pour(i,e1,e2,e3,analyse_placement_bloc b ind pile),0) 
  |AstType.Ethiq(i) ->  (AstPlacement.Ethiq(i),0)
  |AstType.Goto(i)->  (AstPlacement.Goto(i),0)

and  analyse_placement_bloc linstruct ind pile =
  match linstruct with 
    []-> ([],0)
    |t::q-> let (i,tailleI)=analyse_placement_instruction t ind pile in let (iS,tS)= analyse_placement_bloc q (ind+tailleI) pile in (i::iS,tailleI+tS)  


let analyse_placement_fonction (AstType.Fonction(info,linfo, bloc)) =
  let rec aux l placeCourante =
    match l with 
      [] -> ()
      |i::q -> (match info_ast_to_info i with 
                      |InfoVar(_,t,_,_)-> let place = (placeCourante -getTaille t) in modifier_adresse_variable place "LB" i; aux q place
                      |_ -> failwith "ocaml crie" )
  in aux (List.rev linfo) 0;
  let nbloc= analyse_placement_bloc bloc 3 "LB" in AstPlacement.Fonction(info, linfo, nbloc)

  let analyser (AstType.Programme(fonctions, bloc)) =
      let nf = List.map analyse_placement_fonction fonctions in 
      let nb = analyse_placement_bloc bloc 0 "SB" in
      AstPlacement.Programme(nf, nb)