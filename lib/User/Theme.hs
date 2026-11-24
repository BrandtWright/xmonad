{-# LANGUAGE BangPatterns #-}

module User.Theme where

import Control.Exception (SomeException, try)
import Data.Char (isSpace)
import Data.List (find, isPrefixOf, isSuffixOf)
import System.Directory (getHomeDirectory)
import System.IO (hClose, hGetContents)
import System.IO.Unsafe (unsafePerformIO)
import System.Process (
    CreateProcess (..),
    StdStream (..),
    createProcess,
    proc,
    waitForProcess,
 )

-- Xresources Integration
--
-- We parse ~/.Xresources directly rather than querying the X resource database
-- via xrdb. This avoids a dependency on DISPLAY being set, which is important
-- because GHC may evaluate these expressions at compile time (when no X server
-- is available).
--
-- We run the file through cpp (the C preprocessor) before parsing. This is the
-- same preprocessing that xrdb performs, so #include, #define, and #ifdef
-- directives are handled correctly.

{- | Cached Xresources, parsed once at first access.
Runs ~/.Xresources through cpp to expand preprocessor directives (#include,
#define, etc.). Falls back to reading the file directly if cpp fails.
-}
{-# NOINLINE xresourcesCache #-}
xresourcesCache :: [String]
xresourcesCache = unsafePerformIO $ do
    home <- getHomeDirectory
    let xresourcesPath = home ++ "/.Xresources"
    -- Try running through cpp first for preprocessor support.
    -- We use createProcess instead of readProcess because xmonad's SIGCHLD
    -- handling can interfere with the simpler readProcess API.
    cppResult <- try (runCpp xresourcesPath) :: IO (Either SomeException String)
    case cppResult of
        Right output -> return (lines output)
        Left _ -> do
            -- Fall back to reading file directly if cpp fails
            fileResult <- try (readFile xresourcesPath) :: IO (Either SomeException String)
            case fileResult of
                Right content -> return (lines content)
                Left _ -> return []

{- | Run cpp on a file and return the processed output.
Uses createProcess with explicit handle management to work around
process handling issues in xmonad's environment.
-}
runCpp :: FilePath -> IO String
runCpp path = do
    let cpProcess =
            (proc "cpp" ["-P", path])
                { std_in = NoStream
                , std_out = CreatePipe
                , std_err = NoStream
                , -- Don't create a new process group; inherit xmonad's
                  create_group = False
                , -- Delegate Ctrl-C handling to the child
                  delegate_ctlc = True
                }
    (_, Just hout, _, ph) <- createProcess cpProcess
    output <- hGetContents hout
    -- Force evaluation of output before closing handle
    let !result = length output `seq` output
    hClose hout
    _ <- waitForProcess ph
    return result

{- | Look up a value from ~/.Xresources.
Matches lines where the resource name ends with ".<key>" or equals "<key>".
Returns the fallback if not found or if the file cannot be parsed.
-}
xColor :: String -> String -> String
xColor key fallback = maybe fallback extractValue (find matchLine xresourcesCache)
  where
    matchLine l =
        let resourceName = takeWhile (/= ':') l
         in ("." ++ key) `isSuffixOf` resourceName || key == resourceName
    -- Extract the value after the colon, trimming whitespace
    extractValue l =
        let afterColon = drop 1 $ dropWhile (/= ':') l
         in trim afterColon
    trim s = dropWhile isSpace $ reverse $ dropWhile isSpace $ reverse s

-- | Look up a standard terminal color (color0-color15) from Xresources.
xTermColor :: Int -> String -> String
xTermColor n = xColor ("color" ++ show n)

-- Font

fontJetBrainsMonoRegular10 :: String
fontJetBrainsMonoRegular10 = "xft:JetBrainsMono Nerd Font Mono:regular:pixelsize=10"

fontJetBrainsMonoRegular15 :: String
fontJetBrainsMonoRegular15 = "xft:JetBrainsMono Nerd Font Mono:regular:pixelsize=15"

fontJetBrainsMonoRegular20 :: String
fontJetBrainsMonoRegular20 = "xft:JetBrainsMono Nerd Font Mono:regular:pixelsize=20"

fontLiberationMonoPlRegular10 :: String
fontLiberationMonoPlRegular10 = "xft:Liberation Mono for Powerline:size=10:antialias=true:hinting=true"

fontMononokiNerdFontRegular12 :: String
fontMononokiNerdFontRegular12 = "xft:Mononoki Nerd Font:size=12:antialias-true"

-- Accent Colors
prefix :: String
prefix = "screen_glasses.ui."

primaryAccentForeground :: String
primaryAccentForeground = xColor (prefix ++ "primary_accent_foreground") "#a8948a"

primaryAccentBackground :: String
primaryAccentBackground = xColor (prefix ++ "primary_accent_background") "#221c19"

secondaryAccentForeground :: String
secondaryAccentForeground = xColor (prefix ++ "secondary_accent_foreground") "#a49085"

secondaryAccentBackground :: String
secondaryAccentBackground = xColor (prefix ++ "secondary_accent_background") "#4d4136"

tertiaryAccentForeground :: String
tertiaryAccentForeground = xColor (prefix ++ "tertiary_accent_foreground") "#2c2826"

tertiaryAccentBackground :: String
tertiaryAccentBackground = xColor (prefix ++ "tertiary_accent_background") "#a49085"

-- Terminal Colors

colorBlack :: String
colorBlack = xTermColor 0 "#171717"

colorBrightBlack :: String
colorBrightBlack = xTermColor 8 "#636363"

colorRed :: String
colorRed = xTermColor 1 "#c88484"

colorGreen :: String
colorGreen = xTermColor 2 "#7b9d80"

colorGold :: String
colorGold = "#a38e5c"
