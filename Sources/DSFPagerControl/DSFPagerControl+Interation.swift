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

import Carbon.HIToolbox

// MARK: - Keyboard and mouse handing

public extension DSFPagerControl {

	override var acceptsFirstResponder: Bool {
		return self.allowsKeyboardFocus && self.isEnabled
	}

	override func drawFocusRingMask() {
		let pth = NSBezierPath(roundedRect: self.dotsFrame, xRadius: 4, yRadius: 4)
		pth.fill()
	}

	override var focusRingMaskBounds: NSRect {
		return self.dotsFrame
	}

	override func keyDown(with event: NSEvent) {
		switch Int(event.keyCode) {
		case kVK_LeftArrow, kVK_UpArrow:
			self.moveToPreviousPage()
		case kVK_RightArrow, kVK_DownArrow:
			self.moveToNextPage()

		case kVK_ANSI_0, kVK_ANSI_Keypad0: self.selectedPage = self.clamped(0)
		case kVK_ANSI_1, kVK_ANSI_Keypad1: self.selectedPage = self.clamped(1)
		case kVK_ANSI_2, kVK_ANSI_Keypad2: self.selectedPage = self.clamped(2)
		case kVK_ANSI_3, kVK_ANSI_Keypad3: self.selectedPage = self.clamped(3)
		case kVK_ANSI_4, kVK_ANSI_Keypad4: self.selectedPage = self.clamped(4)
		case kVK_ANSI_5, kVK_ANSI_Keypad5: self.selectedPage = self.clamped(5)
		case kVK_ANSI_6, kVK_ANSI_Keypad6: self.selectedPage = self.clamped(6)
		case kVK_ANSI_7, kVK_ANSI_Keypad7: self.selectedPage = self.clamped(7)
		case kVK_ANSI_8, kVK_ANSI_Keypad8: self.selectedPage = self.clamped(8)
		case kVK_ANSI_9, kVK_ANSI_Keypad9: self.selectedPage = self.clamped(9)

		default:
			super.keyDown(with: event)
		}
	}

	override func mouseDown(with event: NSEvent) {
		if !self.isEnabled || self.allowsMouseSelection == false {
			super.mouseDown(with: event)
			return
		}

		let point = self.convert(event.locationInWindow, from: nil)
		guard let whichLayer = self.dotLayers.first(where: { $0.frame.contains(point) }) else {
			super.mouseDown(with: event)
			return
		}

		self.moveToPage(whichLayer.index)
	}
}

#endif
