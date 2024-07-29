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

@objc public protocol DSFPagerControlIndicatorShape {
	/// The orientation for the control
	@objc var orientation: DSFPagerControl.Orientation { get }
	/// The size of the page indicator
	@objc var size: CGSize { get }
	/// The path representing the page indicator
	/// - Parameters:
	///   - selectedPage: The currently selected page index
	///   - totalPageCount: The total number of pages in the control
	/// - Returns: A path
	@objc func path(selectedPage: Int, totalPageCount: Int) -> CGPath
}

public extension DSFPagerControl {
	/// The orientation for the control
	@objc(DSFPagerControlOrientation)
	enum Orientation: Int {
		/// Horizontal orientation
		case horizontal = 0
		/// Vertical orientation
		case vertical   = 1
	}
}

public extension DSFPagerControl {
	/// Default horizontal page indicator
	@objc class DefaultHorizontalIndicatorShape: NSObject, DSFPagerControlIndicatorShape {
		public var orientation: DSFPagerControl.Orientation { .horizontal }
		public var size: CGSize = CGSize(width: 20, height: 20)
		public var dotSize: CGFloat = 8
		@objc public func path(selectedPage: Int, totalPageCount: Int) -> CGPath {
			let xO = max(0, (self.size.width - self.dotSize) / 2)
			let yO = max(0, (self.size.height - self.dotSize) / 2)
			return CGPath(ellipseIn: CGRect(x: xO, y: yO, width: self.dotSize, height: self.dotSize), transform: nil)
		}
	}

	/// Default vertical page indicator
	@objc class DefaultVerticalIndicatorShape: NSObject, DSFPagerControlIndicatorShape {
		public var orientation: DSFPagerControl.Orientation { .vertical }
		public var size: CGSize = CGSize(width: 20, height: 20)
		public var dotSize: CGFloat = 8
		@objc public func path(selectedPage: Int, totalPageCount: Int) -> CGPath {
			let xO = max(0, (self.size.width - self.dotSize) / 2)
			let yO = max(0, (self.size.height - self.dotSize) / 2)
			return CGPath(ellipseIn: CGRect(x: xO, y: yO, width: self.dotSize, height: self.dotSize), transform: nil)
		}
	}
}

#endif
