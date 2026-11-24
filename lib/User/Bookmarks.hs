module User.Bookmarks where

import XMonad

import User.Spawn (safeSpawn)
import User.Terminal

openMenuBookmarks :: X ()
openMenuBookmarks = launchFloatingTUI "menu" "100x30"

openWebBookmark :: X ()
openWebBookmark = launchFloatingTUI "bookmark-web-open" "120x30"

createWebBookmark :: X ()
createWebBookmark = safeSpawn "bookmark-web-create"

openDirectoryBookmark :: X ()
openDirectoryBookmark = safeSpawn "bookmark-directory-open"
