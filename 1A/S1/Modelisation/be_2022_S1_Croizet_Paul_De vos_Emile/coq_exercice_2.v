Require Import Naturelle.
Section Session1_2022_Logique_Exercice_2.

Variable A B : Prop.

Theorem Exercice_2_Naturelle : ((~A) -> B) -> (A \/ B).
Proof.
I_imp H0.
E_ou A (~A).
TE.
I_imp H1.
I_ou_g.
Hyp H1.
I_imp H2.
I_ou_d.
E_imp (~A).
Hyp H0.
Hyp H2.
Qed.

Theorem Exercice_2_Coq : ((~A) -> B) -> (A \/ B).
intros.
cut (A \/~A).
intro.
elim H0.
intro.
left.
exact H1.
intro.
right.
cut (~A).
exact H.
exact H1.
apply (classic A).

Qed.

End Session1_2022_Logique_Exercice_2.

