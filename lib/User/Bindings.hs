module User.Bindings (
    Binding (..),
    allBindings,
    toXMonadKeys,
    toTreeNodes,
) where

import Data.List (partition)
import Data.Map qualified as M
import Data.Tree (Tree (..))
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Types
import XMonad
import XMonad.Actions.CycleWS (toggleOrView)
import XMonad.Actions.Submap (submap)
import XMonad.Actions.TreeSelect qualified as TS
import XMonad.Util.Dmenu (menuMapArgs)

import User.Apps
import User.Bookmarks
import User.Dotfiles
import User.Git
import User.Hardware
import User.Search
import User.Session
import User.Tasks
import User.Terminal
import User.Utilities
import User.Windows
import User.Workspaces

--------------------------------------------------------------------------------
-- Modifier Key Shortcuts
--------------------------------------------------------------------------------

super :: KeyMask
super = mod4Mask

controlSuper :: KeyMask
controlSuper = mod4Mask .|. controlMask

shiftSuper :: KeyMask
shiftSuper = mod4Mask .|. shiftMask

controlShiftSuper :: KeyMask
controlShiftSuper = mod4Mask .|. controlMask .|. shiftMask

--------------------------------------------------------------------------------
-- Binding Data Type
--------------------------------------------------------------------------------

-- | A keybinding can be a direct action or a group (submap/tree node)
data Binding
    = Action
        { bMask :: KeyMask
        -- ^ Modifier keys (0 for none, kmM, kmCM, etc.)
        , bKey :: KeySym
        -- ^ Key symbol (xK_h, xK_Return, etc.)
        , bDesc :: String
        -- ^ Description: "Previous Workspace"
        , bHint :: String
        -- ^ TreeSelect hint shown on right: "M-H"
        , bAction :: X ()
        -- ^ The actual action to execute
        }
    | Group
        { bMask :: KeyMask
        -- ^ Modifier for submap prefix (0 for tree-only groups)
        , bKey :: KeySym
        -- ^ Key for submap prefix (0 for tree-only groups)
        , bDesc :: String
        -- ^ Group name: "XMonad Commands"
        , bChildren :: [Binding]
        -- ^ Child bindings
        }

--------------------------------------------------------------------------------
-- All Keybindings
--------------------------------------------------------------------------------

{- | All keybindings in a single inline structure.
This structure defines BOTH the XMonad keybindings AND the TreeSelect menu.
-}
allBindings :: [Binding]
allBindings =
    -- Convenience Keys (top-level, no submap prefix)
    [ Group
        0
        0
        "Convenience Keys"
        [ Group
            0
            0
            "Mod"
            [ Action super xK_h "Previous Workspace" "M-H" prevWorkspace
            , Action super xK_l "Next Workspace" "M-L" nextWorkspace
            , Action super xK_j "Focus Next Window" "M-J" focusNextWindow
            , Action super xK_k "Focus Previous Window" "M-K" focusPrevWindow
            , Action super xK_c "Close Window" "M-C" closeWindow
            , Action super xK_f "Toggle Full Screen" "M-F" toggleFullScreen
            , Action super xK_space "Next Layout" "M-Space" nextLayout
            , Action super xK_v "Refresh Workspace" "M-V" refreshWorkspace
            , Action super xK_equal "Increase Window Spacing" "M-=" incrementWindowSpacing
            , Action super xK_minus "Decrease Window Spacing" "M--" decrementWindowSpacing
            , Action super xK_Return "Open Terminal" "M-Return" launchTerm
            , Action super xK_d "Open Scratch Pad" "M-D" openScratchPad
            , Action super xK_p "Dmenu Run" "M-P" dmenuRun
            , Action super xK_slash "Scratch Pad Terminal" "M-/" scratchPadTerminal
            , Action super xK_F1 "Restart Picom" "M-F1" restartPicom
            , Group
                super
                xK_i
                "Go to Workspace"
                [ Action 0 xK_s "System" "M-I, S" (toggleOrView wsSystem)
                , Action 0 xK_w "Web" "M-I, W" (toggleOrView wsWeb)
                , Action 0 xK_a "AI" "M-I, A" (toggleOrView wsAi)
                , Action 0 xK_o "Office" "M-I, O" (toggleOrView wsOffice)
                , Action 0 xK_e "Phone" "M-I, E" (toggleOrView wsPhone)
                , Action 0 xK_n "News" "M-I, N" (toggleOrView wsNews)
                , Action 0 xK_r "RSS" "M-I, R" (toggleOrView wsRss)
                , Action 0 xK_i "Social" "M-I, I" (toggleOrView wsSocial)
                , Action 0 xK_g "Graphics" "M-I, G" (toggleOrView wsGraphics)
                , Action 0 xK_v "Video" "M-I, V" (toggleOrView wsVideo)
                , Action 0 xK_m "Music" "M-I, M" (toggleOrView wsMusic)
                , Action 0 xK_f "Finance" "M-I, F" (toggleOrView wsFinance)
                , Action 0 xK_k "Work" "M-I, K" (toggleOrView wsWork)
                , Action 0 xK_c "Misc" "M-I, C" (toggleOrView wsMisc)
                , Action 0 xK_y "Next Empty" "M-I, Y" moveToNextEmptyWorkspace
                ]
            ]
        , Group
            0
            0
            "Mod+Ctrl"
            [ Action controlSuper xK_h "Window to Prev Workspace" "MC-H" windowToPrevWorkspace
            , Action controlSuper xK_j "Swap Window Down" "MC-J" swapWindowDown
            , Action controlSuper xK_k "Swap Window Up" "MC-K" swapWindowUp
            , Action controlSuper xK_l "Window to Next Workspace" "MC-L" windowToNextWorkspace
            , Action controlSuper xK_p "Rotate Windows Down" "MC-P" rotateWindowsDown
            , Action controlSuper xK_n "Rotate Windows Up" "MC-N" rotateWindowsUp
            , Action controlSuper xK_comma "Increase Master Panes" "MC-," incrementMasterPane
            , Action controlSuper xK_period "Decrease Master Panes" "MC-." decrementMasterPane
            , Action controlSuper xK_a "Copy Window to All" "MC-A" copyWindowToAllWorkspaces
            , Action controlSuper xK_c "Kill Other Copies" "MC-C" killOtherWindowCopies
            , Action controlSuper xK_t "Push to Tiling" "MC-T" pushWindowToTilingMode
            , Action controlSuper xK_d "Open Work Scratch Pad" "MC-D" openWorkScratchPad
            , Action controlSuper xK_semicolon "View Keybinds" "MC-;" viewKeyBinds
            ]
        , Group
            0
            0
            "Mod+Shift"
            [ Action shiftSuper xK_j "Shrink Window" "MS-J" shrinkWindow
            , Action shiftSuper xK_k "Expand Window" "MS-K" expandWindow
            , Action shiftSuper xK_h "Shrink Master Pane" "MS-H" shrinkMasterPane
            , Action shiftSuper xK_l "Expand Master Pane" "MS-L" expandMasterPane
            , Action shiftSuper xK_f "True Full Screen" "MS-F" toggleTrueFullScreen
            , Action shiftSuper xK_m "Open App Menu" "MS-M" openAppMenu
            , Action shiftSuper xK_Return "Open Tmux Delux" "MS-Return" (spawn "st tmux-delux")
            , Action shiftSuper xK_slash "Open Floating Terminal" "MS-/" launchTerm
            , Action shiftSuper xK_semicolon "Search Keybinds" "MS-;" searchKeyBinds
            ]
        , Group
            0
            0
            "Mod+Ctrl+Shift"
            [ Action controlShiftSuper xK_equal "Increase Screen Spacing" "MCS-=" incrementScreenSpacing
            , Action controlShiftSuper xK_minus "Decrease Screen Spacing" "MCS--" decrementScreenSpacing
            ]
        , Group
            0
            0
            "Media Keys"
            [ Action 0 xF86XK_AudioRaiseVolume "Increase Volume" "AudioRaise" increaseVolume
            , Action 0 xF86XK_AudioLowerVolume "Decrease Volume" "AudioLower" decreaseVolume
            , Action 0 xF86XK_AudioMute "Toggle Mute" "AudioMute" toggleVolume
            , Action 0 xF86XK_MonBrightnessUp "Increase Brightness" "BrightUp" increaseBrightness
            , Action 0 xF86XK_MonBrightnessDown "Decrease Brightness" "BrightDown" decreaseBrightness
            ]
        ]
    , -- XMonad Commands (M-q prefix)
      Group
        super
        xK_q
        "XMonad"
        [ Action 0 xK_c "Recompile" "M-Q, C" recompileXmonad
        , Action 0 xK_r "Restart" "M-Q, R" restartXmonad
        , Action 0 xK_k "Lock Screen" "M-Q, K" lockScreen
        , Action 0 xK_p "Restart Picom" "M-Q, P" restartPicom
        , Group
            0
            xK_b
            "Key Binds"
            [ Action 0 xK_v "View Key Binds" "M-Q, B, V" viewKeyBinds
            , Action 0 xK_s "Search Key Binds" "M-Q, B, S" searchKeyBinds
            ]
        ]
    , -- Workspace Commands (M-w and M-i prefixes)
      Group
        super
        xK_w
        "Workspace"
        [ Action 0 xK_h "Previous Workspace" "M-W, H" prevWorkspace
        , Action 0 xK_l "Next Workspace" "M-W, L" nextWorkspace
        , Action 0 xK_space "Next Layout" "M-W, Space" nextLayout
        , Action 0 xK_f "Toggle Full Screen" "M-W, F" toggleFullScreen
        , Action 0 xK_u "True Full Screen" "M-W, U" toggleTrueFullScreen
        , Action shiftMask xK_f "True Full Screen" "M-W, S-F" toggleTrueFullScreen
        , Action 0 xK_v "Refresh Workspace" "M-W, V" refreshWorkspace
        , Action 0 xK_equal "Increase Window Spacing" "M-W, =" incrementWindowSpacing
        , Action 0 xK_minus "Decrease Window Spacing" "M-W, -" decrementWindowSpacing
        , Action controlMask xK_equal "Increase Screen Spacing" "M-W, C-=" incrementScreenSpacing
        , Action controlMask xK_minus "Decrease Screen Spacing" "M-W, C--" decrementScreenSpacing
        , Group
            super
            xK_i
            "Go to Workspace"
            [ Action 0 xK_s "System" "M-W, I, S" (toggleOrView wsSystem)
            , Action 0 xK_w "Web" "M-W, I, W" (toggleOrView wsWeb)
            , Action 0 xK_a "AI" "M-W, I, A" (toggleOrView wsAi)
            , Action 0 xK_o "Office" "M-W, I, O" (toggleOrView wsOffice)
            , Action 0 xK_e "Phone" "M-W, I, E" (toggleOrView wsPhone)
            , Action 0 xK_n "News" "M-W, I, N" (toggleOrView wsNews)
            , Action 0 xK_r "RSS" "M-W, I, R" (toggleOrView wsRss)
            , Action 0 xK_i "Social" "M-W, I, I" (toggleOrView wsSocial)
            , Action 0 xK_g "Graphics" "M-W, I, G" (toggleOrView wsGraphics)
            , Action 0 xK_v "Video" "M-W, I, V" (toggleOrView wsVideo)
            , Action 0 xK_m "Music" "M-W, I, M" (toggleOrView wsMusic)
            , Action 0 xK_f "Finance" "M-W, I, F" (toggleOrView wsFinance)
            , Action 0 xK_k "Work" "M-W, I, K" (toggleOrView wsWork)
            , Action 0 xK_c "Misc" "M-W, I, C" (toggleOrView wsMisc)
            , Action 0 xK_y "Next Empty" "M-W, I, Y" moveToNextEmptyWorkspace
            ]
        ]
    , -- Window Commands (M-n prefix)
      Group
        super
        xK_n
        "Window"
        [ Action 0 xK_g "Goto Window" "M-N, G" gotoWindow
        , Action 0 xK_b "Find Window and Bring to Workspace" "M-N, B" bringWindow
        , Action 0 xK_s "Find Window and Send to Workspace" "M-N, S" sendWindow
        , Action 0 xK_j "Focus Next" "M-N, J" focusNextWindow
        , Action 0 xK_k "Focus Previous" "M-N, K" focusPrevWindow
        , Action 0 xK_c "Close" "M-N, C" closeWindow
        , Action 0 xK_comma "Increase Master Panes" "M-N, ," incrementMasterPane
        , Action 0 xK_period "Decrease Master Panes" "M-N, ." decrementMasterPane
        , Action 0 xK_a "Copy to All Workspaces" "M-N, A" copyWindowToAllWorkspaces
        , Action 0 xK_t "Push to Tiling" "M-N, T" pushWindowToTilingMode
        , Action 0 xK_m "Move to Master" "M-N, M" windowToMasterPane
        , Action controlSuper xK_k "Swap Up" "M-N, MC-K" swapWindowUp
        , Action controlSuper xK_j "Swap Down" "M-N, MC-J" swapWindowDown
        , Action controlSuper xK_l "To Next Workspace" "M-N, MC-L" windowToNextWorkspace
        , Action controlSuper xK_h "To Prev Workspace" "M-N, MC-H" windowToPrevWorkspace
        , Action shiftSuper xK_j "Shrink" "M-N, MS-J" shrinkWindow
        , Action shiftSuper xK_k "Expand" "M-N, MS-K" expandWindow
        , Action shiftSuper xK_h "Shrink Master" "M-N, MS-H" shrinkMasterPane
        , Action shiftSuper xK_l "Expand Master" "M-N, MS-L" expandMasterPane
        , Action super xK_p "Rotate Down" "M-N, MC-P" rotateWindowsDown
        , Action controlSuper xK_n "Rotate Up" "M-N, MC-N" rotateWindowsUp
        , Action shiftMask xK_a "Kill Other Copies" "M-N, S-A" killOtherWindowCopies
        , Group
            0
            xK_u
            "Pull to Workspace"
            [ Action 0 xK_s "System" "M-N, U, S" (pullWindowToWorkspace wsSystem)
            , Action 0 xK_w "Web" "M-N, U, W" (pullWindowToWorkspace wsWeb)
            , Action 0 xK_a "AI" "M-N, U, A" (pullWindowToWorkspace wsAi)
            , Action 0 xK_o "Office" "M-N, U, O" (pullWindowToWorkspace wsOffice)
            , Action 0 xK_e "Phone" "M-N, U, E" (pullWindowToWorkspace wsPhone)
            , Action 0 xK_n "News" "M-N, U, N" (pullWindowToWorkspace wsNews)
            , Action 0 xK_r "RSS" "M-N, U, R" (pullWindowToWorkspace wsRss)
            , Action 0 xK_i "Social" "M-N, U, I" (pullWindowToWorkspace wsSocial)
            , Action 0 xK_g "Graphics" "M-N, U, G" (pullWindowToWorkspace wsGraphics)
            , Action 0 xK_v "Video" "M-N, U, V" (pullWindowToWorkspace wsVideo)
            , Action 0 xK_m "Music" "M-N, U, M" (pullWindowToWorkspace wsMusic)
            , Action 0 xK_f "Finance" "M-N, U, F" (pullWindowToWorkspace wsFinance)
            , Action 0 xK_k "Work" "M-N, U, K" (pullWindowToWorkspace wsWork)
            , Action 0 xK_c "Misc" "M-N, U, C" (pullWindowToWorkspace wsMisc)
            ]
        , Group
            0
            xK_p
            "Send to Workspace"
            [ Action 0 xK_s "System" "M-N, P, S" (pushWindowToWorkspace wsSystem)
            , Action 0 xK_w "Web" "M-N, P, W" (pushWindowToWorkspace wsWeb)
            , Action 0 xK_a "AI" "M-N, P, A" (pushWindowToWorkspace wsAi)
            , Action 0 xK_o "Office" "M-N, P, O" (pushWindowToWorkspace wsOffice)
            , Action 0 xK_m "Phone" "M-N, P, E" (pushWindowToWorkspace wsPhone)
            , Action 0 xK_n "News" "M-N, P, N" (pushWindowToWorkspace wsNews)
            , Action 0 xK_r "RSS" "M-N, P, R" (pushWindowToWorkspace wsRss)
            , Action 0 xK_i "Social" "M-N, P, I" (pushWindowToWorkspace wsSocial)
            , Action 0 xK_g "Graphics" "M-N, P, G" (pushWindowToWorkspace wsGraphics)
            , Action 0 xK_v "Video" "M-N, P, V" (pushWindowToWorkspace wsVideo)
            , Action 0 xK_m "Music" "M-N, P, M" (pushWindowToWorkspace wsMusic)
            , Action 0 xK_f "Finance" "M-N, P, F" (pushWindowToWorkspace wsFinance)
            , Action 0 xK_k "Work" "M-N, P, K" (pushWindowToWorkspace wsWork)
            , Action 0 xK_c "Misc" "M-N, P, C" (pushWindowToWorkspace wsMisc)
            ]
        ]
    , -- Dotfiles (M-. prefix)
      Group
        super
        xK_period
        "Dotfiles"
        [ Action 0 xK_b "Stage Dotfiles" "M-., B" stageDotfiles
        , Action 0 xK_c "Edit Dotfiles" "M-., C" editDotfiles
        , Action 0 xK_s "Edit Scripts" "M-., S" editScripts
        ]
    , -- Applications (M-o prefix)
      Group
        super
        xK_o
        "Applications"
        [ Group
            0
            xK_o
            "Office"
            [ Action 0 xK_c "Calc" "M-O, O, C" openLoCalc
            , Action 0 xK_w "Writer" "M-O, O, W" openLoWriter
            , Action 0 xK_b "Base" "M-O, O, B" openLoBase
            , Action 0 xK_p "Impress" "M-O, O, P" openLoImpress
            , Action 0 xK_d "Draw" "M-O, O, D" openLoDraw
            ]
        , Group
            0
            xK_b
            "Browsers"
            [ Action 0 xK_b "Brave" "M-O, B, B" openBrowser
            , Action 0 xK_v "Vivaldi" "M-O, B, V" openVivaldi
            , Action 0 xK_s "Surf" "M-O, B, S" openSurf
            , Action 0 xK_l "Luakit" "M-O, B, L" openLuakit
            ]
        , Group
            0
            xK_f
            "File Explorer"
            [ Action 0 xK_n "Nautilus" "M-O, F, N" openNautilus
            , Action 0 xK_t "Thunar" "M-O, F, T" openThunar
            , Action 0 xK_p "Pcmanfm" "M-O, F, P" openPcmanfm
            , Action 0 xK_r "Ranger" "M-O, F, R" openRanger
            , Action 0 xK_f "Vifm" "M-O, F, F" openVifm
            , Action 0 xK_a "File Roller" "M-O, F, A" openFileRoller
            ]
        , Group
            0
            xK_s
            "System Monitor"
            [ Action 0 xK_h "Htop" "M-O, S, H" openHtop
            , Action 0 xK_g "Gotop" "M-O, S, G" openGotop
            , Action 0 xK_l "Glances" "M-O, S, L" openGlances
            ]
        , Group
            0
            xK_d
            "Design Tools"
            [ Action 0 xK_g "Gimp" "M-O, D, G" openGimp
            , Action 0 xK_f "Figma" "M-O, D, F" openFigma
            , Action 0 xK_b "Blender" "M-O, D, B" openBlender
            ]
        , Group
            0
            xK_m
            "Media"
            [ Action 0 xK_n "Ncmpcpp" "M-O, M, N" openNcmpcpp
            ]
        , Group
            0
            xK_w
            "Wikis"
            [ Action 0 xK_p "Personal Wiki" "M-O, W, P" openPersonalWiki
            , Action 0 xK_a "Arch Wiki" "M-O, W, A" openArchWiki
            ]
        , Action 0 xK_z "Matrix on Misc" "M-O, Z" runMatrixOnMisc
        , Action 0 xK_t "Tmux" "M-O, T" openTmux
        , Action 0 xK_n "Create Note" "M-O, N" createNote
        , Action 0 xK_r "Zathura" "M-O, R" openZathura
        , Action 0 xK_s "Scratch Pad" "M-O, S" (spawn "st sesh connect ~/data/projects/scratch")
        ]
    , -- Bookmarks (M-m prefix)
      Group
        super
        xK_m
        "Bookmarks"
        [ Action 0 xK_o "Open Web Bookmark" "M-M, O" openWebBookmark
        , Action 0 xK_n "New Web Bookmark" "M-M, N" createWebBookmark
        , Group
            0
            xK_m
            "Menu"
            [ Action 0 xK_o "Open Menu Bookmarks" "M-M, M, O" openMenuBookmarks
            ]
        , Action 0 xK_d "Directory Bookmark" "M-M, D" openDirectoryBookmark
        ]
    , -- Search (M-s prefix)
      Group
        super
        xK_s
        "Search"
        [ Group
            0
            xK_p
            "Password Store"
            [ Action 0 xK_u "Username" "M-S, P, U" findUserName
            , Action 0 xK_p "Password" "M-S, P, P" findPassword
            ]
        , Group
            0
            xK_e
            "Emojis"
            [ Action 0 xK_d "Dmenu" "M-S, E, D" dmenuEmojis
            , Action 0 xK_f "Fzf" "M-S, E, F" fzfEmojis
            ]
        , Action 0 xK_m "Man Pages" "M-S, M" dmenuMan
        , Action 0 xK_n "Notes" "M-S, N" findNote
        , Action 0 xK_c "Cht.sh" "M-S, C" searchChtSh
        , Action 0 xK_l "TLDR" "M-S, l" searchTldr
        ]
    , -- Utilities (M-u prefix)
      Group
        super
        xK_u
        "Utilities"
        [ Action 0 xK_c "Quick Calc" "M-U, C" dmenuCalculator
        , Action 0 xK_q "Qalculate" "M-U, Q" openQalculate
        , Action 0 xK_Print "Screenshot" "M-U, Print" dmenuShot
        , Action 0 xK_d "Dictionary" "M-U, D" dictLookup
        , Action 0 xK_t "Thesaurus" "M-U, T" thesaurusLookup
        ]
    , -- Git (M-, prefix)
      Group
        super
        xK_comma
        "Git"
        [ Action 0 xK_t "Tig (fzf)" "M-,, T" findRepoAndTig
        , Action 0 xK_d "Tig (dmenu)" "M-,, D" dmenuTig
        , Action 0 xK_o "Open Repo" "M-,, O" findRepoAndOpenInConsole
        ]
    , -- Scratch Pads (M-r prefix)
      Group
        super
        xK_r
        "Scratch Pads"
        [ Action 0 xK_g "Gotop" "M-R, G" scratchPadGotop
        , Action 0 xK_h "Htop" "M-R, H" scratchPadHtop
        ]
    , -- Tasks (M-t prefix)
      Group
        super
        xK_t
        "Tasks"
        [ Action 0 xK_l "List Tasks" "M-T, L" showTasks
        ]
    , -- Hardware (M-a prefix)
      Group
        super
        xK_a
        "Hardware"
        [ Group
            0
            xK_k
            "Keyboard"
            [ Action 0 xK_m "App Menu" "M-A, K, M" openAppMenu
            ]
        , Group
            0
            xK_t
            "Touchpad"
            [ Action 0 xK_t "Toggle Touchpad" "M-A, T, T" toggleTouchPad
            ]
        , Group
            0
            xK_n
            "Network"
            [ Action 0 xK_v "Toggle VPN" "M-A, N, V" toggleVpn
            ]
        , Group
            0
            xK_s
            "Sound"
            [ Action 0 xK_u "Increase Volume" "M-A, S, U" increaseVolume
            , Action 0 xK_d "Decrease Volume" "M-A, S, D" decreaseVolume
            , Action 0 xK_t "Toggle Mute" "M-A, S, T" toggleVolume
            , Action 0 xK_s "Select Sink" "M-A, S, S" selectPulseAudioSink
            , Action 0 xK_o "Alsa Mixer" "M-A, S, O" openAlsaMixer
            ]
        ]
    ]

--------------------------------------------------------------------------------
-- Conversion Functions
--------------------------------------------------------------------------------

{- | Generate XMonad keymap from binding definitions.
Groups with (0, 0) have their children's keys used directly (no submap).
Groups with a real key create a submap.
-}
toXMonadKeys :: [Binding] -> M.Map (KeyMask, KeySym) (X ())
toXMonadKeys = M.fromList . concatMap flattenBinding
  where
    flattenBinding :: Binding -> [((KeyMask, KeySym), X ())]
    flattenBinding (Action mask key _ _ action) =
        [((mask, key), action)]
    flattenBinding (Group 0 0 _ children) =
        -- Tree-only group: flatten children directly (no submap)
        concatMap flattenBinding children
    flattenBinding (Group mask key _ children) =
        -- Real key: create a submap
        [((mask, key), submap $ M.fromList $ concatMap flattenChild children)]

    flattenChild :: Binding -> [((KeyMask, KeySym), X ())]
    flattenChild (Action mask key _ _ action) =
        [((mask, key), action)]
    flattenChild (Group 0 0 _ children) =
        -- Nested tree-only group: flatten
        concatMap flattenChild children
    flattenChild (Group mask key _ children) =
        -- Nested submap
        [((mask, key), submap $ M.fromList $ concatMap flattenChild children)]

{- | Generate TreeSelect nodes from binding definitions.
The tree structure mirrors the binding structure exactly.
-}
toTreeNodes :: [Binding] -> [Tree (TS.TSNode (X ()))]
toTreeNodes = map toNode
  where
    toNode :: Binding -> Tree (TS.TSNode (X ()))
    toNode (Action _ _ desc hint action) =
        Node (TS.TSNode desc hint action) []
    toNode (Group _ _ desc children) =
        Node (TS.TSNode (desc ++ " >") "" doNothing) (toTreeNodes children)

--------------------------------------------------------------------------------
-- Help Text Generation
--------------------------------------------------------------------------------

-- | Display all keybindings in dmenu and execute selected action
searchKeyBinds :: X ()
searchKeyBinds = do
    result <- menuMapArgs "dmenu-center" ["-i", "-p", "Keybindings:"] actionMap
    case result of
        Just action -> action
        Nothing -> return ()
  where
    actionMap :: M.Map String (X ())
    actionMap = M.fromList $ collectActions "" allBindings

    collectActions :: String -> [Binding] -> [(String, X ())]
    collectActions prefix = concatMap (collectAction prefix)

    collectAction :: String -> Binding -> [(String, X ())]
    collectAction prefix (Action _ _ desc hint action) =
        [(padHint hint ++ " " ++ prefixedDesc, action)]
      where
        prefixedDesc = if null prefix then desc else prefix ++ " > " ++ desc
    collectAction prefix (Group _ _ name children) =
        collectActions newPrefix children
      where
        newPrefix = if null prefix then name else prefix ++ " > " ++ name

    padHint :: String -> String
    padHint h = h ++ replicate (14 - length h) ' '

-- | Generate PDF of all keybindings and display in zathura
viewKeyBinds :: X ()
viewKeyBinds =
    spawn $
        "echo "
            ++ shellQuote markdown
            ++ " | pandoc -f markdown -t pdf | zathura -c ~/.config/zathura/zathura-dark - &"
  where
    markdown = unlines $ ["# XMonad Keybindings", ""] ++ generateMarkdown 2 allBindings

    generateMarkdown :: Int -> [Binding] -> [String]
    generateMarkdown depth bindings =
        -- Render actions first, then nested groups
        -- This prevents actions from visually appearing under the last nested group
        let (actions, groups) = partition isAction bindings
         in concatMap (bindingToMarkdown depth) actions
                ++ concatMap (bindingToMarkdown depth) groups

    isAction :: Binding -> Bool
    isAction (Action{}) = True
    isAction _ = False

    bindingToMarkdown :: Int -> Binding -> [String]
    bindingToMarkdown _ (Action _ _ desc hint _) =
        ["- **" ++ hint ++ "** — " ++ desc]
    bindingToMarkdown depth (Group _ _ name children) =
        -- Use heading level based on depth (## for top-level, ### for nested, etc.)
        -- Cap at 6 since markdown only supports h1-h6
        let level = min depth 6
         in ["", replicate level '#' ++ " " ++ name, ""]
                ++ generateMarkdown (depth + 1) children

    shellQuote :: String -> String
    shellQuote s = "'" ++ concatMap escapeChar s ++ "'"
      where
        escapeChar '\'' = "'\\''"
        escapeChar c = [c]
