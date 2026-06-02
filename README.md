# Clocked

A minimal macOS menubar app for tracking billable time across projects.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)

## Features

- Lives in the menubar — no Dock icon
- Track time across multiple named projects
- One active timer at a time; starting a new project stops the current one
- Green clock icon while a timer is running
- Configurable menubar display: icon only, elapsed time, project name, or name and time
- Manual time entry — click the time on any project to set or add time
- Reorder and delete projects from the Manage Projects view
- All data persists across restarts

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build and run

```sh
git clone https://github.com/SeanLikesData/clocked-bar.git
cd clocked-bar
./run.sh
```

`run.sh` compiles the app with `swiftc` and opens it. The first build takes about 15 seconds; subsequent builds are similar as there is no incremental compilation.

To build without launching:

```sh
./build.sh
```

The output is `Clocked.app` in the project root.

## Install to Applications

After building, copy the app bundle to your Applications folder:

```sh
cp -R Clocked.app /Applications/Clocked.app
open /Applications/Clocked.app
```

To add it to Login Items so it starts automatically, open System Settings → General → Login Items and add `/Applications/Clocked.app`.

## First launch (Gatekeeper)

Because the app is built locally without an Apple Developer certificate, macOS may block the first launch. If you see a security warning, go to System Settings → Privacy & Security → scroll down and click **Open Anyway**, then relaunch the app. This prompt only appears once.

## Project structure

```
Clocked/
├── AppDelegate.swift          # NSStatusItem + NSPopover setup
├── AppState.swift             # Observable state, timer logic, persistence
├── ClockedApp.swift           # App entry point
├── Formatters.swift           # Duration formatting helpers
├── Models/
│   └── Project.swift          # Project data model
└── Views/
    ├── EditProjectsView.swift  # Reorder and delete projects
    ├── ManualTimeEntryView.swift
    ├── MenuBarLabel.swift
    ├── MenuBarView.swift       # Main popover content and navigation
    ├── ProjectRowView.swift    # Per-project row with timer controls
    └── SettingsView.swift      # Menubar display settings
```

## Regenerating the Xcode project

A `Clocked.xcodeproj` is included for development in Xcode. If you need to regenerate it after structural changes, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and run:

```sh
xcodegen generate
```
