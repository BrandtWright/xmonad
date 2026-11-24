module User.Apps where

import XMonad

import User.Spawn (safeSpawn)
import User.Terminal
import User.Workspaces (spawnToWorkspace)

-- Launchers

dmenuRun :: X ()
dmenuRun = spawn "dmenu_run -c -bw 1 -l 10"

-- Scratch Pads

openScratchPad :: X ()
openScratchPad = launchTUI "scratch-pad" (Just "Scratch Pad") (Just "90x30")

openWorkScratchPad :: X ()
openWorkScratchPad =
    launchTUI
        "nvim $HOME/data/projects/work/scratch.md"
        (Just "Scratch Pad")
        (Just "90x30")

-- Terminals

openTmux :: X ()
openTmux = launchTUI "tmux" (Just "Tmux-Deluxe") Nothing

-- Music

openNcmpcpp :: X ()
openNcmpcpp = launchTUI "ncmpcpp" (Just "Music Player") Nothing

-- File Managers

openNautilus :: X ()
openNautilus = spawn "nautilus"

openThunar :: X ()
openThunar = spawn "thunar"

openPcmanfm :: X ()
openPcmanfm = spawn "pcmanfm"

openRanger :: X ()
openRanger = launchTUI "ranger" Nothing Nothing

openVifm :: X ()
openVifm = launchTUI "vifm" Nothing Nothing

openFileRoller :: X ()
openFileRoller = spawn "file-roller"

-- Office

openLoCalc :: X ()
openLoCalc = spawn "localc"

openLoWriter :: X ()
openLoWriter = spawn "lowriter"

openLoBase :: X ()
openLoBase = spawn "lobase"

openLoImpress :: X ()
openLoImpress = spawn "loimpress"

openLoDraw :: X ()
openLoDraw = spawn "libreoffice --draw"

-- Browsers

openBrowser :: X ()
openBrowser = spawn "brave"

openVivaldi :: X ()
openVivaldi = spawn "vivaldi-stable"

openSurf :: X ()
openSurf = spawn "surf"

openLuakit :: X ()
openLuakit = spawn "luakit"

openArchWiki :: X ()
openArchWiki = safeSpawn "arch-wiki"

-- Design

openFigma :: X ()
openFigma = spawn "figma-linux"

openBlender :: X ()
openBlender = spawn "blender"

openGimp :: X ()
openGimp = spawn "gimp"

-- System Monitors

openGlances :: X ()
openGlances = launchTUI "glances" Nothing Nothing

openHtop :: X ()
openHtop = launchTUI "htop" Nothing Nothing

openGotop :: X ()
openGotop = launchTUI "gotop" Nothing Nothing

-- Wikis

openPersonalWiki :: X ()
openPersonalWiki =
    launchTUI
        "nvim ~/data/documents/vimwiki/index.md"
        (Just "Personal Wiki")
        Nothing

-- Misc

openZathura :: X ()
openZathura = spawn "zathura"

runMatrixOnMisc :: X ()
runMatrixOnMisc = spawnToWorkspace "st -e unimatrix -s 96" "Misc"
