{-# LANGUAGE QuasiQuotes #-}

import qualified Data.Map as M
import Data.Monoid
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Decoration
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Simplest (Simplest(..))
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedWindows
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

data LibNotifyUrgencyHook =
  LibNotifyUrgencyHook
  deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name <- getName w
    Just idx <- fmap (W.findTag w) $ gets windowset
    safeSpawn "notify-send" [show name, "workspace " ++ idx]

main :: IO ()
main = do
  xmonad $
    ewmh $
    withUrgencyHook LibNotifyUrgencyHook $
    def
      { normalBorderColor = "#666666"
      , focusedBorderColor = "darkgrey"
      , focusFollowsMouse = False
      , terminal = "alacritty"
      , workspaces = myWorkspaces
      , startupHook = myStartupHook
      , layoutHook = myLayoutHook
      , keys = \c -> myKeys c `M.union` XMonad.keys def c
      , manageHook = manageDocks <+> myManageHook <+> manageHook def
      } `removeKeysP`
    ["M-p"] -- don't clober emacs.

myKeys :: XConfig t -> M.Map (KeyMask, KeySym) (X ())
myKeys (XConfig {XMonad.modMask = modm}) =
  M.fromList
    [ ((modm .|. shiftMask, xK_Right), shiftToNext)
    , ((modm .|. shiftMask, xK_Left), shiftToPrev)
    , ((modm, xK_r), spawn "rofi -show run")
    , ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
    , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
    , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
    , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
    , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
    , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
    , ((modm .|. controlMask, xK_period), onGroup W.focusUp')
    , ((modm .|. controlMask, xK_comma), onGroup W.focusDown')
    ]

myWorkspaces :: [String]
myWorkspaces =
  clickable $ ["main", "2", "3", "4", "5", "6", "7", "8", "console"]
  where
    clickable l =
      [ "%{A1:xdotool key alt+" ++ show (n) ++ "&:}" ++ ws ++ "%{A}"
      | (i, ws) <- zip [1 :: Int .. 9 :: Int] l
      , let n = i
      ]

myTabTheme :: Theme
myTabTheme =
  def
    { activeTextColor = "#000"
    , activeColor = "#ffffea"
    , inactiveColor = "#dedeff"
    , urgentBorderColor = "red"
    }

myLayoutHook ::
     XMonad.Layout.LayoutModifier.ModifiedLayout
       WindowNavigation
       (XMonad.Layout.LayoutModifier.ModifiedLayout
          (XMonad.Layout.Decoration.Decoration
             XMonad.Layout.Tabbed.TabbedDecoration
             XMonad.Layout.Decoration.DefaultShrinker)
          (XMonad.Layout.LayoutModifier.ModifiedLayout
             (Sublayout Simplest)
             (XMonad.Layout.LayoutModifier.ModifiedLayout
                Spacing
                (Choose
                   (XMonad.Layout.LayoutModifier.ModifiedLayout
                      (XMonad.Layout.Decoration.Decoration
                         XMonad.Layout.Tabbed.TabbedDecoration
                         XMonad.Layout.Decoration.DefaultShrinker)
                      (XMonad.Layout.LayoutModifier.ModifiedLayout
                         (Sublayout Simplest)
                         Tall))
                   (Choose
                      (Mirror
                         (XMonad.Layout.LayoutModifier.ModifiedLayout
                            (XMonad.Layout.Decoration.Decoration
                               XMonad.Layout.Tabbed.TabbedDecoration
                               XMonad.Layout.Decoration.DefaultShrinker)
                            (XMonad.Layout.LayoutModifier.ModifiedLayout
                               (Sublayout Simplest)
                               Tall)))
                      Full)))))
       Window
myLayoutHook =
  windowNavigation $
  subTabbed $
  spacingRaw True (Border 30 5 5 5) True (Border 10 10 10 10) True $
  (tiled ||| Mirror tiled ||| Full)
  where
    tiled =
      addTabs shrinkText myTabTheme . subLayout [] Simplest $
      Tall nmaster delta ratio
    nmaster = 1
    ratio = 0.5
    delta = 0.03

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    [ className =? "mpv" --> doFloat
    , className =? "VLC" --> doFloat
    , className =? "Pinentry-gtk-2" --> doFloat
    , className =? "Pinentry-gnome3" --> doFloat
    , className =? "XConsole" --> doF (W.shift (myWorkspaces !! 8))
    ]

myStartupHook :: X ()
myStartupHook = do
  spawn "pkill polybar; polybar"
