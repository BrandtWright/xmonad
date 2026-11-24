module User.Hardware where

import XMonad

import User.Spawn (safeSpawn)
import User.Terminal

-- Keyboard

-- Have to use keyup so that any key binds that require a modifier
-- key to be depressed when xdotool executes do not cause it to send, e.g.,
-- Super-Shift-Menu instead of just Menu.
openAppMenu :: X ()
openAppMenu =
    spawn $
        "xdotool keyup super shift control alt; "
            ++ "sleep 0.05; "
            ++ "xdotool key Menu"

-- Mouse

toggleTouchPad :: X ()
toggleTouchPad = safeSpawn "touchpad-toggle.sh"

-- Network

-- A small terminal, so the sudo password prompt has somewhere to appear.
toggleVpn :: X ()
toggleVpn = launchFloatingTUI "anykey vpn toggle" "60x8"

-- Sound

increaseVolume :: X ()
increaseVolume = safeSpawn "volume-control up"

decreaseVolume :: X ()
decreaseVolume = safeSpawn "volume-control down"

toggleVolume :: X ()
toggleVolume = safeSpawn "volume-control toggle"

selectPulseAudioSink :: X ()
selectPulseAudioSink = safeSpawn "volume-control select"

openAlsaMixer :: X ()
openAlsaMixer = launchFloatingTUI "alsamixer" "120x30"

-- Display

increaseBrightness :: X ()
increaseBrightness = safeSpawn "brightness up"

decreaseBrightness :: X ()
decreaseBrightness = safeSpawn "brightness down"
