//
//  DSFPagerControl+SwiftUI.swift
//  DSFPagerControl
//
//  Created by Darren Ford on 20/7/2024.
//

#if os(macOS)

import SwiftUI

@available(macOS 11, *)
public struct DSFPagerControlUI: NSViewRepresentable {

	private let pageCount: Int
	@Binding private var selectedPage: Int

	private let indicatorShape: DSFPagerControlIndicatorShape
	private let allowsMouseSelection: Bool
	private let allowsKeyboardSelection: Bool
	private let selectedColor: Color?
	private let unselectedColor: Color?
	private let bordered: Bool
	private let disabled: Bool

	/// Create a pager control
	/// - Parameters:
	///   - indicatorShape: The shape for the page indicators
	///   - pageCount: The number of pages
	///   - selectedPage: The selected page
	///   - allowsMouseSelection: Allows the control to be controlled by the mouse
	///   - allowsKeyboardSelection: Allows the control to be focused and controlled by the keyboard
	///   - selectedColor: The color to draw the selected page indicator
	///   - unselectedColor: The color to draw an unselected page indicator
	///   - bordered: If true, draws a border around unselected page indicators
	public init(
		indicatorShape: DSFPagerControlIndicatorShape = DSFPagerControl.HorizontalIndicatorShape(),
		pageCount: Int,
		selectedPage: Binding<Int>,
		allowsMouseSelection: Bool = false,
		allowsKeyboardSelection: Bool = false,
		selectedColor: Color? = nil,
		unselectedColor: Color? = nil,
		bordered: Bool = false,
		disabled: Bool = false
	) {
		self.indicatorShape = indicatorShape
		self.pageCount = pageCount
		self._selectedPage = selectedPage
		self.selectedColor = selectedColor
		self.unselectedColor = unselectedColor
		self.allowsMouseSelection = allowsMouseSelection
		self.allowsKeyboardSelection = allowsKeyboardSelection
		self.bordered = bordered
		self.disabled = disabled
	}

	public init(
		orientation: DSFPagerControl.Orientation,
		pageCount: Int,
		selectedPage: Binding<Int>,
		allowsMouseSelection: Bool = false,
		allowsKeyboardSelection: Bool = false,
		selectedColor: Color? = nil,
		unselectedColor: Color? = nil,
		bordered: Bool = false,
		disabled: Bool = false
	) {
		let shape: DSFPagerControlIndicatorShape = (orientation == .horizontal)
			? DSFPagerControl.HorizontalIndicatorShape()
			: DSFPagerControl.VerticalIndicatorShape()
		self.init(
			indicatorShape: shape,
			pageCount: pageCount,
			selectedPage: selectedPage,
			allowsMouseSelection: allowsMouseSelection,
			allowsKeyboardSelection: allowsKeyboardSelection,
			selectedColor: selectedColor,
			unselectedColor: unselectedColor,
			bordered: bordered,
			disabled: disabled
		)
	}

	public func makeNSView(context: Context) -> DSFPagerControl {
		let p = DSFPagerControl()
		p.delegate = context.coordinator
		context.coordinator.parent = self
		p.translatesAutoresizingMaskIntoConstraints = false
		p.setContentHuggingPriority(.init(900), for: .vertical)
		p.setContentHuggingPriority(.init(900), for: .horizontal)

		p.pageCount = self.pageCount
		p.selectedPage = self.selectedPage
		p.indicatorShape = self.indicatorShape
		p.allowsMouseSelection = self.allowsMouseSelection
		p.allowsKeyboardFocus = self.allowsKeyboardSelection
		p.bordered = self.bordered
		p.isEnabled = !self.disabled
		if let s = self.selectedColor {
			p.selectedColor = NSColor(s)
		}
		if let s = self.unselectedColor {
			p.unselectedColor = NSColor(s)
		}

		p.needsLayout = true

		return p
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	public func updateNSView(_ nsView: DSFPagerControl, context: Context) {
		context.coordinator.parent = self

		if self.indicatorShape !== nsView.indicatorShape {
			nsView.indicatorShape = self.indicatorShape
		}

		if self.pageCount != nsView.pageCount {
			nsView.pageCount = self.pageCount
		}

		if self.selectedPage != nsView.selectedPage {
			nsView.selectedPage = self.selectedPage
		}

		if self.allowsMouseSelection != nsView.allowsMouseSelection {
			nsView.allowsMouseSelection = self.allowsMouseSelection
		}

		if self.allowsKeyboardSelection != nsView.allowsKeyboardFocus {
			nsView.allowsKeyboardFocus = self.allowsKeyboardSelection
		}

		if self.bordered != nsView.bordered {
			nsView.bordered = self.bordered
		}

		if self.disabled != !nsView.isEnabled {
			nsView.isEnabled = !self.disabled
		}

		if let c = self.selectedColor {
			nsView.selectedColor = NSColor(c)
		}
		else {
			nsView.selectedColor = nil
		}

		if let c = self.unselectedColor {
			nsView.unselectedColor = NSColor(c)
		}
		else {
			nsView.unselectedColor = nil
		}
	}

	final public class Coordinator: NSObject, DSFPagerControlHandling {

		public var parent: DSFPagerControlUI

		init(parent: DSFPagerControlUI) {
			self.parent = parent
		}

		@objc public func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool {
			return true
		}

		/// Called when the pager changed to a new page
		@objc public func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int) {
			if parent.selectedPage != page {
				DispatchQueue.main.async { [weak self] in
					self?.parent.selectedPage = page
				}
			}
		}
	}
}

@available(macOS 11, *)
struct DSFPagerControlUI_Previews: PreviewProvider {
	static var previews: some View {
		@State var selection: Int = 3
		VStack {
			HStack {
				DSFPagerControlUI(
					pageCount: 10,
					selectedPage: $selection,
					allowsMouseSelection: true
				)

				Text("\(selection)")

				Button {
					selection = 3
				} label: {
					Text("Reset")
				}
			}
			Spacer()
		}
	}
}

#endif
