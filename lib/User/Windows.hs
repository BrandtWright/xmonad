module User.Windows where

import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.RotSlaves
import XMonad.Layout.ResizableTile
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.Workspace
import XMonad.StackSet qualified as W

import User.Prompts
import User.Workspaces (wsFilter)

-- Window Focus

focusNextWindow :: X ()
focusNextWindow = windows W.focusDown

focusPrevWindow :: X ()
focusPrevWindow = windows W.focusUp

gotoWindow :: X ()
gotoWindow = windowPrompt defaultPickerConfig{autoComplete = Just 500000} Goto allWindows

bringWindow :: X ()
bringWindow = windowPrompt defaultPickerConfig{autoComplete = Just 500000} Bring allWindows

sendWindow :: X ()
sendWindow = workspacePrompt defaultPickerConfig (windows . W.shift)

-- Window Operations

closeWindow :: X ()
closeWindow = kill

pushWindowToTilingMode :: X ()
pushWindowToTilingMode = withFocused $ windows . W.sink

-- Window Movement

swapWindowUp :: X ()
swapWindowUp = windows W.swapUp

swapWindowDown :: X ()
swapWindowDown = windows W.swapDown

windowToNextWorkspace :: X ()
windowToNextWorkspace = shiftTo Next wsFilter

windowToPrevWorkspace :: X ()
windowToPrevWorkspace = shiftTo Prev wsFilter

windowToMasterPane :: X ()
windowToMasterPane = windows W.shiftMaster

rotateWindowsDown :: X ()
rotateWindowsDown = rotAllDown

rotateWindowsUp :: X ()
rotateWindowsUp = rotAllUp

-- Window Sizing

shrinkWindow :: X ()
shrinkWindow = sendMessage MirrorShrink

expandWindow :: X ()
expandWindow = sendMessage MirrorExpand

-- Window Copying

copyWindowToAllWorkspaces :: X ()
copyWindowToAllWorkspaces = windows copyToAll

killOtherWindowCopies :: X ()
killOtherWindowCopies = killAllOtherCopies
