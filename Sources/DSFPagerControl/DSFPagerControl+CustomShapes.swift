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

public extension DSFPagerControl {
	/// Default horizontal page indicator
	@objc class HorizontalIndicatorShape: NSObject, DSFPagerControlIndicatorShape {
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
	@objc class VerticalIndicatorShape: NSObject, DSFPagerControlIndicatorShape {
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

public extension DSFPagerControl {
	/// Mini dots
	class MiniDotsShape: DSFPagerControlIndicatorShape {
		public init() {}
		public var orientation: DSFPagerControl.Orientation { .horizontal }
		public var size: CGSize { CGSize(width: 10, height: 10) }
		@objc public func path(selectedPage: Int, totalPageCount: Int) -> CGPath {
			CGPath(ellipseIn: CGRect(x: 2.5, y: 2.5, width: 5, height: 5), transform: nil)
		}
	}

	/// A thin horizontal line of horizontal rects with capped ends
	class ThinHorizontalPillShape: DSFPagerControlIndicatorShape {
		public init() { }
		public var orientation: DSFPagerControl.Orientation { .horizontal }
		public var size: CGSize { CGSize(width: 30, height: 8) }
		@objc public func path(selectedPage: Int, totalPageCount: Int) -> CGPath {
			let rectangleRect = CGRect(origin: .zero, size: size).insetBy(dx: 1.5, dy: 2)
			if selectedPage == totalPageCount - 1 {
				let maxshapeCornerRadius: CGFloat = 2
				let maxshapeRect = rectangleRect
				let maxshapeInnerRect = maxshapeRect.insetBy(dx: maxshapeCornerRadius, dy: maxshapeCornerRadius)
				let maxshapePath = NSBezierPath()
				maxshapePath.move(to: NSPoint(x: maxshapeRect.minX, y: maxshapeRect.minY))
				maxshapePath.appendArc(withCenter: NSPoint(x: maxshapeInnerRect.maxX, y: maxshapeInnerRect.minY), radius: maxshapeCornerRadius, startAngle: 270, endAngle: 360)
				maxshapePath.appendArc(withCenter: NSPoint(x: maxshapeInnerRect.maxX, y: maxshapeInnerRect.maxY), radius: maxshapeCornerRadius, startAngle: 0, endAngle: 90)
				maxshapePath.line(to: NSPoint(x: maxshapeRect.minX, y: maxshapeRect.maxY))
				maxshapePath.close()
				return maxshapePath.makeCGPath()
			}
			else if selectedPage == 0 {
				let minshapeCornerRadius: CGFloat = 2
				let minshapeRect = rectangleRect
				let minshapeInnerRect = minshapeRect.insetBy(dx: minshapeCornerRadius, dy: minshapeCornerRadius)
				let minshapePath = NSBezierPath()
				minshapePath.appendArc(withCenter: NSPoint(x: minshapeInnerRect.minX, y: minshapeInnerRect.minY), radius: minshapeCornerRadius, startAngle: 180, endAngle: 270)
				minshapePath.line(to: NSPoint(x: minshapeRect.maxX, y: minshapeRect.minY))
				minshapePath.line(to: NSPoint(x: minshapeRect.maxX, y: minshapeRect.maxY))
				minshapePath.appendArc(withCenter: NSPoint(x: minshapeInnerRect.minX, y: minshapeInnerRect.maxY), radius: minshapeCornerRadius, startAngle: 90, endAngle: 180)
				minshapePath.close()
				return minshapePath.makeCGPath()
			}
			else {
				return CGPath(rect: rectangleRect, transform: nil)
			}
		}
	}

	/// A thin horizontal line of horizontal rounded rects
	class ThinHorizontalRoundedShape: DSFPagerControlIndicatorShape {
		public init() { }
		public var orientation: DSFPagerControl.Orientation { .horizontal }
		public var size: CGSize { CGSize(width: 30, height: 8) }
		@objc public func path(selectedPage: Int, totalPageCount: Int) -> CGPath {
			let rectangleRect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
			return CGPath(roundedRect: rectangleRect, cornerWidth: 2, cornerHeight: 2, transform: nil)
		}
	}
}

#endif
