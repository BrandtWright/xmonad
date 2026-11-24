module User.Workspaces where

import Data.Functor
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.ManageDocks (ToggleStruts (..))
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Spacing
import XMonad.StackSet qualified as W
import XMonad.Util.NamedScratchpad

-- Workspace Names
wsSystem, wsWeb, wsAi, wsOffice, wsPhone :: String
wsNews, wsRss, wsSocial, wsGraphics :: String
wsVideo, wsMusic, wsWork, wsMisc :: String
-- Main
wsSystem = "System"
wsWeb = "Web"
wsAi = "AI"
-- Util
wsOffice = "Office"
wsPhone = "Phone"
wsGraphics = "Graphics"

-- Read, view, listen
wsNews = "News"
wsRss = "RSS"
wsVideo = "Video"
wsMusic = "Music"
wsSocial = "Social"

-- Context
wsFinance = "Finance"
wsWork = "Work"
wsMisc = "Misc"

-- Helper to create WSType from workspace name
wsType :: String -> WSType
wsType name = WSIs (return (\ws -> W.tag ws == name))

-- All workspaces
myWorkspaces :: [String]
myWorkspaces =
    [ wsSystem
    , wsWeb
    , wsAi
    , wsOffice
    , wsPhone
    , wsGraphics
    , wsNews
    , wsRss
    , wsVideo
    , wsMusic
    , wsFinance
    , wsSocial
    , wsWork
    , wsMisc
    ]

-- Current Layout
currentLayout :: X String
currentLayout =
    gets windowset
        Data.Functor.<&> (description . W.layout . W.workspace . W.current)

myScratchpads :: [NamedScratchpad]
myScratchpads =
    [ NS
        "matrix"
        "st -e unimatrix -s 96"
        (title =? "What is the Matrix?")
        defaultFloating
    , NS
        "htop"
        "st -e htop"
        (title =? "htop")
        ( customFloating $
            W.RationalRect (1 / 4) (1 / 4) (1 / 2) (1 / 2)
        )
    , NS
        "gotop"
        "st -e gotop"
        (title =? "gotop")
        ( customFloating $
            W.RationalRect (1 / 4) (1 / 4) (1 / 2) (1 / 2)
        )
    , NS
        "terminal"
        "st"
        (title =? "st")
        ( customFloating $
            W.RationalRect (1 / 4) (1 / 4) (1 / 2) (1 / 2)
        )
    ]

-- Spawn a given application on a given workspace
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
    spawn program
    windows $ W.greedyView workspace

-- Workspace Actions

prevWorkspace :: X ()
prevWorkspace = moveTo Prev wsFilter

nextWorkspace :: X ()
nextWorkspace = moveTo Next wsFilter

wsFilter :: WSType
wsFilter = ignoringWSs [scratchpadWorkspaceTag]

nextLayout :: X ()
nextLayout = sendMessage NextLayout

toggleFullScreen :: X ()
toggleFullScreen = sendMessage $ Toggle FULL

toggleTrueFullScreen :: X ()
toggleTrueFullScreen = do
    sendMessage $ Toggle FULL -- Toggle full layout
    sendMessage $ Toggle NOBORDERS -- Toggle borders
    sendMessage ToggleStruts -- Toggle xmobar visibility
    toggleScreenSpacingEnabled -- Toggle screen padding
    toggleWindowSpacingEnabled -- Toggle window padding

refreshWorkspace :: X ()
refreshWorkspace = refresh

incrementWindowSpacing :: X ()
incrementWindowSpacing = incWindowSpacing 1

decrementWindowSpacing :: X ()
decrementWindowSpacing = decWindowSpacing 1

incrementScreenSpacing :: X ()
incrementScreenSpacing = incScreenSpacing 1

decrementScreenSpacing :: X ()
decrementScreenSpacing = decScreenSpacing 1

moveToNextEmptyWorkspace :: X ()
moveToNextEmptyWorkspace = moveTo Next emptyWS

-- | Send the focused window to a workspace and follow it
pullWindowToWorkspace :: String -> X ()
pullWindowToWorkspace ws = shiftTo Next (wsType ws) >> moveTo Next (wsType ws)

-- | Send the focused window to a workspace without following
pushWindowToWorkspace :: String -> X ()
pushWindowToWorkspace ws = shiftTo Next (wsType ws)

shrinkMasterPane :: X ()
shrinkMasterPane = sendMessage Shrink

expandMasterPane :: X ()
expandMasterPane = sendMessage Expand

incrementMasterPane :: X ()
incrementMasterPane = sendMessage (IncMasterN 1)

decrementMasterPane :: X ()
decrementMasterPane = sendMessage (IncMasterN (-1))

-- Scratchpad Actions

scratchPadHtop :: X ()
scratchPadHtop = namedScratchpadAction myScratchpads "htop"

scratchPadGotop :: X ()
scratchPadGotop = namedScratchpadAction myScratchpads "gotop"

scratchPadTerminal :: X ()
scratchPadTerminal = namedScratchpadAction myScratchpads "terminal"
