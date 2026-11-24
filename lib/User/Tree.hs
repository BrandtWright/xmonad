module User.Tree (launchKeyTree) where

import Data.Map qualified as M
import XMonad
import XMonad.Actions.TreeSelect qualified as TS

import User.Bindings (allBindings, toTreeNodes)
import User.Theme

--------------------------------------------------------------------------------
-- Launch Key Tree
--------------------------------------------------------------------------------

launchKeyTree :: X ()
launchKeyTree = TS.treeselectAction keymapTreeConfig (toTreeNodes allBindings)

--------------------------------------------------------------------------------
-- TreeSelect Config
--------------------------------------------------------------------------------

keymapTreeConfig :: TS.TSConfig (X ())
keymapTreeConfig =
    TS.TSConfig
        { TS.ts_hidechildren = True
        , TS.ts_background = 0xc0000000
        , TS.ts_font = fontLiberationMonoPlRegular10
        , TS.ts_node = (0xff000000, 0xffa9b4c9)
        , TS.ts_nodealt = (0xff000000, 0xff8690a3)
        , TS.ts_highlight = (0xffffffff, 0xff64779c)
        , TS.ts_extra = 0xffa9b4c9
        , TS.ts_node_width = 260
        , TS.ts_node_height = 24
        , TS.ts_originX = 0
        , TS.ts_originY = 0
        , TS.ts_indent = 80
        , TS.ts_navigate = keymapTreeNavigation
        }

--------------------------------------------------------------------------------
-- TreeSelect Navigation
--------------------------------------------------------------------------------

keymapTreeNavigation =
    M.fromList
        [ ((0, xK_Escape), TS.cancel)
        , ((0, xK_Return), TS.select)
        , ((0, xK_space), TS.select)
        , ((0, xK_Up), TS.movePrev)
        , ((0, xK_Down), TS.moveNext)
        , ((0, xK_Left), TS.moveParent)
        , ((0, xK_Right), TS.moveChild)
        , ((0, xK_k), TS.movePrev)
        , ((0, xK_j), TS.moveNext)
        , ((0, xK_h), TS.moveParent)
        , ((0, xK_l), TS.moveChild)
        , ((0, xK_o), TS.moveHistBack)
        , ((0, xK_i), TS.moveHistForward)
        , ((controlMask, xK_bracketleft), TS.cancel)
        ]
