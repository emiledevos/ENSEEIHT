(* Module de la passe de gestion des identifiants *)
(* doit être conforme à l'interface Passe *)
open Tds
open Exceptions
open Ast

type t1 = Ast.AstSyntax.programme
type t2 = Ast.AstTds.programme

(*get_ethiquette : liste instruction -> tds -> tds
  Param: la tds des ethiquette : tdse
          la liste des instructions : li
  renvoie une tds avec tout les éthiquette truové dans la liste du programme, erreur si l'ethiquette est déjà définie*)
  (*la variable contexte permettra de créé une éthiquette avec le nom de la fonction dans la dernière passe*)

let rec get_ethiquette li contexte tdse= 
  match li with 
  |[] -> tdse
  |AstSyntax.Ethiq(n)::q -> (match (chercherGlobalement tdse n) with 
                              |None ->  let i = InfoEthiq(n, contexte) in ajouter tdse n (info_to_info_ast i); get_ethiquette q contexte tdse
                              |Some _ -> raise (MauvaiseUtilisationIdentifiant n))  (*ON doit visiter chaque bloc, dont ceux des conditionelle/BOucle*)
  |AstSyntax.Conditionnelle(_,b1,b2)::q -> get_ethiquette (b1@b2@q) contexte tdse
  |AstSyntax.TantQue(_,b)::q -> get_ethiquette(b@q) contexte tdse
  |_::q -> get_ethiquette q contexte tdse


(*analyse_tds_affectable : tds ASTSYntax.affectable -> astTDS.affecatble*)

let rec analyse_tds_affectable tds modifier a =
  match a with 
    |AstSyntax.Ident(n) -> (match chercherGlobalement tds n with 
                              |None -> raise (IdentifiantNonDeclare n)
                              |Some i -> (match info_ast_to_info i with
                                  | InfoVar _ -> AstTds.Ident(i)
                                  | InfoConst _ -> if modifier then raise(MauvaiseUtilisationIdentifiant n) else Ident(i)
                                  | InfoFun _ -> raise (MauvaiseUtilisationIdentifiant n)
                                  | _ -> raise (MauvaiseUtilisationIdentifiant n)))
    |AstSyntax.Deref(ai) -> AstTds.Deref(analyse_tds_affectable tds modifier ai)

(* analyse_tds_expression : tds -> AstSyntax.expression -> AstTds.expression *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre e : l'expression à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme l'expression
en une expression de type AstTds.expression *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_expression tds e = 
  match e with
  | AstSyntax.Null -> AstTds.Null
  | AstSyntax.New t -> AstTds.New t
  | AstSyntax.Affectable a -> AstTds.Affectable(analyse_tds_affectable tds false a)
  | AstSyntax.Adresse n -> (match chercherGlobalement tds n with
                              |None -> raise (IdentifiantNonDeclare n)
                              |Some i -> (match info_ast_to_info i with 
                                  |InfoVar _ -> AstTds.Adresse i
                                  |_ -> raise (MauvaiseUtilisationIdentifiant n)))
  | AstSyntax.Entier(n) -> AstTds.Entier n
  | AstSyntax.Booleen (b) -> AstTds.Booleen b
  | AstSyntax.Binaire (b, e1, e2) -> AstTds.Binaire(b,analyse_tds_expression tds e1,analyse_tds_expression tds e2)
  | AstSyntax.Unaire (b, e) -> AstTds.Unaire(b, analyse_tds_expression tds e)
  | AstSyntax.AppelFonction(n, l) -> 
    match chercherGlobalement tds n with 
    | None -> raise (IdentifiantNonDeclare n)
    | Some i -> (match info_ast_to_info i with  
                | InfoFun (s, t, tl) -> AstTds.AppelFonction(i,(List.map (analyse_tds_expression tds) l))   (* afficher_locale tdsbloc ; *) (* décommenter pour afficher la table locale *)
                |_ -> raise (MauvaiseUtilisationIdentifiant n))
             
             



(* analyse_tds_instruction : tds -> info_ast option -> AstSyntax.instruction -> AstTds.instruction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre oia : None si l'instruction i est dans le bloc principal,
                   Some ia où ia est l'information associée à la fonction dans laquelle est l'instruction i sinon *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme l'instruction
en une ins             truction de type AstTds.instruction *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_instruction tdse tds oia i =
  match i with
  |AstSyntax.Goto(n) -> (match chercherGlobalement tdse n with 
                            |None -> raise (MauvaiseUtilisationIdentifiant n) (*SI ethiquetet non déclarer -> erreur*)
                            |Some i -> AstTds.Goto(i))

  |AstSyntax.Ethiq(n) -> (match chercherGlobalement tdse n with 
                              |None -> raise (MauvaiseUtilisationIdentifiant n) (*Impossible car l'erreur serait déjà lever dans get_ethiquette*)
                              |Some i -> AstTds.Ethiq(i))

  | AstSyntax.Declaration (t, n, e) ->
      begin
        match chercherLocalement tds n with
        | None ->
            (* L'identifiant n'est pas trouvé dans la tds locale,
            il n'a donc pas été déclaré dans le bloc courant *)
            (* Vérification de la bonne utilisation des identifiants dans l'expression *)
            (* et obtention de l'expression transformée *)
            let ne = analyse_tds_expression tds e in
            (* Création de l'information associée à l'identfiant *)
            let info = InfoVar (n,Undefined, 0, "") in
            (* Création du pointeur sur l'information *)
            let ia = info_to_info_ast info in
            (* Ajout de l'information (pointeur) dans la tds *)
            ajouter tds n ia;
            (* Renvoie de la nouvelle déclaration où le nom a été remplacé par l'information
            et l'expression remplacée par l'expression issue de l'analyse *)
            AstTds.Declaration (t, ia, ne)
        | Some _ ->
            (* L'identifiant est trouvé dans la tds locale,
            il a donc déjà été déclaré dans le bloc courant *)
            raise (DoubleDeclaration n)
      end
  | AstSyntax.Affectation (a,e) ->
    let na = analyse_tds_affectable tds true a in
    let ne = analyse_tds_expression tds e in AstTds.Affectation(na, ne)
  | AstSyntax.Constante (n,v) -> 
      begin
        match chercherLocalement tds n with
        | None -> 
        (* L'identifiant n'est pas trouvé dans la tds locale, 
        il n'a donc pas été déclaré dans le bloc courant *)
        (* Ajout dans la tds de la constante *)
        ajouter tds n (info_to_info_ast (InfoConst (n,v))); 
        (* Suppression du noeud de déclaration des constantes devenu inutile *)
        Empty
        | Some _ ->
          (* L'identifiant est trouvé dans la tds locale, 
          il a donc déjà été déclaré dans le bloc courant *) 
          raise (DoubleDeclaration n)
      end
  | AstSyntax.Affichage e ->
      (* Vérification de la bonne utilisation des identifiants dans l'expression *)
      (* et obtention de l'expression transformée *)
      let ne = analyse_tds_expression tds e in
      (* Renvoie du nouvel affichage où l'expression remplacée par l'expression issue de l'analyse *)
      AstTds.Affichage (ne)
  | AstSyntax.Conditionnelle (c,t,e) ->
      (* Analyse de la condition *)
      let nc = analyse_tds_expression tds c in
      (* Analyse du bloc then *)
      let tast = analyse_tds_bloc tdse tds oia t in
      (* Analyse du bloc else *)
      let east = analyse_tds_bloc tdse tds oia e in
      (* Renvoie la nouvelle structure de la conditionnelle *)
      AstTds.Conditionnelle (nc, tast, east)
  | AstSyntax.TantQue (c,b) ->
      (* Analyse de la condition *)
      let nc = analyse_tds_expression tds c in
      (* Analyse du bloc *)
      let bast = analyse_tds_bloc tdse tds oia b in
      (* Renvoie la nouvelle structure de la boucle *)
      AstTds.TantQue (nc, bast)
  | AstSyntax.Retour (e) ->
      begin
      (* On récupère l'information associée à la fonction à laquelle le return est associée *)
      match oia with
        (* Il n'y a pas d'information -> l'instruction est dans le bloc principal : erreur *)
      | None -> raise RetourDansMain
        (* Il y a une information -> l'instruction est dans une fonction *)
      | Some ia ->
        (* Analyse de l'expression *)
        let ne = analyse_tds_expression tds e in
        AstTds.Retour (ne,ia)
      end
  |AstSyntax.Pour(t, n1, n2, e1, e2, e3, b) -> if not(n1=n2) then raise (MauvaiseUtilisationIdentifiant n2) (* Dans ce cas, on a utiliser une variable différente dans la condition d'arret de la boucle que celle avec la quelle on à définit la boucle*)
                                                  else match chercherGlobalement tds n1 with (* il serait surement necessaire de verifier que la condition d'arret comprend bien le paramètre n1, à faire éventuellement plus tard *)
                                                  |None -> let info = InfoVar (n1,Undefined, 0, "") in 
                                                  let infop = info_to_info_ast info in
                                                  (* Ajout de l'information (pointeur) dans la tds *)
                                                  ajouter tds n1 infop; 
                                                  AstTds.Pour(t,infop, analyse_tds_expression tds e1,analyse_tds_expression tds e2,analyse_tds_expression tds e3, analyse_tds_bloc tdse tds oia b)
                                                  |Some _ -> raise (DoubleDeclaration n1)


(* analyse_tds_bloc : tds -> info_ast option -> AstSyntax.bloc -> AstTds.bloc *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre oia : None si le bloc li est dans le programme principal,
                   Some ia où ia est l'information associée à la fonction dans laquelle est le bloc li sinon *)
(* Paramètre li : liste d'instructions à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme le bloc en un bloc de type AstTds.bloc *)
(* Erreur si mauvaise utilisation des identifiants *)
and analyse_tds_bloc tdse tds oia li =
  (* Entrée dans un nouveau bloc, donc création d'une nouvelle tds locale
  pointant sur la table du bloc parent *)
  let tdsbloc = creerTDSFille tds in
  (* Analyse des instructions du bloc avec la tds du nouveau bloc.
     Cette tds est modifiée par effet de bord *)
   let nli = List.map (analyse_tds_instruction tdse tdsbloc oia ) li  in
   (* afficher_locale tdsbloc ; *) (* décommenter pour afficher la table locale *)
   nli


  (*let rec ajout_TDS tdsf l =
    match l with 
    []->()
    |(_,n)::q -> match chercherLocalement tdsf n with 
                |None -> ajouter tdsf n (info_to_info_ast(InfoVar(n,Undefined,0,"")));
                ajout_TDS tdsf q
                |Some _ -> raise (DoubleDeclaration n)*)
    

(*FOnction qui on était utile lors d'un weekend de debbugage, souvenir souvenir...*)


(*
let print_info i=
match i with 
|InfoFun(n,t,l) -> print_string(n)
|_-> print_string("e")
*)(*
let print_f f =
  match f with 
  AstTds.Fonction(t, info_fun_ast, _, _)-> print_info(info_ast_to_info(info_fun_ast))
  |_ -> print_string("erreur")
*)


(*analyse_liste : typ*string list-> tds -> typ*info_ast list*)
(*Paramètre: TDS de la fonction, liste l de paramètre de la fonction*)
(*Le but de cette fonction est d'enregistrer dans la tds le nom des paramètre de la fonction. *)
(*Renvoie une ereur si deux param ont le même nom.*)
let rec analyse_liste l tdsf = 
  match l with 
  |[]->[]
  |(t, n)::q -> match chercherLocalement tdsf n with 
                    |None ->let info = info_to_info_ast(InfoVar(n,Undefined,0,"")) in  ajouter tdsf n info; (t,info)::(analyse_liste q tdsf)
                    |Some _ -> raise (DoubleDeclaration n)



(* analyse_tds_fonction : tds -> AstSyntax.fonction -> AstTds.fonction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre : la fonction à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme la fonction
en une fonction de type AstTds.fonction *)
(* Erreur si mauvaise utilisation des identifiants *)

let analyse_tds_fonction maintds (AstSyntax.Fonction(t,n,lp,li))  =
  match chercherLocalement maintds n with
    |None -> (let info_fun =InfoFun(n,t,(List.map fst lp)) in let tdse= creerTDSMere () in
    let tdsfille = creerTDSFille maintds in
    let info_fun_ast = info_to_info_ast info_fun in ajouter maintds n info_fun_ast;
    let argAnal =  analyse_liste lp tdsfille in
    AstTds.Fonction(t, info_fun_ast, argAnal, (analyse_tds_bloc (get_ethiquette li n tdse) tdsfille (Some info_fun_ast) li )))
    |Some _ -> raise (DoubleDeclaration n)



(* analyser : AstSyntax.programme -> AstTds.programme *)
(* Paramètre : le programme à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme le programme
en un programme de type AstTds.programme *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyser (AstSyntax.Programme (fonctions,prog)) =
  let tds = creerTDSMere () in
  let tdse= creerTDSMere () in let tdseEthiquette = get_ethiquette prog "main" tdse in
  let nf = List.map (analyse_tds_fonction tds) fonctions in
 (* List.iter print_f nf;*)
  let nb = analyse_tds_bloc tdseEthiquette tds None prog  in
  AstTds.Programme (nf,nb)
