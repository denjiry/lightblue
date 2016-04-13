{-# OPTIONS -Wall #-}
{-# LANGUAGE OverloadedStrings #-}

{-|
Description : LexicalTemplates
Copyright   : (c) Daisuke Bekki, 2016
Licence     : All right reserved
Maintainer  : Daisuke Bekki <bekki@is.ocha.ac.jp>
Stability   : beta
-}

module LexicalTemplates (
  -- * Macros for lexical items
  lexicalitem,
  -- * Macros for CCG syntactic features
  defS,
  ---
  verb,
  adjective,
  nomPred,
  nonStem,
  anySExStem,
  anyPos,
  m5,
  pmmmm,
  mpmmm,
  mmpmm,
  mmmpm,
  mppmm,
  -- * Templates for DTS representations
  id,
  verbSR,
  predSR,
  nPlaceEventType,
  nPlaceStateType,
  nPlacePredType,
  properNameSR,
  commonNounSR,
  intensionalEvent,
  intensionalState,
  modalSR,
  mannerAdverb,
  eventModifier,
  negOperator,
  argumentCM,
  adjunctCM,
  andSR,
  orSR
  ) where

import Prelude hiding (id)
import qualified Data.Text.Lazy as T -- text
import Data.Ratio
import CombinatoryCategorialGrammar
import DependentTypes

{- Some Macros for defining lexical items -}

lexicalitem :: T.Text -> T.Text -> Integer -> Cat -> (Preterm, [Signature]) -> Node
lexicalitem pf' source' score' cat' (sem',sig') = Node {rs=LEX, pf=pf', cat=cat', sem=sem', daughters=[], score=(score' % 100), source=source', sig=sig'}

{- Some Marcos for CCG categories/features -}

-- | Category S with the default feature setting
defS :: [FeatureValue] -> [FeatureValue] -> Cat
defS p c = S [F p,
              F c,
              F [M],
              F [M],
              F [M],
              F [M],
              F [M]
             ]

--catS :: [FeatureValue] -> [FeatureValue] -> Feature -> Feature -> Feature -> Feature -> Feature -> Cat
--catS pos conj pm1 pm2 pm3 pm4 pm5 = S [F pos, F conj, pm1, pm2, pm3, pm4, pm5]

verb :: [FeatureValue]
verb = [V5k, V5s, V5t, V5n, V5m, V5r, V5w, V5g, V5z, V5b, V5IKU, V5YUK, V5ARU, V5NAS, V5TOW, V1, VK, VS, VSN, VZ, VURU]

adjective :: [FeatureValue]
adjective = [Aauo, Ai, ANAS, ATII, ABES]

nomPred :: [FeatureValue]
nomPred = [Nda, Nna, Nno, Nni, Nemp, Ntar]

anyPos :: [FeatureValue]
anyPos = verb ++ adjective ++ nomPred ++ [Exp]

nonStem :: [FeatureValue]
nonStem = [Neg, Cont, Term, Attr, Hyp, Imper, Pre, ModU, ModS, VoR, VoS, VoE, NegL, TeForm]

anySExStem :: Cat
anySExStem = S [SF 2 anyPos, SF 3 nonStem, SF 4 [P,M], SF 5 [P,M], SF 6 [P,M], F [M], F [M]]

m5 :: [Feature]
m5 = [F[M],F[M],F[M],F[M],F[M]]

pmmmm :: [Feature]
pmmmm = [F[P],F[M],F[M],F[M],F[M]]

mpmmm :: [Feature]
mpmmm = [F[M],F[P],F[M],F[M],F[M]]

mmpmm :: [Feature]
mmpmm = [F[M],F[M],F[P],F[M],F[M]]

mmmpm :: [Feature]
mmmpm = [F[M],F[M],F[M],F[P],F[M]]

mppmm :: [Feature]
mppmm = [F[M],F[P],F[P],F[M],F[M]]


--anyConj :: [ConjFeature]
--anyConj = [Stem, UStem, Neg, Cont, Term, Attr, Hyp, Imper, Pre, EuphT, EuphD, ModU, ModS, VoR, VoS, VoE, TeForm, NiForm, Yooni]

--anyCase :: [CaseFeature] 
--anyCase = [Nc, Ga, O, Ni, To, Niyotte, No]

{- Templates for Semantic Representation -}
-- | \x.x
id :: Preterm
id = Lam (Var 0)

-- | verbSR i op
-- i==1 -> S\NP:             \x.\c.(e:event)Xop(e,x)X(ce)
-- i==2 -> S\NP\NP:       \y.\x.\c.(e:event)X(op(e,x,y)X(ce)
-- i==3 -> S\NP\NP\NP: \z.\y.\x.\c.(e:event)X(op(e,x,y,z)X(ce)
-- i==4 -> error

verbSR :: Int -> T.Text -> (Preterm,[Signature])
verbSR i op | i == 1 = ((Lam (Lam (Sigma (Con "event") (Sigma (App (App (Con op) (Var 2)) (Var 0)) (App (Var 2) (Var 1)))))), [(op, nPlaceEventType 1)])
            | i == 2 = ((Lam (Lam (Lam (Sigma (Con "event") (Sigma (App (App (App (Con op) (Var 3)) (Var 2)) (Var 0)) (App (Var 2) (Var 1))))))), [(op, nPlaceEventType 2)])
            | i == 3 = ((Lam (Lam (Lam (Lam (Sigma (Con "event") (Sigma (App (App (App (App (Con op) (Var 4)) (Var 3)) (Var 2)) (Var 0)) (App (Var 2) (Var 1)))))))), [(op, nPlaceEventType 3)])
            | otherwise = (Con $ T.concat ["verbSR: verb ",op," of ", T.pack (show i), " arguments"], [])

nPlaceEventType :: Int -> Preterm
nPlaceEventType i
  | i < 0 = Con $ T.concat ["nPlaceEvent with: ", T.pack (show i)]
  | i == 0 = Pi (Con "event") Type
  | otherwise = Pi (Con "entity") (nPlaceEventType (i-1))

nPlaceStateType :: Int -> Preterm
nPlaceStateType i
  | i < 0 = Con $ T.concat ["nPlaceState with: ", T.pack (show i)]
  | i == 0 = Pi (Con "state") Type
  | otherwise = Pi (Con "entity") (nPlaceStateType (i-1))

nPlacePredType :: Int -> Preterm
nPlacePredType i
  | i < 0 = Con $ T.concat ["nPlacePred with: ", T.pack (show i)]
  | i == 0 = Type
  | otherwise = Pi (Con "entity") (nPlaceStateType (i-1))

-- | S\NP: \x.\c.(s:state)Xop(s,x)X(ce)
predSR :: Int -> T.Text -> (Preterm,[Signature])
predSR i op | i == 1 = ((Lam (Lam (Sigma (Con "state") (Sigma (App (App (Con op) (Var 2)) (Var 0)) (App (Var 2) (Var 1)))))), [(op, nPlacePredType 1)])
            | i == 2 = ((Lam (Lam (Lam (Sigma (Con "state") (Sigma (App (App (App (Con op) (Var 3)) (Var 2)) (Var 0)) (App (Var 2) (Var 1))))))), [(op, nPlacePredType 2)])
            | otherwise = ((Con $ T.concat ["predSR: pred ",op," of ", T.pack (show i), " arguments"]), [])

-- | NP: 
properNameSR :: T.Text -> (Preterm, [Signature])
properNameSR op = ((Lam (App (Var 0) (Con op))), [(op, (Con "entity"))])

-- | N: 
commonNounSR :: T.Text -> (Preterm, [Signature])
commonNounSR op = ((Lam (Lam (Sigma (Con "state") (Sigma (App (App (Con op) (Var 2)) (Var 0)) (App (Var 2) (Var 1)))))), [(op, nPlacePredType 1)])

-- | S\S, S/S: \p.\c.op (pc)
modalSR :: T.Text -> (Preterm,[Signature])
modalSR op = ((Lam (Lam (App (Con op) (App (Var 1) (Var 0))))), [(op, Pi Type Type)])

-- | 
-- >>> S\NP\(S\NP):    \p.\x.\c.op(x,\z.(pz)c)
-- >>> S\NP\NP\(S\NP): \p.\y.\x.\c.op(x,\z.((py)z)c)
intensionalEvent :: Int -> T.Text -> (Preterm,[Signature])
intensionalEvent i op | i == 1 = ((Lam (Lam (Lam (Sigma (Con "event") (Sigma (App (App (App (Con op) (Lam (App (App (Var 4) (Var 0)) (Lam Top)))) (Var 2)) (Var 0)) (App (Var 2) (Var 1))))))), [(op,sg)])
                      | i == 2 = ((Lam (Lam (Lam (Lam (App (App (Con op) (Lam (App (App (Var 4) (Var 3)) (Var 1)))) (Var 1)))))), [(op,sg)])
                      | otherwise = (Con $ T.concat ["intensionalEvent: verb ",op," of ", T.pack (show i), " arguments"],[])
  where sg = Pi (Pi (Con "entity") Type) (Pi (Con "entity") (Pi (Con "event") Type))

intensionalState :: Int -> T.Text -> (Preterm,[Signature])
intensionalState i op | i == 1 = ((Lam (Lam (Lam (Sigma (Con "state") (Sigma (App (App (App (Con op) (Lam (App (App (Var 4) (Var 0)) (Lam Top)))) (Var 2)) (Var 0)) (App (Var 2) (Var 1))))))), [(op,sg)])
                      | i == 2 = ((Lam (Lam (Lam (Lam (App (App (Con op) (Lam (App (App (Var 4) (Var 3)) (Var 1)))) (Var 1)))))), [(op,sg)])
                      | otherwise = (Con $ T.concat ["intensionalState: verb ",op," of ", T.pack (show i), " arguments"], [])
  where sg = Pi (Pi (Con "entity") Type) (Pi (Con "entity") (Pi (Con "state") Type))

-- | T/T: \p.\v.\c.pv(\e.(op e) X ce)
mannerAdverb :: T.Text -> (Preterm, [Signature])
mannerAdverb op = ((Lam (Lamvec (Lam (App (Appvec 1 (Var 2)) (Lam (Sigma (App (Con op) (Var 0)) (App (Var 3) (Var 0)))))))), [(op, Pi (Con "entity") Type)])

-- | S\S: \p.\c.p(\e.(op e) X ce)
eventModifier :: T.Text -> (Preterm, [Signature])
eventModifier op = ((Lam (Lam (App (Var 1) (Lam (Sigma (App (Con op) (Var 0)) (App (Var 2) (Var 1))))))), [(op, Pi (Con "event") Type)])

-- | S\S: \p.\c.not (pc)
negOperator :: (Preterm, [Signature])
negOperator = ((Lam (Lam (Not (App (Var 1) (Var 0))))), [])

-- | T/(T\NP[cm])\NP[nc]: \x.\p.px
argumentCM :: (Preterm, [Signature])
argumentCM = ((Lam (Lam (App (Var 0) (Var 1)))), [])

-- | T/T\NP[nc]: \x.\p.\v.\c.p (\e.op(e,x) X ce)
adjunctCM :: T.Text -> (Preterm, [Signature])
adjunctCM c = ((Lam (Lam (Lam (App (Var 1) (Lam (Sigma (App (App (Con c) (Var 3)) (Var 0)) (App (Var 2) (Var 1)))))))), [(c, nPlaceEventType 1)])

andSR :: (Preterm, [Signature])
andSR = ((Lam (Lam (Sigma (Var 1) (Var 1)))), [])

orSR :: (Preterm, [Signature])
orSR = ((Lam (Lam (Pi (Not (Var 1)) (Var 1)))), [])