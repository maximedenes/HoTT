Require Import Category.Core Functor.Core Category.Prod NaturalTransformation.Core Functor.Composition Functor.Prod.
Require Import Functor.Paths.
Require Import types.Prod HoTT.Tactics types.Forall types.Sigma.

Set Universe Polymorphism.
Set Implicit Arguments.
Generalizable All Variables.
Set Asymmetric Patterns.

Local Notation fst_type := Coq.Init.Datatypes.fst.
Local Notation snd_type := Coq.Init.Datatypes.snd.
Local Notation pair_type := Coq.Init.Datatypes.pair.
Local Notation prod_type := Coq.Init.Datatypes.prod.

Local Open Scope morphism_scope.
Local Open Scope functor_scope.

Section universal.
  Context `{Funext}.

  Variable A : PreCategory.
  Variable B : PreCategory.
  Variable C : PreCategory.

  Local Open Scope functor_scope.

  Section universal.
    Variable a : Functor C A.
    Variable b : Functor C B.

    Local Transparent compose_composition_of compose_identity_of.

    Lemma compose_fst_prod : fst o (a * b) = a.
    Proof.
      path_functor; trivial.
    Defined.

    Lemma compose_snd_prod : snd o (a * b) = b.
    Proof.
      path_functor; trivial.
    Defined.

    Section unique.
      Variable F : Functor C (A * B).
      Hypothesis H1 : fst o F = a.
      Hypothesis H2 : snd o F = b.

      Lemma unique_helper c
      : (a * b) c = F c.
      Proof.
        pose proof (ap (fun F => object_of F c) H1).
        pose proof (ap (fun F => object_of F c) H2).
        simpl in *.
        path_induction.
        apply eta_prod.
      Defined.

      Lemma unique_helper2
      : transport
          (fun GO : C -> prod_type A B =>
             forall s d : C,
               morphism C s d ->
               prod_type (morphism A (fst_type (GO s)) (fst_type (GO d)))
                         (morphism B (snd_type (GO s)) (snd_type (GO d))))
          (path_forall (a * b) F unique_helper)
          (fun (s d : C) (m : morphism C s d) => pair_type (a _1 m) (b _1 m)) =
        morphism_of F.
      Proof.
        repeat (apply path_forall; intro).
        repeat match goal with
                 | _ => reflexivity
                 | _ => progress simpl
                 | _ => rewrite !transport_forall_constant
                 | [ |- appcontext[?f (transport ?P ?p ?z)] ]
                   => rewrite (@ap_transport _ P _ _ _ p (fun _ => f) z)
               end.
        transport_path_forall_hammer.
        unfold unique_helper.
        repeat match goal with
                 | [ H : _ = _ |- _ ] => case H; simpl; clear H
               end.
        repeat match goal with
                 | [ |- appcontext[@morphism_of ?C ?D ?F ?s ?d ?m] ]
                   => destruct (@morphism_of C D F s d m); clear m
                 | [ |- appcontext[@object_of ?C ?D ?F ?x] ]
                   => destruct (@object_of C D F x); clear x
               end.
        reflexivity.
      Qed.

      Lemma unique
      : a * b = F.
      Proof.
        path_functor.
        exists (path_forall _ _ unique_helper).
        apply unique_helper2.
      Defined.
    End unique.

    Local Open Scope core_scope.

    Global Instance contr_prod_type
           `{IsHSet (Functor C A), IsHSet (Functor C B)}
    : Contr { F : Functor C (A * B)
            | fst o F = a
              /\ snd o F = b }
      := let x := {| center := (a * b;
                                (compose_fst_prod,
                                 compose_snd_prod)) |}
         in x.
    Proof.
      intro y.
      apply path_sigma_uncurried.
      simpl.
      exists (unique (fst_type y.2) (snd_type y.2)).
      exact (center _).
    Qed.
  End universal.

  Definition path_prod (F G : Functor C (A * B))
             (H1 : fst o F = fst o G)
             (H2 : snd o F = snd o G)
  : F = G.
  Proof.
    etransitivity; [ apply symmetry | ];
    apply unique; try eassumption; reflexivity.
  Defined.
End universal.
