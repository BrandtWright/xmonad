module User.Session where

import XMonad

-- Utility

doNothing :: X ()
doNothing = return ()

-- XMonad Control

recompileXmonad :: X ()
recompileXmonad = spawn "xmonad --recompile"

restartXmonad :: X ()
restartXmonad = spawn "xmonad --restart"

-- Screen

lockScreen :: X ()
lockScreen = spawn "xset s activate"

-- Compositor

restartPicom :: X ()
restartPicom = spawn "killall picom;sleep 0.1;picom -b"
