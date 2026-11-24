module User.Dotfiles where

import XMonad

import User.Terminal

stageDotfiles :: X ()
stageDotfiles = launchFloatingTUI "anykey stage-dotfiles" "120x40"

editDotfiles :: X ()
editDotfiles = launchTUI "edit-dotfiles" (Just "Dotfiles") Nothing

editScripts :: X ()
editScripts = launchTUI "edit-scripts" (Just "Scripts") Nothing
