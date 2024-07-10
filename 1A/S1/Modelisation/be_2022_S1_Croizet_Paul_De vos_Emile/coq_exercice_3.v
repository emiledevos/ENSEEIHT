Section Session1_2022_Induction_Exercice_3.

(* Déclaration d’un domaine pour les éléments des listes *)
Variable A : Set.

(* Définition du type inductif représentant les entiers naturels *) 
Inductive naturel : Set :=
  Zero : naturel
  | Succ : naturel -> naturel.

(* Définition du type inductif représentant les listes d'éléments de type A *) 
Inductive liste : Set :=
Nil : liste
| Cons : A -> liste -> liste.

(* Déclaration du nom de la fonction taille *)
Variable taille_spec : liste -> naturel.

(* Spécification du comportement de taille pour Nil en paramètre *)
Axiom taille_Nil : (taille_spec Nil) = Zero.

(* Spécification du comportement de taille pour Cons en paramètre *)
Axiom taille_Cons : forall (t : A), forall (q : liste),
  (taille_spec(Cons t q)) = (Succ(taille_spec q)). 

(* Déclaration du nom de la fonction map *)
Variable map_spec : (A -> A) -> (liste -> liste).

(* Spécification du comportement de map pour Nil en paramètre *)
Axiom map_Nil : forall (f: A -> A), (map_spec f Nil) = Nil.

(* Spécification du comportement de taille pour Cons en paramètre *)
Axiom map_Cons : forall (f: A -> A),forall (t : A), forall (q : liste),
(map_spec f (Cons t q)) = (Cons (f t) (map_spec f q)).

Theorem taille_map : forall (f : A -> A), forall (l : liste), (taille_spec (map_spec f l)) = (taille_spec l).
Proof.
intros.
induction l.
rewrite map_Nil.
reflexivity.
rewrite map_Cons.
rewrite taille_Cons.
rewrite IHl.
rewrite taille_Cons.
reflexivity.
Qed.

(* Implantation de la fonction taille *)
Fixpoint taille_impl (l : liste) {struct l} : naturel :=
match l with 
  |Nil => Zero
  |(Cons t q) => Succ (taille_impl q)
end.

(* Preuve de correction de l'implantation de la fonction taille par rapport à sa spécification. *)
Theorem taille_correcte : forall (l : liste), (taille_spec l) = (taille_impl l).
Proof.
intros.
induction l.
simpl.
rewrite taille_Nil.
reflexivity.

simpl.
rewrite taille_Cons.
rewrite IHl.
reflexivity.
Qed.

End Session1_2022_Induction_Exercice_3.s
