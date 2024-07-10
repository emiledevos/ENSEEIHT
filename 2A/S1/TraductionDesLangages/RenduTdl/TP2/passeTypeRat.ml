open Exceptions
open Ast
open Type
open Tds

type t1 = Ast.AstTds.programme
type t2 = Ast.AstType.programme

(*analyse_type_affectable : affectable -> affectable*)
(*Paramètre: affectable dont il faut analyser le type et sa cohérence*)
(*analyse du type des affectable, globalement il ajoute le type à l'info et vérifie la cohérence des types*)
let rec analyse_type_affectable a =
  match a with 
    |AstTds.Ident(i) -> (match info_ast_to_info i with
                            | InfoVar(_, t, _, _ )-> (AstType.Ident(i), t) 
                            |InfoConst _ -> (AstType.Ident(i), Int)
                            |_-> failwith "probleme info type")
    |AstTds.Deref(b)-> (match analyse_type_affectable b with 
                          |(nom, Pointeur t) ->  (AstType.Deref(nom,t), t)
                          |_ -> failwith("IMpossible, ni pointeur ni variable"))


(* analyse_type_expression : tds -> AstTds.expression -> AstType.expression *)
(* Paramètre e : l'expression à analyser *)
(* Vérifie la bonne utilisation des types et tranforme l'expression
en une expression de type AstType.expression *)
(* Erreur si mauvaise utilisation des type *)

let rec analyse_type_expression e = 
  match e with
    AstTds.Affectable(a) -> let (na,t) = analyse_type_affectable a in (AstType.Affectable(na),t) 
    | AstTds.Null -> (AstType.Null, Pointeur Undefined) 
    | AstTds.New t -> (AstType.New(t),Pointeur t)
    | AstTds.Adresse i -> (match (info_ast_to_info i)  with    (*Ici, il à était nécessaire de modifier la fonction est compatible, car dans ces cas, on renvoie le type Pointeur t qui n'est initialement pas pris en compte, on a donc ajouter un cas au match de la fonction est_compatible du module type.*)
          | InfoVar(_,t,_,_) -> (AstType.Adresse(i), Pointeur t)
          | _ ->failwith ("Ocamel crie") )
    |AstTds.Unaire(u,e) -> let (n,t)= analyse_type_expression e in 
                            if est_compatible t Rat then (match u with
                            |Denominateur -> (AstType.Unaire(Denominateur,n),Int)
                            |Numerateur -> (AstType.Unaire(Numerateur, n), Int))

                            else raise (TypeInattendu(t, Rat))
    | AstTds.Binaire (b, e1, e2) -> let (n1,t1) = analyse_type_expression e1 in 
                                    let (n2,t2) = analyse_type_expression e2 in
                                    if est_compatible t1 t2  then (match b with 
                                      | Plus -> if est_compatible t1 Int then (AstType.Binaire(PlusInt, n1, n2),Int) else if est_compatible t1 Rat then (AstType.Binaire(PlusRat, n1, n2),Rat) else raise( TypeBinaireInattendu( b, t1,t2))
                                      |Fraction -> if est_compatible t1 Int then (AstType.Binaire(Fraction, n1, n2), Rat) else raise( TypeBinaireInattendu(b, t1,t2))
                                      |Mult -> if est_compatible t1 Int then (AstType.Binaire(MultInt, n1, n2),Int) else if est_compatible t1 Rat  then  (AstType.Binaire(MultRat, n1, n2),Rat) else raise( TypeBinaireInattendu( b, t1,t2))
                                      |Equ -> if est_compatible t1 Bool then (AstType.Binaire(EquBool, n1, n2),Bool) else if est_compatible t1 Int  then  (AstType.Binaire(EquInt, n1, n2),Bool) else raise( TypeBinaireInattendu( b, t1,t2))
                                      |Inf -> (if (est_compatible t1 Int) then (AstType.Binaire(Inf, n1, n2),Bool) else (raise (TypeBinaireInattendu(b, t1,t2))))
                                          )


                                  else raise (TypeBinaireInattendu (b,t1,t2))
    | AstTds.Entier(n) -> (AstType.Entier(n),Int)
    | AstTds.Booleen(b) -> (AstType.Booleen(b),Bool)
    (*Le mtach de ident(i) qui était ici pase dans analyse affectable*)
    |AstTds.AppelFonction(i, le) -> (
      (match info_ast_to_info i with 
      |InfoFun(n, tRet, tParam) -> 
        let rec analyseParam l p =
          match l, p with 
            |[],[] -> []
            |[], _ -> raise (TypesParametresInattendus (tParam,[]))
            |_, [] -> raise (TypesParametresInattendus (tParam,[]))
            |t::q, x::y -> let (ne,te) =  analyse_type_expression t in if not(est_compatible te x) then raise (TypesParametresInattendus(tParam, [te])) 
            else ne::analyseParam q y in
            let nle=analyseParam le tParam in (AstType.AppelFonction(i,nle),tRet)
      |_->failwith "ocaml crie"))
    | _ -> failwith "erreur"


(* analyse_tds_instruction : tds -> info_ast option -> AstSyntax.instruction -> AstTds.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme l'instruction
en une instruction de type AstType.instruction *)
(* Erreur si mauvaise utilisation des types *)

let rec analyse_type_instruction i =
  match i with 
    |AstTds.Ethiq(i) -> AstType.Ethiq(i)
    |AstTds.Goto(i)-> AstType.Goto(i)

    |AstTds.Declaration(t,info,e) ->   let (ne,te) = analyse_type_expression e in
                                      if not(est_compatible t te) then raise(TypeInattendu (te,t))
                                      else modifier_type_variable t info; AstType.Declaration(info,ne)

    |AstTds.Conditionnelle (nc, tast, east) -> let (e,t) = analyse_type_expression nc in
                                                  if est_compatible t Bool then AstType.Conditionnelle(e, List.map (analyse_type_instruction) tast, List.map (analyse_type_instruction) east)
                                                  else raise (TypeInattendu(t, Bool))

    |AstTds.Affectation(a, e) -> let (na,t)= analyse_type_affectable a in
                                    let (ne,te)=analyse_type_expression e in
                                    if est_compatible t te then 
                                      AstType.Affectation(na, ne)
                                    else raise (TypeInattendu( te,t))  

    |AstTds.Affichage(e) -> (let (ne,te) = analyse_type_expression e in
                                            (match te with 
                                              |Int -> AffichageInt(ne)
                                              |Rat -> AffichageRat(ne)
                                              |Bool -> AffichageBool(ne)))

    |AstTds.TantQue(c, b) -> (let (nc,t) = analyse_type_expression c in 
                                            if Type.est_compatible t Bool then AstType.TantQue(nc, List.map (analyse_type_instruction) b) else raise (TypeInattendu(t, Bool)))
    |AstTds.Empty -> AstType.Empty
    |AstTds.Retour(e, i) -> let (ne, te) = analyse_type_expression e in (match info_ast_to_info i with 
                                                                      |InfoFun(_,tipe,_) ->if te!=tipe then raise (TypeInattendu( te,tipe)) else AstType.Retour(ne,i)
                                                                      |_->failwith("ocaml crie"))
    |Pour (t,i,e1,e2,e3,b) -> if (Type.est_compatible t Int) then (modifier_type_variable t i; let (ne1, t1) = analyse_type_expression e1 in let (ne2, t2) = analyse_type_expression e2 in let (ne3, t3) = analyse_type_expression e3 in
                             if not (Type.est_compatible t1 Int) then raise (TypeInattendu (t1, Int)) else
                              if not (Type.est_compatible t2 Bool) then raise (TypeInattendu (Bool, Int)) else
                                if not (Type.est_compatible t3 Int) then raise (TypeInattendu (t3, Int)) else Pour(i, ne1, ne2, ne3, List.map (analyse_type_instruction) b))
                              else raise (TypeInattendu (t, Int))

    |AstTds.Ethiq(i) -> AstType.Ethiq(i)
    |AstTds.Goto(i) -> AstType.Goto(i)


(*Vestige d'un weekend de debuggage*)

 (*) let print_info i=
    match i with 
    |InfoFun(n,t,l) -> print_string(n); print_string("a")
    |_-> print_string("e")

    let print_f f =
      match f with 
      AstTds.Fonction(t, info_fun_ast, _, _)-> print_info(info_ast_to_info(info_fun_ast))
      |_ -> print_string("erreur") *)

(*analyse_type_fonction : AstTds.Fonction -> AstType.Fonction*)
(*Paramètre : une fonction*)
(*MOdifie les info des types associé au fonction et au paramètre des fonction.*)
  let analyse_type_fonction (AstTds.Fonction(t,info,lp,li)) =

    let rec aux l   =
    match l with 
      []-> []
      |(typ,i)::q-> modifier_type_variable typ i; i::aux q in
    let linfo= aux lp in 
    modifier_type_fonction t (List.map(fst) lp) info;
    AstType.Fonction(info, linfo, List.map (analyse_type_instruction) li)
  
    let rec liste_fonction_type f =
      match f with 
      []->[]
      |t::q-> (analyse_type_fonction t) :: liste_fonction_type q

let analyser (AstTds.Programme (fonctions,prog)) =

  let nf =liste_fonction_type fonctions in
  let nb = List.map (analyse_type_instruction) prog in
  AstType.Programme (nf,nb) 





                                  

