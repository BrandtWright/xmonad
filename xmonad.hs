--------------------------------------------------------------------------------
--
--  	  _/      _/  _/      _/    _/_/    _/      _/    _/_/    _/_/_/
--  	   _/  _/    _/_/  _/_/  _/    _/  _/_/    _/  _/    _/  _/    _/
--  	    _/      _/  _/  _/  _/    _/  _/  _/  _/  _/_/_/_/  _/    _/
--  	 _/  _/    _/      _/  _/    _/  _/    _/_/  _/    _/  _/    _/
--    _/      _/  _/      _/    _/_/    _/      _/  _/    _/  _/_/_/
--
--------------------------------------------------------------------------------
--
--  by Brandt Wright
--
--------------------------------------------------------------------------------
--  * TODO: [ ] Add bradt@github/dmenu to ansible
--  * TODO: [ ] Add additional wikis and search engines to search submap
--  * TODO: [ ] Re-theme dmenu_shot
--  * TODO: [ ] Bind (or script) global rehash
--  * TODO: [ ] Integrate input prompt: https://xmonad.github.io/xmonad-docs/xmonad-contrib-0.16.999/XMonad-Prompt-Input.html
--  * TODO: [ ] Checkout XMonad Actions Submap VisualSubmap
--  * TODO: [ ] investigate lm_sensors for mars.  Fan speed.  Arch wiki.
--

-- XMonad.Imports

import Data.Map qualified as M
import Data.Monoid
import Data.Ratio
import System.Exit (exitSuccess)
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import XMonad.Hooks.StatusBar.PP (filterOutWsPP)
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.StackSet qualified as W
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import User.Apps
import User.Bindings (allBindings, toXMonadKeys)
import User.Session (lockScreen, recompileXmonad, restartXmonad)
import User.Terminal
import User.Theme
import User.Tree (launchKeyTree)
import User.Windows (closeWindow)
import User.Workspaces

--------------------------------------------------------------------------------
-- Keys
--------------------------------------------------------------------------------

myKeys :: XConfig l -> M.Map (KeyMask, KeySym) (X ())
myKeys _ =
    M.union (toXMonadKeys allBindings) $
        M.fromList [((mod4Mask, xK_semicolon), launchKeyTree)]

myBorderWidth = 1

-------------------------------------------------------------------------------
-- Mouse Support
-------------------------------------------------------------------------------

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Bindings (default actions bound to mouse events)
myMouseBindings (XConfig{XMonad.modMask = mod4Mask}) =
    M.fromList
        -- mod-button1, Set the window to floating mode and move by dragging
        [
            ( (mod4Mask, button1)
            , \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster
            )
        , -- mod-button2, Raise the window to the top of the stack
          ((mod4Mask, button2), \w -> focus w >> windows W.shiftMaster)
        , -- mod-button3, Set the window to floating mode and resize by dragging

            ( (mod4Mask, button3)
            , \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster
            )
            -- you may also bind events to the mouse scroll wheel (button4 and button5)
        ]

--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
--    NOTE:
--
--   XMonad.Hooks.EwmhDesktops users must remove the obsolete
--   ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
--   Instead use the 'ewmh' function from that module to modify your
--   defaultConfig as a whole. (See also logHook, handleEventHook, and
--   startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--------------------------------------------------------------------------------

layoutTallName = "Tall"
layoutSpiralName = "Spiral"
layoutGridName = "Grid"
layoutMirrorName = "Mirror"
layoutFullName = "Full"
layoutTabbedName = "Tabbed"
layoutThreeColName = "3Col"
layoutThreeColMidName = "3ColMid"

myTabbedConfig =
    def
        { decoWidth = 200
        , decoHeight = 25
        , activeColor = tertiaryAccentBackground
        , activeTextColor = tertiaryAccentForeground
        , activeBorderColor = tertiaryAccentBackground
        , inactiveColor = primaryAccentBackground
        , inactiveTextColor = primaryAccentForeground
        , inactiveBorderColor = primaryAccentBackground
        , urgentColor = colorRed
        , urgentTextColor = primaryAccentBackground
        , urgentBorderColor = colorRed
        , fontName = fontMononokiNerdFontRegular12
        }

myLayoutHook =
    avoidStruts $
        renamed [CutWordsLeft 1] $ -- Remove the "Spacing" word from the layout name...
            spacingRaw False (squareBorder 10) True (squareBorder 10) True $
                mkToggle (NOBORDERS ?? FULL ?? EOT) $
                    smartBorders $
                        layoutResizableTall
                            ||| layoutMirror
                            ||| layoutSpiral
                            ||| layoutGrid
                            ||| layoutFull
                            ||| layoutTabbed
                            ||| layoutThreeCol
                            ||| layoutThreeColMid
  where
    squareBorder n = Border n n n n
    layoutResizableTall = renamed [Replace layoutTallName] (ResizableTall 1 (3 / 100) (1 / 2) [])
    layoutTall = Tall 1 (3 / 100) (1 / 2)
    layoutSpiral = renamed [Replace layoutSpiralName] $ spiral (125 % 146)
    layoutGrid = renamed [Replace layoutGridName] Grid
    layoutMirror = renamed [Replace layoutMirrorName] $ Mirror (Tall 1 (3 / 100) (3 / 5))
    layoutFull = renamed [Replace layoutFullName] $ noBorders Full
    layoutTabbed = gaps [(L, 10), (R, 10), (D, 5)] $ tabbedBottom shrinkText myTabbedConfig
    layoutThreeCol = renamed [Replace layoutThreeColName] (ThreeCol 1 (3 / 100) (3 / 7))
    layoutThreeColMid = renamed [Replace layoutThreeColMidName] (ThreeColMid 1 (3 / 100) (3 / 7))

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------
-- ServerMode allows external programs to send commands to XMonad via xmonadctl.
-- Usage: xmonadctl <command>
-- Example: xmonadctl lock-screen
--------------------------------------------------------------------------------

myServerCommands :: [(String, X ())]
myServerCommands =
    [ ("lock-screen", lockScreen)
    , ("restart", restartXmonad)
    , ("recompile", recompileXmonad)
    , ("quit", io exitSuccess)
    , ("next-workspace", nextWorkspace)
    , ("prev-workspace", prevWorkspace)
    , ("next-layout", nextLayout)
    , ("toggle-fullscreen", toggleFullScreen)
    , ("close-window", closeWindow)
    ]

myEventHook :: Event -> X All
myEventHook = serverModeEventHookCmd' $ return myServerCommands

---------------------------------------------------------------------------------
-- Logging
---------------------------------------------------------------------------------
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--     NOTE:
--
--    EwmhDesktops users should use the 'ewmh' function from:
--    XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
--    It will add EWMH logHook actions to your custom log hook by
--    combining it with ewmhDesktopsLogHook.
--------------------------------------------------------------------------------
myLogHook h = dynamicLogWithPP $ filterOutWsPP [scratchpadWorkspaceTag] wsPP{ppOutput = hPutStrLn h}

--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices. By default, do nothing.
--------------------------------------------------------------------------------
myStartupHook = do
    spawnOnce "picom -bc"
    spawnOnce "xrdb -merge $HOME/.Xresources"

--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use:
-- `xprop | grep WM_CLASS` and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--------------------------------------------------------------------------------
myManageHook =
    insertPosition Above Newer
        <+> composeAll
            [ className =? "MPlayer" --> doFloat
            , className =? "Gimp" --> doFloat
            , className =? "Tk" --> doFloat
            , className =? "mplayer2" --> doCenterFloat
            , className =? "mpv" --> doCenterFloat
            , className =? "feh" --> doCenterFloat
            , className =? "Display.im6" --> doCenterFloat
            , className =? "Shutter" --> doCenterFloat
            , className =? "Thunar" --> doCenterFloat
            , className =? "Nautilus" --> doCenterFloat
            , className =? "Plugin-container" --> doCenterFloat
            , className =? "Screenkey" --> doRectFloat (W.RationalRect 0.7 0.9 0.3 0.1)
            , className =? "Websearch" --> doCenterFloat
            , className =? "XClock" --> doSideFloat NE
            , className =? "zenity" --> doCenterFloat
            , className =? "gcr-prompter" --> doCenterFloat
            , className =? "Gcr-prompter" --> doCenterFloat
            , resource =? "desktop_window" --> doIgnore
            , resource =? "kdesktop" --> doIgnore
            , title =? "Speedbar" --> doCenterFloat
            , title =? "urxvt_float" --> doSideFloat SC
            , title =? floatingTitle --> doCenterFloat
            , title =? "Scratch Pad" --> doCenterFloat
            , title =? "Quick Pick" --> doCenterFloat
            , title =? "vCoolor" --> doCenterFloat
            , title =? "Bluetooth" --> doCenterFloat
            , stringProperty "WM_NAME" =? "LINE" --> doRectFloat (W.RationalRect 0.60 0.1 0.39 0.82)
            , stringProperty "WM_NAME" =? "Google Keep" --> doRectFloat (W.RationalRect 0.3 0.1 0.4 0.82)
            , stringProperty "WM_NAME" =? "tmptex.pdf - 1/1 (96 dpi)" --> doRectFloat (W.RationalRect 0.29 0.25 0.42 0.5)
            , stringProperty "WM_NAME" =? "Figure 1" --> doCenterFloat
            , isDialog --> doCenterFloat
            , isFullscreen --> doFullFloat
            ]

--------------------------------------------------------------------------------
-- Xmobar
--------------------------------------------------------------------------------
myWsBar = "xmobar $HOME/.config/xmobar/xmobarrc"

myLayoutPrinter :: String -> String
myLayoutPrinter layout = xmobarColor primaryAccentForeground primaryAccentBackground icon
  where
    icon = " <icon=" ++ iconName ++ ".xbm/>"
    iconName
        | layout == layoutTallName = "tall"
        | layout == layoutSpiralName = "spiral"
        | layout == layoutGridName = "grid"
        | layout == layoutMirrorName = "mirror"
        | layout == layoutFullName = "full"
        | layout == layoutThreeColName = "col"
        | layout == layoutThreeColMidName = "mid"
        | otherwise = "tabbed"

wsPP =
    xmobarPP
        { ppOrder = \(ws : l : t : xs : _) -> [l, ws, xs, t]
        , ppCurrent = xmobarColor primaryAccentForeground primaryAccentBackground . const "●"
        , ppUrgent = xmobarColor colorRed primaryAccentBackground . const "●"
        , ppVisible = xmobarColor colorGreen primaryAccentBackground . const "⦿"
        , ppHidden = xmobarColor colorBrightBlack primaryAccentBackground . const "●"
        , ppHiddenNoWindows = xmobarColor colorBrightBlack primaryAccentBackground . const "○"
        , ppTitle = xmobarColor primaryAccentForeground primaryAccentBackground . pad . shorten 50
        , ppOutput = putStrLn
        , ppWsSep = " "
        , ppSep = "   "
        , ppLayout = myLayoutPrinter
        , ppExtras = [lWorkspaceName]
        }
  where
    lWorkspaceName = xmobarColorL primaryAccentForeground primaryAccentBackground . padL . padL $ logCurrent

-- XMonad.EntryPoint

main = do
    wsbar <- spawnPipe myWsBar
    xmonad $
        ewmh . docks $
            withUrgencyHook NoUrgencyHook $
                def
                    { terminal = terminalName
                    , focusFollowsMouse = myFocusFollowsMouse
                    , borderWidth = myBorderWidth
                    , modMask = mod4Mask
                    , workspaces = myWorkspaces
                    , normalBorderColor = colorBlack
                    , focusedBorderColor = colorGold
                    , keys = myKeys
                    , mouseBindings = myMouseBindings
                    , layoutHook = myLayoutHook
                    , manageHook = manageDocks <+> myManageHook <+> namedScratchpadManageHook myScratchpads
                    , handleEventHook = myEventHook
                    , logHook = myLogHook wsbar
                    , startupHook = myStartupHook
                    }
