module User.Tasks where

import XMonad

import User.Terminal

showTasks :: X ()
showTasks = launchFloatingTUI "vit" "120x25"
