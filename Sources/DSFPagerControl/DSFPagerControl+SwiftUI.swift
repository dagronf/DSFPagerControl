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

	private let allowsMouseSelection: Bool
	private let allowsKeyboardSelection: Bool
	private let selectedColor: Color?
	private let unselectedColor: Color?
	private let bordered: Bool
	private let orientation: DSFPagerControl.Orientation

	/// <#Description#>
	/// - Parameters:
	///   - orientation: The orientation for the control
	///   - pageCount: The number of pages
	///   - selectedPage: The selected page
	///   - allowsMouseSelection: Allows the control to be controlled by the mouse
	///   - allowsKeyboardSelection: Allows the control to be focused and controlled by the keyboard
	///   - selectedColor: The color to draw the selected page indicator
	///   - unselectedColor: The color to draw an unselected page indicator
	///   - bordered: If true, draws a border around unselected page indicators
	public init(
		orientation: DSFPagerControl.Orientation = .horizontal,
		pageCount: Int,
		selectedPage: Binding<Int>,
		allowsMouseSelection: Bool = false,
		allowsKeyboardSelection: Bool = false,
		selectedColor: Color? = nil,
		unselectedColor: Color? = nil,
		bordered: Bool = false
	) {
		self.pageCount = pageCount
		self._selectedPage = selectedPage
		self.selectedColor = selectedColor
		self.unselectedColor = unselectedColor
		self.orientation = orientation
		self.allowsMouseSelection = allowsMouseSelection
		self.allowsKeyboardSelection = allowsKeyboardSelection
		self.bordered = bordered
	}

	public func makeNSView(context: Context) -> DSFPagerControl {
		let p = DSFPagerControl()
		p.delegate = context.coordinator
		context.coordinator.parent = self
		p.translatesAutoresizingMaskIntoConstraints = false
		p.setContentHuggingPriority(.required, for: .vertical)
		p.setContentHuggingPriority(.required, for: .horizontal)

		self.sync(p)

		p.needsLayout = true

		return p
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	public func updateNSView(_ nsView: DSFPagerControl, context: Context) {
		context.coordinator.parent = self
		self.sync(nsView)
	}

	func sync(_ nsView: DSFPagerControl) {
		DispatchQueue.main.async {
			self._sync(nsView)
		}
	}

	func _sync(_ nsView: DSFPagerControl) {
		if self.pageCount != nsView.pageCount {
			nsView.pageCount = self.pageCount
		}

		if self.selectedPage != nsView.selectedPage {
			nsView.selectedPage = self.selectedPage
		}

		if self.orientation != nsView.orientation {
			nsView.orientation = self.orientation
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
