//
//  DSFThemeManager.swift
//
//  Created by Darren Ford on 28/2/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  With help from
//    https://chromium.googlesource.com/chromium/src/+/master/content/renderer/theme_helper_mac.mm
//    https://bugzilla.mozilla.org/show_bug.cgi?id=1062801
//
//  Simple Usage :-
//
//     _ = DSFThemeManager.shared.addObserver { notification in
//         Swift.print(self.theme)
//     }
//

#if os(macOS)

import AppKit

/// Apple notifications for theme changes
private extension NSNotification.Name {
	static let ThemeChangedNotification = NSNotification.Name("AppleInterfaceThemeChangedNotification")
	static let AccentChangedNotification = NSNotification.Name("AppleColorPreferencesChangedNotification")
	static let AquaVariantChangeNotification = NSNotification.Name("AppleAquaColorVariantChanged")
	static let SystemColorsChangeNotification = NSNotification.Name("NSSystemColorsDidChangeNotification")
}

@objc internal class DSFThemeManager: NSObject {
	/// A common shared thememanager
	@objc public static let shared = DSFThemeManager()

	/// The notification sent when a change occurs in the theme.
	///
	/// The userInfo contains the change type(s) as an via the key DSFThemeManager.ThemeChangedNotification,
	/// as a `DSFThemeManager.Changes` object
	@objc(DSFThemeManagerThemeChangedNotification)
	public static let ThemeChangedNotification = NSNotification.Name("DSFThemeManager.ThemeChangedNotification")

	/// Key for the notification containing the type(s) of changes that occured.
	@objc(DSFThemeManagerChange)
	public static let ThemeManagerChange: String = "DSFThemeManagerChange"

	/// The type of a change that occurred
	@objc(DSFThemeManagerStyleChangeType)
	public enum StyleChangeType: Int {
		case theme = 0
		case accent = 1
		case aquaVariant = 2
		case systemColors = 3
		case accentColorOrTheme = 4
		case contrastOrAccessibility = 5
	}

	/// A class containing the current set of theme changes
	@objc(DSFThemeManagerChange)
	public class Change: NSObject {
		public private(set) var changes = Set<StyleChangeType>()

		@objc func add(change: StyleChangeType) {
			self.changes.insert(change)
		}

		@objc public var nsChanges: NSSet {
			return NSSet(set: self.changes)
		}
	}

	private let debouncer = DSFDebounce(seconds: 0.1)
	private var queuedChanges = Change()

	fileprivate static let kInterfaceStyle: String = "AppleInterfaceStyle"
	fileprivate static let kHighlightStyle: String = "AppleHighlightColor"
	fileprivate static let kAccentColor: String = "AppleAccentColor"
	fileprivate static let kAquaVariantColor: String = "AppleAquaColorVariant"

	@objc(DSFThemeManagerAquaColorVariant)
	public enum AppleAquaColorVariant: Int {
		case blue = 1
		case graphite = 6
	}

	@objc(DSFThemeManagerSystemColor)
	public enum SystemColor: Int {
		case graphite = -1
		case red = 0
		case orange = 1
		case yellow = 2
		case green = 3
		case blue = 4
		case purple = 5
		case pink = 6
	}

	/// Return the NSColor object representing the system color
	@objc public static func Color(for systemColor: SystemColor) -> NSColor {
		return DSFThemeManager.ColorForInt(systemColor.rawValue)
	}

	/// Map an integer value to a system color
	private static func ColorForInt(_ value: Int) -> NSColor {
		switch value {
		case -1: return NSColor.systemGray
		case 0: return NSColor.systemRed
		case 1: return NSColor.systemOrange
		case 2: return NSColor.systemYellow
		case 3: return NSColor.systemGreen
		case 4: return NSColor.systemBlue
		case 5: return NSColor.systemPurple
		case 6: return NSColor.systemPink
		default: return self.DefaultColor
		}
	}

	// Default color (has changed in Big Sur)
	private static var DefaultColor: NSColor {
		if #available(OSX 11.0, *) {
			return NSColor.systemGray
		}
		else {
			return NSColor.systemBlue
		}
	}

	/// The distributed notification center to listen to for some of the notification types
	private let distributedNotificationCenter = DistributedNotificationCenter.default()

	/// The notification center to post updates on
	private var notificationCenter: NotificationCenter

	/// Is the UI currently being displayed as dark (Mojave upwards)
	@objc public private(set) var isDark: Bool = DSFThemeManager.IsDark

	/// Are the menu and doc currently being displayed as dark (Yosemite upwards)
	@objc public private(set) var isDarkMenu: Bool = DSFThemeManager.IsDarkMenu

	/// What is the current accent color?
	@objc public private(set) var accentColor: NSColor = DSFThemeManager.AccentColor

	/// What is the current highlight color?
	@objc public private(set) var highlightColor: NSColor = DSFThemeManager.HighlightColor

	/// What is the current aqua variant color?
	@objc public private(set) var aquaVariant: AppleAquaColorVariant = DSFThemeManager.AquaVariant

	init(notificationCenter: NotificationCenter = NotificationCenter.default) {
		self.notificationCenter = notificationCenter
		super.init()
		self.installNotificationListeners()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		self.distributedNotificationCenter.removeObserver(self)
	}

	override public var description: String {
		return
			"""
			Current Theme:
				isDark: \(self.isDark)
				isDarkMenu: \(self.isDarkMenu)
				accentColor: \(self.accentColor)
				highlightColor: \(self.highlightColor)
				aquaVariant: \(self.aquaVariant)
			"""
	}

	/// Force a reload of the theme cache
	@objc public func updateCache() {
		self.isDark = Self.IsDark
		self.isDarkMenu = Self.IsDarkMenu
		self.accentColor = Self.AccentColor
		self.highlightColor = Self.HighlightColor
		self.aquaVariant = Self.AquaVariant
	}
}

// MARK: - Observers and Listeners

@objc extension DSFThemeManager {
	/// Adds an entry to the notification center to call the provided selector with the notification.
	func addObserver(_ observer: Any, selector aSelector: Selector) {
		self.notificationCenter.addObserver(
			observer,
			selector: aSelector,
			name: DSFThemeManager.ThemeChangedNotification,
			object: self
		)
	}

	/// Adds an entry to the notification center to receive notifications that passed to the provided block.
	func addObserver(queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
		return NotificationCenter.default.addObserver(
			forName: DSFThemeManager.ThemeChangedNotification,
			object: self,
			queue: queue,
			using: block
		)
	}

	/// Removes all entries specifying an observer from the notification center's dispatch table
	func removeObserver(_ observer: NSObject) {
		self.notificationCenter.removeObserver(observer)
	}
}

// MARK: - Static theme values

@objc extension DSFThemeManager {
	/// Is the user interface being displayed as dark (Mojave and later)
	static var IsDark: Bool {
		if #available(OSX 10.14, *) {
			if let style = UserDefaults.standard.string(forKey: DSFThemeManager.kInterfaceStyle) {
				return style.lowercased().contains("dark")
			}
		}
		return false
	}

	/// Are the menu bars and dock being displayed as dark (Yosemite and later)
	static var IsDarkMenu: Bool {
		if let style = UserDefaults.standard.string(forKey: DSFThemeManager.kInterfaceStyle) {
			return style.lowercased().contains("dark")
		}
		return false
	}

	/// Returns the user's current accent color
	static var AccentColor: NSColor {
		if #available(OSX 10.14, *) {
			// macOS 10.14 and above have a dedicated static NSColor
			return NSColor.controlAccentColor
		}

		// Use standard user defaults for anything lower than 10.14
		let userDefaults = UserDefaults.standard
		guard userDefaults.object(forKey: kAccentColor) != nil else {
			//  Pre-11.0, defaults to blue
			//  Post-11.0, uses application-defined accent color if provided (SwiftUI only?), else blue
			return Self.DefaultColor
		}

		return ColorForInt(userDefaults.integer(forKey: kAccentColor))
	}

	/// Returns the user's current highlight color
	static var HighlightColor: NSColor {
		let ud = UserDefaults.standard

		guard let setting = ud.string(forKey: DSFThemeManager.kHighlightStyle) else {
			return NSColor.systemGray
		}

		let c = setting.components(separatedBy: " ")
		guard let r = Float(c[0]), let g = Float(c[1]), let b = Float(c[2]) else {
			return NSColor.systemGray
		}

		return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
	}

	/// Returns the current aqua variant. (graphite or aqua style on older macOS)
	static var AquaVariant: AppleAquaColorVariant {
		let userDefaults = UserDefaults.standard
		guard userDefaults.object(forKey: DSFThemeManager.kAquaVariantColor) != nil else {
			return AppleAquaColorVariant.blue
		}

		let colorDef = userDefaults.integer(forKey: DSFThemeManager.kAquaVariantColor)
		guard let variant = AppleAquaColorVariant(rawValue: colorDef) else {
			return AppleAquaColorVariant.blue
		}
		return variant
	}
}

// MARK: - Internals

private extension DSFThemeManager {
	private func installNotificationListeners() {
		// Listen for theme changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.themeChange),
			name: NSNotification.Name.ThemeChangedNotification,
			object: nil
		)

		// Listen for accent changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.accentChange),
			name: NSNotification.Name.AccentChangedNotification,
			object: nil
		)

		// Listen for aqua variant changes
		self.distributedNotificationCenter.addObserver(
			self,
			selector: #selector(self.aquaVariantChange),
			name: NSNotification.Name.AquaVariantChangeNotification,
			object: nil
		)

		// Listen for changes on NSSystemColorsDidChangeNotification (user changed the accent color)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.systemColorsChange),
			name: NSNotification.Name.SystemColorsChangeNotification,
			object: nil
		)

		// Listen for changes on NSWorkspace.didChangeFileLabelsNotification (the accent name or color changed)
		NSWorkspace.shared.notificationCenter.addObserver(
			self,
			selector: #selector(self.finderLabelsDidChange),
			name: NSWorkspace.didChangeFileLabelsNotification,
			object: nil
		)

		// Accessibility changes
		NSWorkspace.shared.notificationCenter.addObserver(
			self,
			selector: #selector(self.accessibilityDidChange),
			name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
			object: NSWorkspace.shared)
	}

	@objc private func themeChange() {
		self.changedTheme(change: .theme)
	}

	@objc private func accentChange() {
		self.changedTheme(change: .accent)
	}

	@objc private func aquaVariantChange() {
		self.changedTheme(change: .aquaVariant)
	}

	@objc private func systemColorsChange() {
		self.changedTheme(change: .systemColors)
	}

	@objc private func finderLabelsDidChange() {
		self.changedTheme(change: .accentColorOrTheme)
	}

	@objc private func accessibilityDidChange() {
		self.changedTheme(change: .contrastOrAccessibility)
	}

	private func changedTheme(change: StyleChangeType) {
		// Swift.print("DSFThemeManager: update")

		// Make sure that these occur on the main queue
		DispatchQueue.main.async { [weak self] in
			self?.update(change: change)
		}
	}

	private func update(change: StyleChangeType) {
		// Using the main thread here avoids race conditions on `self.queuedChanges`
		assert(Thread.isMainThread)

		// Update the local caches first
		self.updateCache()

		// Update the queue with the new change type
		self.queuedChanges.add(change: change)

		// And debounce, so that we don't receive lots of messages for a single change
		self.debouncer.debounce { [weak self] in
			self?.postChanges()
		}
	}

	private func postChanges() {
		// Using the main thread here avoids race conditions on `self.queuedChanges`
		assert(Thread.isMainThread)

		// Take ownership of the current set of queued changes
		let ch = self.queuedChanges
		self.queuedChanges = Change()
		self.notificationCenter.post(
			name: DSFThemeManager.ThemeChangedNotification,
			object: self,
			userInfo: [DSFThemeManager.ThemeManagerChange: ch]
		)
	}
}

#endif
