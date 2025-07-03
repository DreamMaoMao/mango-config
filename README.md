# Maomao-config

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code-of-conduct.md)
[![Awesome](https://awesome.re/badge-flat.svg)](https://awesome.re)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)

A special thanks to [Harsha Bhattacharyya](https://github.com/Harsha-Bhattacharyya) for co-authoring this document.

## Introduction

This repository contains the configuration files for my personalized `maomaowm` setup. It's tailored for a specific workflow and includes custom scripts and settings for a complete desktop environment.

## Index

- [Introduction](#introduction)
- [Screenshots](#screenshots)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Keybindings](#keybindings)
  - [Window Management](#window-management)
  - [Application Launchers](#application-launchers)
  - [System Control](#system-control)
  - [Mouse](#mouse)
  - [Scroll Wheel](#scroll-wheel)
  - [Touchpad Gestures](#touchpad-gestures)

## Screenshots

![image](https://github.com/user-attachments/assets/7b0f9d38-f919-43a5-ba1d-7bb21a07eea8)

![image](https://github.com/user-attachments/assets/39238f7f-9e0b-4c9e-981e-0eddd5cb0d0b)

## Dependencies

- `rofi-wayland`
- `foot`
- `xdg-desktop-portal-wlr`
- `swaybg`
- `waybar`
- `wl-clip-persist`
- `cliphist`
- `wl-clipboard`
- `wlsunset`
- `xfce-polkit`
- `swaync`
- `pamixer`
- `lavalauncher-mao-git`
- `wlr-dpms`
- `sway-audio-idle-inhibit-git`
- `swayidle`
- `dimland-git`
- `brightnessctl`
- `swayosd`
- `wlr-randr`
- `grim`
- `slurp`
- `satty`
- `swaylock-effects-git`
- `wlogout`

**Quick install for Arch:**

```bash
yay -S rofi-wayland foot xdg-desktop-portal-wlr swaybg waybar wl-clip-persist cliphist wl-clipboard wlsunset xfce-polkit swaync pamixer lavalauncher-mao-git wlr-dpms sway-audio-idle-inhibit-git swayidle dimland-git brightnessctl swayosd wlr-randr grim slurp satty swaylock-effects-git wlogout
```

**Note for other distributions:** The package names may differ. Please use your distribution's package manager to find and install the equivalent packages.

## Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/DreamMaoMao/maomao-config.git ~/.config/maomao
    ```

2.  Start the window manager from your display manager or terminal.

## Keybindings

### Window Management

| Keybinding | Action |
| --- | --- |
| `Super + R` | Reload configuration |
| `Alt + Q` | Close window |
| `Super + Tab` | Focus next window |
| `Super + U` | Focus last active window |
| `Alt + Left/Right/Up/Down` | Focus window in the specified direction |
| `Super + Shift + Left/Right/Up/Down` | Swap window with the one in the specified direction |
| `Ctrl + Shift + Left/Right/Up/Down` | Smart move window in the specified direction |
| `Ctrl + Alt + Left/Right/Up/Down` | Smart resize window in the specified direction |
| `Super + G` | Toggle window global mode |
| `Alt + Tab` | Toggle overview |
| `Alt + \` | Toggle window floating mode |
| `Alt + A` | Maximize window |
| `Alt + F` | Toggle fullscreen |
| `Alt + Shift + F` | Toggle fake fullscreen |
| `Super + I` | Minimize window |
| `Super + O` | Toggle window overlay mode |
| `Super + Shift + I` | Restore last minimized window |
| `Alt + Z` | Toggle scratchpad |
| `Alt + E` | Reset window proportion |
| `Alt + X` | Switch window proportion preset |
| `Super + E` / `Super + T` | Increase/Decrease master windows count |
| `Alt + Super + H` / `L` | Decrease/Increase master window size |
| `Alt + Super + K` / `J` | Decrease/Increase secondary window size |
| `Alt + S` | Move window to master area |
| `Ctrl + Super + I` | Set layout to spiral |
| `Ctrl + Super + L` | Set layout to scroller |
| `Super + N` | Switch layout |
| `Super + Left/Right` | View workspace to the left/right |
| `Ctrl + Left/Right` | View workspace to the left/right (if it has windows) |
| `Ctrl + Super + Left/Right` | Move window to workspace on the left/right |
| `Ctrl + Numpad 1-9` | View workspace 1-9 |
| `Alt + Numpad 1-9` | Move window to workspace 1-9 |
| `Ctrl + Super + Numpad 1-9` | Add/Remove window from workspace 1-9 |
| `Super + Numpad 1-9` | Toggle view of workspace 1-9 |
| `Alt + Shift + Left/Right` | Focus monitor on the left/right |
| `Super + Alt + Left/Right` | Move window to monitor on the left/right |
| `Alt + Shift + X` / `Z` | Increase/Decrease gaps |
| `Alt + Shift + R` | Toggle gaps |

### Application Launchers

| Keybinding | Action |
| --- | --- |
| `Alt + Return` | Open terminal |
| `Alt + Space` | Show application launcher |
| `Super + Return` | Open web browser |
| `Ctrl + Return` | Start Clash VPN script |
| `Ctrl + Super + Return` | Open file manager (yazi) |
| `Ctrl + Shift + Return` | Open email client (aerc) |
| `Ctrl + Alt + Return` | Open terminal multiplexer |
| `Ctrl + Space` | Search applications/files |
| `Super + Space` | Show clipboard history |
| `Super + Alt + Return` | Open video player (MPV) |

### System Control

| Keybinding | Action |
| --- | --- |
| `Super + M` | Quit session |
| `Super + L` | Lock screen |
| `Super + H` | Toggle Waybar visibility |
| `Ctrl + Alt + A` | Take screenshot |
| `Ctrl + Alt + T` | Translate text on screen |
| `Ctrl + ,` / `.` | Decrease/Increase brightness |
| `Alt + ,` / `.` | Decrease/Increase volume |
| `Ctrl + Alt + \` | Toggle notification center |
| `Ctrl + Alt + Backspace` | Clear all notifications |
| `Super + Shift + P` | Turn on primary display |
| `Super + P` | Run monitor setup script |
| `Super + Shift + p` | Run virtual monitor script |
| `Super + K` | Show key presses |
| `Super + Code:28` | Switch keyboard layout (`Code:28` is the keycode for the `grave` key) |

### Mouse

| Button | Action |
| --- | --- |
| `Super + Left Click` | Move window |
| `Alt + Middle Click` | Set window proportion to 50% |
| `Super + Right Click` | Resize window |
| `Super + Ctrl + Left Click` | Minimize window |
| `Super + Ctrl + Right Click` | Close window |
| `Super + Ctrl + Middle Click` | Toggle fullscreen |
| `Middle Click (on empty space)` | Maximize window |
| `Left Click (on empty space)` | Toggle overview |
| `Right Click (on empty space)` | Close window |

### Scroll Wheel

| Action | Command |
| --- | --- |
| `Super + Scroll Up/Down` | View workspace to the left/right (if it has windows) |
| `Alt + Scroll Up/Down` | Focus window on the left/right |
| `Shift + Super + Scroll Up/Down` | Swap window with the one on the left/right |
| `Ctrl + Alt + Scroll Up/Down` | Increase/Decrease window proportion |

### Touchpad Gestures

| Gesture | Action |
| --- | --- |
| 3-finger swipe Left/Right/Up/Down | Focus window in the specified direction |
| 4-finger swipe Left/Right | View workspace to the left/right (if it has windows) |
| 4-finger swipe Up/Down | Toggle overview |


