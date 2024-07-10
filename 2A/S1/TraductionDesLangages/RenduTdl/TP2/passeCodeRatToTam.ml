open Tds
open Exceptions
open Ast
open AstType
open AstPlacement
open Type
open Code
open Tam

type t1 = Ast.AstPlacement.programme
type t2 = string


(* analyse_affectable : AstPlacement.affectable -> bool -> String *)
(* Paramètre : Un affectable *)
(* génère le code a produire pour gerer un affectable. Le booleen ecriture permet ici de différencier si on est en écriture ou en lecture *)

let rec analyse_affectable a ecriture =
  match a with 
  |AstType.Ident(i) -> (match info_ast_to_info i with 
                              |InfoConst(_,v) -> loadl_int v
                              |InfoVar(_, t, dep, reg) -> if ecriture then store (getTaille t) dep reg else load (getTaille t) dep reg
                              |_ -> failwith "OCAML CRIE")
  |AstType.Deref(ab, t) -> if ecriture then (analyse_affectable ab false) ^ (storei (getTaille t)) else (analyse_affectable ab false) ^ loadi (getTaille t)




(* analyse_expression : AstPlacement.expression -> String *)
(* Paramètre : Une expression *)
(* génère le code a produire pour gerer une expression. *)

let rec analyse_expression e =
  match e with 
  |AstType.New(t) -> loadl_int (getTaille t)^ subr "Malloc"
  |AstType.Null -> ""
  |AstType.Adresse(i) -> (match info_ast_to_info i with
                              |InfoVar(n,t,dep,reg) -> loada dep reg
                              |_ -> failwith "ocaml crie")
  |AstType.Affectable(a) -> analyse_affectable a false
  |AstType.Entier i -> loadl_int i 
  |AstType.Unaire(op, e) -> analyse_expression e ^ if (op == Numerateur) then pop 0 1 else if (op == Denominateur) then pop 1 1 else failwith "erreur"
  |AstType.Binaire(op,e1,e2) ->  analyse_expression e1 ^ analyse_expression e2 ^ (match op with
                                                                                |PlusInt -> subr "IAdd"
                                                                                |MultInt -> subr "IMul"
                                                                                |EquInt -> subr "IEq"
                                                                                |Inf -> subr "ILss"
                                                                                |Fraction -> ""
                                                                                |EquBool-> subr "Ieq"                                                                                
                                                                                |PlusRat -> call "St" "Radd"
                                                                                |MultRat -> call "St" "RMul")
  |AstType.Booleen(b) -> if not(b) then loadl_int 0 else loadl_int 1
  |AstType.AppelFonction(i, le) ->(match info_ast_to_info i with
                                |InfoFun(n,_,_) -> (List.fold_left (^) "" (List.map (analyse_expression) le)) ^
                                    call "SB" n 
                                |_->failwith "Ocaml crie")



(* analyse_affectable : AstPlacement.instruction ->  String *)
(* Paramètre : Une instruciton *)
(* génère le code a produire pour gerer une instruction. *)

let rec analyse_instruction i = 
  match i with 
    |Empty-> "" 
    |AstPlacement.Declaration(info,e)-> (match (info_ast_to_info info) with 
                                          |InfoVar(_, t,dep,reg) -> push (getTaille t) ^ analyse_expression e  ^ store (getTaille t) dep reg 
                                          |_ -> failwith "OCAML CRIE")
                                          
    |AstPlacement.Affectation(a,e) -> analyse_expression e ^ analyse_affectable a true
    |AstPlacement.TantQue(c,b) -> let d = "etiq1\n" in let f = "etiq2\n" in d ^
                                                              analyse_expression c ^
                                                              jumpif 0 f  ^
                                                              analyser_bloc b ^ 
                                                              jump d ^
                                                              f
    |AstPlacement.Pour(i, e1,e2,e3, b ) -> let d = "etiq1\n" in let f = "etiq2\n" in analyse_instruction (AstPlacement.Declaration(i,e1)) ^ d ^
                                                              analyse_expression e2 ^
                                                              jumpif 0 f  ^
                                                              analyser_bloc b ^
                                                              analyse_instruction (AstPlacement.Affectation(Ident i,e3)) ^ 
                                                              jump d ^
                                                              f
                                                              (*Le code est similaire a celui du while, il faut cependant déclarer en plus au début la variable locale au code et ne pas oublier de l'incrementer a chaque tours de boucle, la condition devient l'expression e2*)

    |AstPlacement.Conditionnelle(c,b1,b2) -> let et_if = getEtiquette() in let et_else = getEtiquette() in
                                                                      analyse_expression c ^
                                                                      jumpif 0 et_if ^
                                                                      analyser_bloc b1 ^
                                                                      jump et_else ^
                                                                      label et_if ^
                                                                      analyser_bloc b2 ^
                                                                      label et_else 

    |AstPlacement.AffichageBool(e) -> analyse_expression e ^
                          Tam.subr "Bout"

    |AstPlacement.AffichageInt(e) -> analyse_expression e ^
                        Tam.subr "Iout"

    |AstPlacement.AffichageRat(e) -> analyse_expression e ^
                         call "St" "rout"
    |AstPlacement.Retour(e, tr, taille_lp) -> analyse_expression e ^ 
                                            return tr taille_lp
    |AstPlacement.Goto(i) -> (match info_ast_to_info i with
                                |InfoEthiq(n,contexte) -> let e = n^contexte in jump e 
                                |_ -> failwith "ocamel crie")
    |AstPlacement.Ethiq(i) -> (match info_ast_to_info i with
                                |InfoEthiq(n,contexte) -> let e = n^contexte in label e
                                |_ -> failwith "ocamel crie")
    |_ -> failwith "a completer"


and analyser_bloc (l, taille) = 
  match l with
  |[] -> ""
  |t:: q -> analyse_instruction t ^analyser_bloc (q,taille) 

  (*analyse_fonction : AstPlacement.Fonction -> string
     Paramètre : un fonction 
     génère le code associé a une fcontion*)
  let analyse_fonction (AstPlacement.Fonction(info,_,l)) =
    match info_ast_to_info info with 
      |InfoFun(n,_,_) ->
        label n ^
        analyser_bloc l ^
        halt
      |_ ->failwith "ocaml crie"

  
let rec analyser (AstPlacement.Programme (fonctions,bloc)) =
  getEntete() ^
  (List.fold_left (^) "" (List.map (analyse_fonction) fonctions)) 
  ^ "Main \n" ^
  analyser_bloc bloc ^
  halt