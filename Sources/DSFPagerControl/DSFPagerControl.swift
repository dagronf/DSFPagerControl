//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if os(macOS)

import Foundation
import AppKit

import DSFAppearanceManager

/// A pager control
@IBDesignable
public class DSFPagerControl: NSView {

	/// The delegate to receive feedback
	@IBOutlet public weak var delegate: DSFPagerControlHandling?

	/// Can the user use the keyboard to focus and change the selection?
	@IBInspectable public var allowsKeyboardFocus: Bool = false {
		didSet {
			self.needsLayout = true
			self.needsDisplay = true
		}
	}

	/// Can the user use the mouse to change the selection?
	@IBInspectable public var allowsMouseSelection: Bool = false {
		didSet {
			self.updateTrackingAreas()
		}
	}

	/// The number of pages within the control
	@IBInspectable public dynamic var pageCount: Int {
		get { self._pageCount }
		set {
			if newValue != self._pageCount {
				self._pageCount = newValue
				self.rebuildDotLayers()
			}
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

	/// The indicator shape
	@objc public var indicatorShape: DSFPagerControlIndicatorShape = HorizontalIndicatorShape() {
		didSet {
			self.rebuildDotLayers()
		}
	}

	@IBInspectable public var isHorizontal: Bool = true {
		didSet {
			self.indicatorShape = self.isHorizontal ? HorizontalIndicatorShape() : VerticalIndicatorShape()
		}
	}

	/// The color to use when drawing the selected dot
	@IBInspectable public var selectedColor: NSColor? = nil {
		didSet {
			if let s = selectedColor {
				self.selectedColorBlock = {
					return s
				}
			}
			else {
				selectedColorBlock = nil
			}
			self.colorsDidChange()
		}
	}

	/// The color to use when drawing a dot that's not selected
	@IBInspectable public var unselectedColor: NSColor? = nil {
		didSet {
			if let s = unselectedColor {
				self.unselectedColorBlock = {
					return s
				}
			}
			else {
				unselectedColorBlock = nil
			}
			self.colorsDidChange()
		}
	}

	/// Uses the selected color to draw a 0.5px border around each unselected page dot
	@IBInspectable public var bordered: Bool = false {
		didSet {
			self.colorsDidChange()
		}
	}

	/// A custom callback for retrieving the circle fill color to use for the selected page
	@objc public var selectedColorBlock: (() -> NSColor)? {
		didSet {
			self.colorsDidChange()
		}
	}

	/// A custom callback for retrieving the circle stroke color to use for an unselected page
	@objc public var unselectedColorBlock: (() -> NSColor)? {
		didSet {
			self.colorsDidChange()
		}
	}


	////////
	
	/// The width of each page indicator. Only applies to the default indicator shapes
	@IBInspectable public var pageIndicatorWidth: CGFloat = 20 {
		didSet {
			if let s = self.indicatorShape as? HorizontalIndicatorShape {
				s.size = CGSize(width: pageIndicatorWidth, height: s.size.height)
			}
			if let s = self.indicatorShape as? VerticalIndicatorShape {
				s.size = CGSize(width: pageIndicatorWidth, height: s.size.height)
			}
			self.rebuildDotLayers()
		}
	}

	/// The height of each page indicator. Only applies to the default indicator shapes
	@IBInspectable public var pageIndicatorHeight: CGFloat = 20 {
		didSet {
			if let s = self.indicatorShape as? HorizontalIndicatorShape {
				s.size = CGSize(width: s.size.width, height: pageIndicatorHeight)
			}
			if let s = self.indicatorShape as? VerticalIndicatorShape {
				s.size = CGSize(width: s.size.width, height: pageIndicatorHeight)
			}
			self.rebuildDotLayers()
		}
	}

	/// The size of the dot. Only applies to the default indicator shapes
	@IBInspectable public var dotSize: CGFloat = 8 {
		didSet {
			if let s = self.indicatorShape as? HorizontalIndicatorShape {
				s.dotSize = self.dotSize
			}
			if let s = self.indicatorShape as? VerticalIndicatorShape {
				s.dotSize = self.dotSize
			}
			self.rebuildDotLayers()
		}
	}

	////////

	/// Create
	@objc override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	/// Create
	@objc required public init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	deinit {
		DSFAppearanceCache.shared.deregister(self)
	}

	// Private

	// Internal page count
	private var _pageCount: Int = 0

	// Internal selected value.
	private var _selected: Int = 0 {
		didSet {
			self.selectionDidChange()
			self.delegate?.pagerControl(self, didMoveToPage: self._selected)

			if oldValue == 0 || self._selected == 0 {
				self.willChangeValue(for: \.isFirstPage)
				self.didChangeValue(for: \.isFirstPage)
			}

			if oldValue == self.pageCount - 1 || self._selected == self.pageCount - 1 {
				self.willChangeValue(for: \.isLastPage)
				self.didChangeValue(for: \.isLastPage)
			}
		}
	}

	// The layers currently on display
	internal var dotLayers: [PageIndicatorLayer] = []

	// The frame containing the dots
	var dotsFrame: CGRect {
		guard let first = self.dotLayers.first else { return .zero }
		return self.dotLayers.dropFirst().reduce(first.frame) { partialResult, l in
			partialResult.union(l.frame)
		}
	}

	// Tracking area for cursor changes
	private var trackingArea: NSTrackingArea?
}

// MARK: - Layout and display

public extension DSFPagerControl {

	override var isFlipped: Bool {
		return true
	}

	override var wantsUpdateLayer: Bool {
		return true
	}

	override var intrinsicContentSize: NSSize {
		let i = self.indicatorShape
		switch i.orientation {
		case .horizontal:
			return CGSize(width: i.size.width * CGFloat(self.pageCount), height: i.size.height)
		case .vertical:
			return CGSize(width: i.size.height, height: i.size.height * CGFloat(self.pageCount))
		}
	}

	override func updateLayer() {
		super.updateLayer()
		self.relayoutLayers()
	}

	override func prepareForInterfaceBuilder() {
		self.rebuildDotLayers()
		self.selectionDidChange()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let t = self.trackingArea {
			self.removeTrackingArea(t)
		}

		if !self.allowsMouseSelection {
			return
		}

		self.trackingArea = NSTrackingArea(
			rect: self.dotsFrame,
			options: [.mouseEnteredAndExited, .activeInActiveApp],
			owner: self,
			userInfo: nil)
		self.addTrackingArea(self.trackingArea!)
	}
}

extension DSFPagerControl: DSFAppearanceCacheNotifiable {

	func setup() {

		self.wantsLayer = true
		self.layerContentsRedrawPolicy = .duringViewResize

		// Detect system changes that will potentially affect our colors
		DSFAppearanceCache.shared.register(self)

		self.rebuildDotLayers()
	}

	public func appearanceDidChange() {
		self.colorsDidChange()
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
			let dl = PageIndicatorLayer(index: index, parent: self)
			self.layer!.addSublayer(dl)
			self.dotLayers.append(dl)
		}
		self.relayoutLayers()

		self.invalidateIntrinsicContentSize()

		self.selectionDidChange()
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
		let i = self.indicatorShape

		CATransaction.withDisabledActions(DSFAppearanceManager.ReduceMotion) {
			switch i.orientation {
			case .horizontal:
				let w = (self.bounds.width - (i.size.width * CGFloat(self.dotLayers.count))) / 2
				var xOff: CGFloat = 0
				self.dotLayers.forEach { l in
					l.frame = CGRect(x: w + xOff, y: 0, width: i.size.width, height: i.size.height)
					xOff += i.size.width
				}
			case .vertical:
				let h = (self.bounds.height - (i.size.height * CGFloat(self.dotLayers.count))) / 2
				var yOff: CGFloat = 0
				self.dotLayers.forEach { l in
					l.frame = CGRect(x: 0, y: h + yOff, width: i.size.width, height: i.size.height)
					yOff += i.size.height
				}
			}
		}
	}
}


// MARK: - Page changing

public extension DSFPagerControl {

	/// Is the selected page the first page?
	@objc dynamic var isFirstPage: Bool {
		return self.selectedPage == 0
	}

	/// Is the selected page the last page?
	@objc dynamic var isLastPage: Bool {
		return self.selectedPage == self.pageCount - 1
	}

	/// Move to the next page in the pager. If the current page is the last page, does nothing.
	///
	/// Will call the delegate methods to validate the change
	@objc func moveToNextPage() {
		self.moveToPage(self.clamped(self.selectedPage + 1))
	}

	/// Move to the previous page in the pager. If the current page is the first page, does nothing
	///
	/// Will call the delegate methods to validate the change
	@objc func moveToPreviousPage() {
		self.moveToPage(self.clamped(self.selectedPage - 1))
	}
}

internal extension DSFPagerControl {
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

	// Clamp page to the current page count
	func clamped(_ page: Int) -> Int {
		max(0, min(self.pageCount - 1, page))
	}
}

extension DSFPagerControl {
	var _selectedFillColor: NSColor {
		if let s = self.selectedColorBlock {
			return s()
		}
		return .textColor
	}
	var _unselectedStrokeColor: NSColor {
		if let s = self.unselectedColorBlock {
			return s()
		}
		return DSFAppearanceManager.IsDark
			? NSColor(deviceWhite: 0.3, alpha: 1)   // .darkGray
			: NSColor(deviceWhite: 0.75, alpha: 1)  // .lightGray
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
	class PageIndicatorLayer: CAShapeLayer {
		let index: Int
		unowned var parent: DSFPagerControl

		var isSelected: Bool = false {
			didSet {
				self.updateDisplay()
			}
		}

		init(index: Int, parent: DSFPagerControl) {
			self.index = index
			self.parent = parent
			super.init()
			self.setup()
		}

		override init(layer: Any) {
			guard let e = layer as? DSFPagerControl.PageIndicatorLayer else {
				fatalError()
			}
			self.parent = e.parent
			self.index = e.index
			self.isSelected = e.isSelected
			super.init(layer: layer)
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func setup() {
			self.updateDisplay()
		}

		func updateDisplay() {
			CATransaction.withDisabledActions(DSFAppearanceManager.ReduceMotion) {

				self.parent.usingEffectiveAppearance {
					if self.isSelected {
						self.fillColor = self.parent._selectedFillColor.cgColor
						self.strokeColor = self.parent._selectedFillColor.cgColor
					}
					else {
						if DSFAppearanceManager.IncreaseContrast {
							self.strokeColor = self.parent._selectedFillColor.cgColor
							self.fillColor = nil
							self.lineWidth = 1
						}
						else if self.parent.bordered {
							self.strokeColor = self.parent._selectedFillColor.cgColor
							self.fillColor = self.parent._unselectedStrokeColor.cgColor
							self.lineWidth = 0.5
						}
						else {
							self.fillColor = self.parent._unselectedStrokeColor.cgColor
							self.strokeColor = self.parent._unselectedStrokeColor.cgColor
						}
					}
				}
			}
		}

		override func layoutSublayers() {
			super.layoutSublayers()
			self.path = self.parent.indicatorShape.path(
				selectedPage: index,
				totalPageCount: self.parent.pageCount
			)
		}
	}
}

#endif
