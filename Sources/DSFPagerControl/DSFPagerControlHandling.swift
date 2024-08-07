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

/// The pager delegate protocol
@objc public protocol DSFPagerControlHandling: NSObjectProtocol {
	/// Called when the pager has been asked to change to a new page. Return false to cancel the change
	@objc func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool
	/// Called when the pager changed to a new page
	@objc func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int)
}

public extension DSFPagerControlHandling {
	func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool {
		// Default implementation -- Always a valid change
		return true
	}
}

#endif
