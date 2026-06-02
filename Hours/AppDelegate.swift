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
        appState.$tick
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshStatusButton() }
            .store(in: &cancellables)
        appState.$activeProjectId
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshStatusButton() }
            .store(in: &cancellables)
    }

    // MARK: - Status button

    private func refreshStatusButton() {
        guard let button = statusItem.button else { return }
        if let project = appState.activeProject {
            let elapsed = formatDuration(appState.currentSeconds(for: project))
            button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: nil)
            button.title = "  \(elapsed)"
        } else {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Hours")
            button.title = ""
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
