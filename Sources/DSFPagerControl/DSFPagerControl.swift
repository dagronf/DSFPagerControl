//
//  DSFPagerView.swift
//
//  Created by Darren Ford on 13/9/21.
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


import Foundation

#if os(macOS)

import AppKit

/// The pager delegate protocol
@objc public protocol DSFPagerControlHandling: NSObjectProtocol {
	/// Called when the pager has been asked to change to a new page. Return false to cancel the change
	func pagerControl(_ pager: DSFPagerControl, willMoveToPage: Int) -> Bool
	/// Called when the pager changed to a new page
	func pagerControl(_ pager: DSFPagerControl, didMoveToPage: Int)
}

/// A pager control
@IBDesignable
public class DSFPagerControl: NSView {
	/// The delegate to receive feedback
	@IBOutlet weak var delegate: DSFPagerControlHandling?

	/// Can the user use the keyboard to focus and change the selection?
	@IBInspectable public var allowsKeyboardFocus: Bool = false

	/// Can the user use the mouse to change the selection?
	@IBInspectable public var allowsMouseSelection: Bool = false

	/// The number of pages within the control
	@IBInspectable public dynamic var pageCount: Int = 0 {
		didSet {
			self.rebuildDotLayers()
		}
	}

	/// The currently selected page in the control
	@IBInspectable public dynamic var selectedPage: Int {
		get {
			return self._selected
		}
		set {
			self._selected = self.clamped(newValue)
		}
	}

//	/// The color to use when drawing the selected dot
//	@IBInspectable public var primaryColor: NSColor = .textColor {
//		didSet {
//			self.colorsDidChange()
//		}
//	}
//
//	/// The color to use when drawing a dot that's not selected
//	@IBInspectable public var secondaryColor: NSColor = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? .textColor : .placeholderTextColor {
//		didSet {
//			self.colorsDidChange()
//		}
//	}

	/// The width of each dot segment
	@IBInspectable public var dotBoundsWidth: CGFloat = 20 {
		didSet {
			self.rebuildDotLayers()
		}
	}
	/// The height of each dot segment
	@IBInspectable public var dotBoundsHeight: CGFloat = 20 {
		didSet {
			self.rebuildDotLayers()
		}
	}
	/// The diameter of the dot within the bounds
	@IBInspectable public var dotSize: CGFloat = 8 {
		didSet {
			self.rebuildDotLayers()
		}
	}

	/// Horizontal/Vertical display
	@IBInspectable public var isHorizontal: Bool = true {
		didSet {
			self.rebuildDotLayers()
		}
	}

	/// A custom callback for retrieving the circle fill color to use for the selected page
	public var selectedFillColorBlock: (() -> NSColor)? {
		didSet {
			self.colorsDidChange()
		}
	}

	/// A custom callback for retrieving the circle stroke color to use for an unselected page
	public var unselectedStrokeColorBlock: (() -> NSColor)? {
		didSet {
			self.colorsDidChange()
		}
	}

	/// Create
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	/// Create
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	// Private

	// Internal selected value.
	private var _selected: Int = 0 {
		didSet {
			self.selectionDidChange()
			self.delegate?.pagerControl(self, didMoveToPage: self._selected)
		}
	}

	var trackingArea: NSTrackingArea?

	// The layers currently on display
	private var dotLayers: [DotLayer] = []

	private let themeChangeDetector = DSFThemeManager.ChangeDetector()
}

// MARK: - Layout and display

extension DSFPagerControl {

	public override var isFlipped: Bool {
		return true
	}

	override public var wantsUpdateLayer: Bool {
		return true
	}

	override public var intrinsicContentSize: NSSize {
		if isHorizontal {
			return CGSize(width: self.dotBoundsWidth * CGFloat(self.pageCount), height: self.dotBoundsHeight)
		}
		else {
			return CGSize(width: self.dotBoundsWidth, height: self.dotBoundsHeight * CGFloat(self.pageCount))
		}
	}

	func setup() {
		wantsLayer = true

		self.themeChangeDetector.themeChangeCallback = { [weak self] (_, _) in
			self?.colorsDidChange()
		}

		self.rebuildDotLayers()
	}

	func selectionDidChange() {
		self.dotLayers.enumerated().forEach { l in
			l.element.isSelected = (l.offset == self._selected)
		}
	}

	func colorsDidChange() {
		self.dotLayers.forEach { l in
			l.updateDisplay()
		}
	}

	func rebuildDotLayers() {

		self.dotLayers.forEach { $0.removeFromSuperlayer() }
		self.dotLayers.removeAll()

		(0 ..< self.pageCount).forEach { index in
			let dl = DotLayer(parent: self)
			self.layer!.addSublayer(dl)
			self.dotLayers.append(dl)
		}
		self.relayoutLayers()

		self.invalidateIntrinsicContentSize()

		self.selectionDidChange()
	}

	public override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let t = self.trackingArea {
			self.removeTrackingArea(t)
		}

		if !self.allowsMouseSelection {
			return
		}

		self.trackingArea = NSTrackingArea(
			rect: self.bounds,
			options: [.mouseEnteredAndExited, .activeInActiveApp],
			owner: self,
			userInfo: nil)
		self.addTrackingArea(self.trackingArea!)
	}

	public override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		NSCursor.pointingHand.push()
	}

	public override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		NSCursor.pointingHand.pop()
	}

	// Layout the dot layers
	func relayoutLayers() {
		if isHorizontal {
			var xOff: CGFloat = 0
			self.dotLayers.forEach { l in
				l.frame = CGRect(x: xOff, y: 0, width: self.dotBoundsWidth, height: self.dotBoundsHeight)
				xOff += self.dotBoundsWidth
			}
		}
		else {
			var yOff: CGFloat = 0
			self.dotLayers.forEach { l in
				l.frame = CGRect(x: 0, y: yOff, width: self.dotBoundsWidth, height: self.dotBoundsHeight)
				yOff += self.dotBoundsHeight
			}
		}
	}

	override public func updateLayer() {
		super.updateLayer()
		self.relayoutLayers()
	}

	override public func prepareForInterfaceBuilder() {
		self.rebuildDotLayers()
		self.selectionDidChange()
	}
}

// MARK: - Keyboard and mouse handing

import Carbon.HIToolbox

public extension DSFPagerControl {
	override var acceptsFirstResponder: Bool {
		return allowsKeyboardFocus
	}

	override func drawFocusRingMask() {
		let pth = NSBezierPath(roundedRect: self.bounds, xRadius: 4, yRadius: 4)
		pth.fill()
	}

	override var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	override func keyDown(with event: NSEvent) {
		// Handle some special chars
		switch Int(event.keyCode) {
		case kVK_LeftArrow, kVK_UpArrow:
			self.moveToPage(self.clamped(self.selectedPage - 1))
		case kVK_RightArrow, kVK_DownArrow:
			self.moveToPage(self.clamped(self.selectedPage + 1))

		default:
			super.keyDown(with: event)
		}
	}

	override func mouseDown(with event: NSEvent) {
		if !allowsMouseSelection {
			return
		}

		if isHorizontal {
			let div = self.frame.width / CGFloat(self.pageCount)
			let point = self.convert(event.locationInWindow, from: nil)
			let which = Int((point.x / div).rounded(.towardZero))
			self.selectedPage = which
		}
		else {
			let div = self.frame.height / CGFloat(self.pageCount)
			let point = self.convert(event.locationInWindow, from: nil)
			let which = Int((point.y / div).rounded(.towardZero))
			self.selectedPage = which
		}
	}
}

// MARK: - Page changing

extension DSFPagerControl {
	// Must be called with a valid page range
	func moveToPage(_ page: Int) {
		assert((0 ..< self.pageCount).contains(page))

		if self.selectedPage == page {
			return
		}
		if self.delegate?.pagerControl(self, willMoveToPage: page) ?? true {
			self.selectedPage = page
		}

		NSAccessibility.post(element: self, notification: .selectedChildrenChanged)
	}

	@inlinable func clamped(_ page: Int) -> Int {
		max(0, min(self.pageCount - 1, page))
	}
}

extension DSFPagerControl {
	var _selectedFillColor: NSColor {
		if let s = self.selectedFillColorBlock {
			return s()
		}

		let grey: NSColor = DSFThemeManager.IsDark ? .systemGray : .darkGray
		return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? .textColor : grey
	}
	var _unselectedStrokeColor: NSColor {
		if let s = self.unselectedStrokeColorBlock {
			return s()
		}

		let grey: NSColor = DSFThemeManager.IsDark ? .systemGray : .darkGray
		return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? .textColor : grey
	}
}

// MARK: - Accessibility

public extension DSFPagerControl {
	override func isAccessibilityElement() -> Bool {
		return true
	}

	override func accessibilityRole() -> NSAccessibility.Role? {
		NSAccessibility.Role(rawValue: "Pager")
	}
}

// MARK: - Layer drawing

extension DSFPagerControl {
	class DotLayer: CAShapeLayer {
		unowned var parent: DSFPagerControl

		var isSelected: Bool = false {
			didSet {
				self.updateDisplay()
			}
		}

		init(parent: DSFPagerControl) {
			self.parent = parent
			super.init()
			self.setup()
		}

		override init(layer: Any) {
			guard let e = layer as? DSFPagerControl.DotLayer else {
				fatalError()
			}
			self.parent = e.parent
			super.init(layer: layer)

			self.setup()
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func setup() {
			self.updateDisplay()
		}

		func updateDisplay() {

			if #available(macOS 10.12, *) {
				if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion == true {
					CATransaction.setDisableActions(true)
				}
			}

			UsingEffectiveAppearance(of: self.parent) {
				if isSelected {
					self.fillColor = self.parent._selectedFillColor.cgColor
					self.strokeColor = self.parent._selectedFillColor.cgColor
				}
				else {
					self.fillColor = .clear
					self.strokeColor = self.parent._unselectedStrokeColor.cgColor
				}
			}
			self.lineWidth = 1

			CATransaction.commit()
		}

		override func layoutSublayers() {
			super.layoutSublayers()

			let ds: CGFloat = self.parent.dotSize

			let xO = max(0, (self.parent.dotBoundsWidth - ds) / 2)
			let yO = max(0, (self.parent.dotBoundsHeight - ds) / 2)

			self.path = CGPath(ellipseIn: CGRect(x: xO, y: yO, width: ds, height: ds), transform: nil)
		}
	}
}

#endif
