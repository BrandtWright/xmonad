module User.Git where

import XMonad

import User.Spawn (safeSpawn)
import User.Terminal (launchFloatingTUI, launchTUI)

findRepoAndTig :: X ()
findRepoAndTig = launchFloatingTUI "fzf-repos-tig" "120x30"

findRepoAndOpenInConsole :: X ()
findRepoAndOpenInConsole = safeSpawn "dmenu-repos-shell"

dmenuTig :: X ()
dmenuTig = safeSpawn "dmenu-repos-tig"
