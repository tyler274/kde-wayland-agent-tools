# kde-wayland-agent-tools

Small shell and Python tools that let a terminal agent (Claude Code, Codex, a cron job,
a remote shell) see and drive a KDE Plasma **Wayland** desktop when the usual
accessibility and automation stacks are not available.

They came out of a real session: "play this video" with Firefox open on YouTube, no
`xdotool`, no AT-SPI Python bindings, and a compositor that refuses the Wayland
virtual-keyboard protocol. Everything here was verified on NixOS with Plasma 6 and
Firefox running natively on Wayland.

## What works on Plasma Wayland, and what does not

| Approach | Result |
|---|---|
| `xdotool` | Only reaches Xwayland windows. Native Wayland apps such as Firefox ignore it. |
| `wtype`, `wlrctl` | Fail: KWin does not expose `zwp_virtual_keyboard_v1` or wlroots virtual pointer. |
| AT-SPI based computer use | Needs `python3` with `gi` and `gir1.2-atspi-2.0` on `PATH`. |
| MPRIS `Play` over D-Bus | Only works once a player is registered. Firefox registers one *after* media first plays. |
| **`dotool` over `/dev/uinput`** | Works. KWin hot-plugs the virtual evdev device like a real keyboard or mouse. |
| **KWin scripting over D-Bus** | Works for finding, focusing and raising windows. |
| **Spectacle `-b -f`** | Works for headless full-desktop screenshots. |

## Tools

All scripts live in `bin/`. Each sources `kw-env`, which fills in `WAYLAND_DISPLAY`,
`DBUS_SESSION_BUS_ADDRESS` and `XDG_RUNTIME_DIR` when the calling shell lacks them.

| Script | Purpose |
|---|---|
| `kw-focus <class> [caption]` | Activate a window by app class and caption substring via a throwaway KWin script. |
| `kw-input <dotool cmd>...` | Inject keys or pointer events through uinput. Falls back to `nix run nixpkgs#dotool`. |
| `kw-screenshot [out.png]` | Capture the entire desktop to a PNG without a GUI. |
| `kw-mpris` | List MPRIS players with playback status and title. |
| `firefox-tabs [profile]` | Print every open Firefox tab from the session store, selected tab starred. No extension required. |
| `kw-press-play [caption]` | Focus Firefox on YouTube, send `k`, confirm through MPRIS. |

## Requirements

- KDE Plasma on Wayland with `qdbus`, `busctl` and `spectacle` available.
- Write access to `/dev/uinput` for `kw-input`. On NixOS one option is a udev rule such as
  `KERNEL=="uinput", GROUP="input", MODE="0660"` plus membership of that group, or an ACL on the device.
- `dotool` on `PATH`, or Nix so the script can fetch it on demand.
- `python3` for `firefox-tabs` (standard library only).

## Example

```bash
export PATH="$PWD/bin:$PATH"
firefox-tabs | grep '^\*'            # which tab is in front
kw-screenshot before.png             # look at the screen
kw-press-play                        # focus YouTube in Firefox, press k, verify
kw-input "mouseto 0.45 0.50" "click left"   # or click a fraction of the screen
```

## Safety notes

`kw-input` types into whatever has keyboard focus. Focus the intended window with
`kw-focus` first and verify the result with `kw-screenshot` or `kw-mpris` rather than
assuming the keystroke landed. Nothing here bypasses the compositor's security model;
it relies on the user having granted uinput access on their own machine.

## License

MIT
