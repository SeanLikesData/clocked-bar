import AppKit
import SwiftUI
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock and app switcher — menubar only.
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupPopover()
        observeTimer()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Hours")
        button.imagePosition = .imageLeft
        button.action = #selector(togglePopover)
        button.target = self
    }

    private func setupPopover() {
        popover = NSPopover()
        // .transient closes when user clicks outside. Unlike MenuBarExtra .window,
        // this only closes on external clicks — not when a view inside updates.
        popover.behavior = .transient
        popover.animates = true

        let content = MenuBarView()
            .environmentObject(appState)
        popover.contentViewController = NSHostingController(rootView: content)
    }

    private func observeTimer() {
        // Observe every published change so settings updates reflect immediately.
        // objectWillChange fires before the mutation, so we dispatch async to read
        // the new values after the property has been written.
        appState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.refreshStatusButton() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Status button

    private func refreshStatusButton() {
        guard let button = statusItem.button else { return }
        guard let project = appState.activeProject else {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Hours")
            button.title = ""
            return
        }

        button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: nil)

        let seconds = appState.currentSeconds(for: project)
        let timeStr = appState.menubarShowSeconds
            ? formatDuration(seconds)
            : formatDurationNoSeconds(seconds)

        switch appState.menubarDisplay {
        case .iconOnly:
            button.title = ""
        case .time:
            button.title = "  \(timeStr)"
        case .name:
            button.title = "  \(project.name)"
        case .nameAndTime:
            button.title = "  \(project.name)  \(timeStr)"
        }
    }

    // MARK: - Popover toggle

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
