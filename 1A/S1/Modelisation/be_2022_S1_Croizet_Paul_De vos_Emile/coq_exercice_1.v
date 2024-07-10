Require Import Naturelle.
Section Session1_2022_Logique_Exercice_1.

Variable A B : Prop.

Theorem Exercice_1_Naturelle : (A \/ B) -> (~A) -> B.
Proof.
I_imp H0.
I_imp H1.
E_ou A B.
Hyp H0.
I_imp H2.
E_antiT.
I_antiT A.
Hyp H2.
Hyp H1.
I_imp H3.
Hyp H3.
Qed.

Theorem Exercice_1_Coq : (A \/ B) -> (~A) -> B.
Proof.
intros.
elim H.
intro.
cut False.
intro H2.
contradiction.
absurd A.
exact H0.
exact H1.
intro I.
exact I.
Qed.

End Session1_2022_Logique_Exercice_1.

