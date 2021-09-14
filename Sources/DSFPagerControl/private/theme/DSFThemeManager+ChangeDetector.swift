//
//  DSFThemeChangeDetector.swift
//
//  Created by Darren Ford on 21/6/21.
//
//   let themeCapture = DSFThemeManager.ChangeDetector()
//
//   themeCapture.themeChangeCallback = { [weak self] theme, change in
//      self?.doSomething(theme)
//   }

#if os(macOS)

import AppKit

public extension DSFThemeManager {

	/// Detect visibility changes in the UI
	class ChangeDetector: NSObject {

		/// The theme manager being observed
		public let theme: DSFThemeManager

		/// A callback for when the theme changes. Guaranteed to always be called on the main thread
		public var themeChangeCallback: ((DSFThemeManager, DSFThemeManager.Change) -> Void)?

		public init(themeManager: DSFThemeManager = DSFThemeManager.shared) {
			self.theme = themeManager
			super.init()
			self.observer = self.theme.addObserver(queue: .main) { [weak self] notify in
				guard let `self` = self,
						let info = notify.userInfo?[DSFThemeManager.ThemeManagerChange],
						let changeType = info as? DSFThemeManager.Change else {
							fatalError()
						}
				self.themeDidChange(changeType)
			}
		}

		deinit {
			self.observer = nil
			self.themeChangeCallback = nil
		}

		// Privates

		private var observer: NSObjectProtocol?

		@objc private func themeDidChange(_ change: DSFThemeManager.Change) {
			assert(Thread.isMainThread)
			self.themeChangeCallback?(self.theme, change)
		}
	}
}

#endif
