-- | Function and implementation to find association files for an
-- identified test root file.

{-# LANGUAGE LambdaCase #-}

module Test.Tasty.Sugar.AssocCheck
  (
    getAssoc
  )
  where

import           Control.Monad.Logic
import qualified Data.List as L
import           Data.Maybe ( catMaybes )

import           Test.Tasty.Sugar.ParamCheck
import           Test.Tasty.Sugar.Types


-- | For a specific NamedParamMatch, find all associated files having
-- the rootMatch plus the named parameter values (in the same order
-- but with any combination of separators) and the specified suffix
-- match.
getAssoc :: CandidateFile
         -> Separators
         -> [NamedParamMatch]
         -> [ (String, FileSuffix) ]
         -> [CandidateFile]
         -> Logic [(String, CandidateFile)]
getAssoc rootPrefix seps pmatch assocNames allNames = assocSet
  where
    assocSet = concat <$> mapM fndBestAssoc assocNames

    fndBestAssoc :: (String, FileSuffix)
                 -> Logic [(String, CandidateFile)] -- usually just one
    fndBestAssoc assoc =
      do let candidates = L.nub $ catMaybes $
                          observeAll (fndAnAssoc assoc)
         let highestRank = maximum (fst <$> candidates)
             c = filter ((== highestRank) . fst) candidates
         if null candidates
           then return []
           else return (snd <$> c)

    fndAnAssoc :: (String, FileSuffix)
               -> Logic (Maybe (Int, (String, CandidateFile)))
    fndAnAssoc assoc = ifte (fndAssoc assoc)
                       (return . Just)
                       (return Nothing)

    fndAssoc :: (String, FileSuffix) -> Logic (Int, (String, CandidateFile))
    fndAssoc assoc =
      do pseq <- npseq pmatch
         (rank, assocPfx, assocSfx) <- sepParams seps (fmap snd pseq)
         let possible =
               if null assocSfx
               then let justSep = null (snd assoc) && length assocPfx == 1
                        rootNm = candidateFile rootPrefix
                        assocFName = if justSep
                                     then rootNm
                                     else rootNm <> assocPfx <> (snd assoc)
                    in (assocFName ==)
               else let assocStart = candidateFile rootPrefix <> assocPfx
                        assocEnd = assocSfx <> snd assoc
                        aSL = length assocStart
                        aEL = length assocEnd
                        chk f =
                          and [ assocStart `L.isPrefixOf` f
                              , assocEnd `L.isSuffixOf` f
                              , length f > (aSL + aEL)
                              , let mid = drop aSL (take (length f - aEL) f)
                                in and $ fmap (not . flip elem mid) seps
                              ]
                    in chk
         f <- eachFrom $ filter (possible . candidateFile) allNames
         return (rank, (fst assoc, f))

    sepParams :: Separators -> [ParamMatch] -> Logic (Int, String, String)
    sepParams sl =
      let rank (n,_,_) = n
          pfx (_,l,_) = l
      in \case
        [] -> if null sl
              then return (0, [], [])
              else do s <- eachFrom sl
                      return (0, [s], [])
        (NotSpecified:ps) -> do r <- sepParams sl ps
                                return (rank r, [], pfx r)
        ((Explicit v):ps) -> do (n,l,r) <- sepParams sl ps
                                if null sl
                                  then return (n+1, v <> l, r)
                                  else do s <- eachFrom sl
                                          return (n+1, [s] <> v <> l, r)
        ((Assumed  v):ps) -> do (n,l,r) <- sepParams sl ps
                                if null sl
                                  then return (n+1, v <> l, r)
                                  else do s <- eachFrom sl
                                          return (n+1, [s] <> v <> l, r)

    npseq = eachFrom
            . ([]:)                -- consider no parameters just once
            . filter (not . null)  -- excluding multiple blanks in
            . concatMap L.inits    -- any number of the
            . L.permutations       -- parameters in each possible order
