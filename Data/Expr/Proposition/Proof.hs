module Data.Expr.Proposition.Proof where

import           Data.Expr.Proposition.Constr
import           Data.Expr.Proposition.Eval
import           Data.Expr.Proposition.Substitute
import           Data.Expr.Proposition.Types
import           Data.Pretty

import           Data.List                        (intercalate)
import           Data.Maybe                       (listToMaybe)

-- ----------------------------------------

truthTable :: Int -> [[Bool]]
truthTable 0 = [[]]
truthTable n = map (True:) t' ++ map (False:) t'
  where t' = truthTable (n - 1)
        
-- compute a proof by generating a truth table,
-- iterate over all rows in the table
-- and substitute all variable by the values in a row
-- and evaluate the expression
-- if a single result is false
-- we have a counter example, else the expr
-- is a tautology

proof' :: Expr -> Maybe VarEnv
proof' e
  = (listToMaybe . foldr evalEnv []) envs
  where
    varNames  = freeVars e
    fullTable = map (map Lit) $ truthTable $ length varNames
    envs      = map (zip varNames) fullTable
    evalEnv env falseEnvs
      | eval $ substVars env e = falseEnvs
      | otherwise = env:falseEnvs

proof :: Expr -> String
proof e
  = case proof' e of
     Nothing
       -> pretty e ++ " is a tautology"
     Just env
       -> pretty e ++ " isn't a tautology, " ++
          "a counter example is " ++ ppEnv env
  where
    ppEnv = intercalate ", " . map ppVar
    ppVar (i, v) = i ++ "=" ++ pretty v

-- ----------------------------------------
