module User.Prompts where

import Data.Map qualified as M
import XMonad
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch

import User.Theme

defaultPickerKeymap =
    M.union emacsLikeXPKeymap $
        M.fromList
            [ ((controlMask, xK_g), quit)
            , ((controlMask, xK_m), setSuccess True >> setDone True)
            , ((controlMask, xK_j), setSuccess True >> setDone True)
            , ((controlMask, xK_h), deleteString Prev)
            , ((mod4Mask, xK_b), moveWord Prev)
            , ((mod4Mask, xK_f), moveWord Next)
            ]

defaultPickerConfig =
    def
        { font = fontJetBrainsMonoRegular20
        , bgColor = primaryAccentBackground
        , fgColor = tertiaryAccentBackground
        , fgHLight = primaryAccentBackground
        , bgHLight = tertiaryAccentBackground
        , borderColor = tertiaryAccentBackground
        , promptBorderWidth = 1
        , position = CenteredAt 0.4 0.5
        , height = 30
        , historySize = 256
        , maxComplRows = Just 10
        , promptKeymap = defaultPickerKeymap
        , searchPredicate = fuzzyMatch
        , sorter = fuzzySort
        , completionKey = (controlMask, xK_n)
        , prevCompletionKey = (controlMask, xK_p)
        , alwaysHighlight = True
        }
