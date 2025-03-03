(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 assumption *)
Inductive ref (a:Type) :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Arguments mk_ref {a}.

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a} (v:ref a) : a :=
  match v with
  | mk_ref x => x
  end.

(* Why3 goal *)
Theorem VC_somme :
  forall (m:Z) (n:Z), (0%Z <= n)%Z ->
  ((n + m)%Z = (m + n)%Z) /\
  forall (i:Z) (r:Z), ((r + i)%Z = (m + n)%Z) ->
  ((0%Z < i)%Z -> forall (r1:Z), (r1 = (r + 1%Z)%Z) -> forall (i1:Z),
   (i1 = (i - 1%Z)%Z) ->
   ((0%Z <= i)%Z /\ (i1 < i)%Z) /\ ((r1 + i1)%Z = (m + n)%Z)) /\
  (~ (0%Z < i)%Z -> ((n + m)%Z = r)).
(* Why3 intros m n h1. *)
Proof.
intros i r h1 r1 h2 i1.

Qed.

