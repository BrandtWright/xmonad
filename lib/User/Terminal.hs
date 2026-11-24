module User.Terminal
    ( terminalName
    , floatingTitle
    , launchTerm
    , launchTUI
    , launchFloatingTUI
    ) where

import Data.Maybe (catMaybes)
import XMonad (X, spawn)

terminalName :: String
terminalName = "st"

-- | Title matched by manage hook for floating terminals
floatingTitle :: String
floatingTitle = "Terminal Quick Picker"

-- | Configuration for building terminal commands
data TermConfig = TermConfig
    { termTitle :: Maybe String -- -t flag (also used for manage hook matching)
    , termGeom :: Maybe String -- -g flag (geometry, e.g. "120x40")
    , termExec :: Maybe String -- -e command (Nothing = no -e flag)
    }

defaultTerm :: TermConfig
defaultTerm = TermConfig Nothing Nothing Nothing

-- | Build a terminal command string from config
buildTermCmd :: TermConfig -> String
buildTermCmd cfg =
    unwords $
        catMaybes
            [ Just terminalName
            , ("-t '" ++) . (++ "'") <$> termTitle cfg -- wrap title in shell quotes
            , ("-g " ++) <$> termGeom cfg
            , ("-e " ++) <$> termExec cfg
            ]

launchTerm :: X ()
launchTerm =
    spawn $
        buildTermCmd
            defaultTerm
                { termExec = Nothing
                , termTitle = Just "Terminal"
                , termGeom = Nothing
                }

launchTUI :: String -> Maybe String -> Maybe String -> X ()
launchTUI command title geometry =
    spawn $
        buildTermCmd
            defaultTerm
                { termExec = Just command
                , termTitle = title
                , termGeom = geometry
                }

launchFloatingTUI :: String -> String -> X ()
launchFloatingTUI command geometry =
    spawn $
        buildTermCmd
            defaultTerm
                { termExec = Just command
                , termTitle = Just floatingTitle
                , termGeom = Just geometry
                }
