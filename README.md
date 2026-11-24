# xmonad

My [XMonad](https://xmonad.org) configuration, with `xmonadctl`, a small
tool that sends commands to a running XMonad.

## Building

On Arch Linux, with `ghc`, `xmonad` and `xmonad-contrib` installed:

```sh
./build
```

It compiles `xmonad.hs` (with the modules in `lib/`) and installs
`xmonadctl` into `~/.local/bin`; its exit status says whether both
compiled, and `notify-send` reports it on the desktop. `xmonad --recompile`
runs it too, giving it the path for XMonad's binary.

## Colours and fonts

The colours come from `~/.Xresources` when XMonad starts (`lib/User/Theme.hs`),
with fallbacks for when it's missing, so this repository holds no theme of
its own. On my machines, `~/.Xresources` and the status bar's (xmobar's)
configuration, `~/.config/xmobar/xmobarrc`, are written by my host
provisioning, from one palette.

## Layout icons

`assets/` holds the status bar's layout icons, as X bitmaps (`.xbm`),
chosen by name in `xmonad.hs`.

## Licence

MIT: see `LICENSE`.
