module User.Search where

import XMonad

import User.Spawn (safeSpawn)
import User.Terminal

-- Password

findPassword :: X ()
findPassword = safeSpawn "passmenu -t -p"

findUserName :: X ()
findUserName = safeSpawn "passmenu -t -u"

-- Documentation

dmenuMan :: X ()
dmenuMan = safeSpawn "dmenu-man"

searchChtSh :: X ()
searchChtSh = launchFloatingTUI "cht-prompt" "120x30"

searchTldr :: X ()
searchTldr = safeSpawn "dmenu-tldr"

-- Notes

findNote :: X ()
-- findNote = launchFloatingTUI "slip -f" "100x40"
findNote = launchFloatingTUI "sh -c 'cd ~/data/base/slipbox && slip -f'" "100x40"

createNote :: X ()
createNote = launchFloatingTUI "sh -c 'cd ~/data/base/slipbox && slip -n'" "100x30"

-- Emojis

fzfEmojis :: X ()
fzfEmojis = launchFloatingTUI "fzf-emoji" "100x30"

dmenuEmojis :: X ()
dmenuEmojis = spawn "FINDER='dmenu -l 10 -bw 1' emojis"
