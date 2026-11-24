module User.Spawn (
    safeSpawn,
) where

import Control.Monad.IO.Class (liftIO)
import System.Directory (findExecutable)
import XMonad (X, spawn)

{- | Spawn a command, but check if the executable exists first.
If missing, display a notification instead of failing silently.
-}
safeSpawn :: String -> X ()
safeSpawn cmd = do
    let executable = takeWhile (/= ' ') cmd
    exists <- liftIO $ findExecutable executable
    case exists of
        Just _ -> spawn cmd
        Nothing -> spawn $ "notify-send -u critical -t 5000 'Command not found: " ++ executable ++ "'"
