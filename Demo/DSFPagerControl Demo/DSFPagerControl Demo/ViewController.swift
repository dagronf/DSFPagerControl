//
//  ViewController.swift
//  DSFPagerControl Demo
//
//  Created by Darren Ford on 14/9/21.
//

import Cocoa
import DSFPagerControl

class ViewController: NSViewController {

	@IBOutlet weak var imagePager: DSFPagerControl!
	@IBOutlet weak var previousPageButton: NSButton!
	@IBOutlet weak var nextPageButton: NSButton!

	@objc dynamic var imagePagerSelection: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()

		imagePager.selectedPage = self.imagePagerSelection
		updateDisplay()

		// Do any additional setup after loading the view.

		// Custom color blocks can be defined for customizing the colors

//		customHorizontal.selectedColorBlock = {
//			return .systemPink
//		}
//		customHorizontal.unselectedColorBlock = {
//			return .systemPurple
//		}
//
//		customVertical.selectedColorBlock = {
//			return .systemTeal
//		}
//		customVertical.unselectedColorBlock = {
//			return .systemBlue
//		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	func updateDisplay() {
		nextPageButton.isEnabled = imagePagerSelection < imagePager.pageCount - 1
		previousPageButton.isEnabled = imagePagerSelection > 0
	}

	@IBAction func prevPage(_ sender: Any) {
		imagePagerSelection -= 1
		imagePager.selectedPage = imagePagerSelection
		updateDisplay()
	}

	@IBAction func nextPage(_ sender: Any) {
		imagePagerSelection += 1
		imagePager.selectedPage = imagePagerSelection
		updateDisplay()
	}
}

extension ViewController: DSFPagerControlHandling {
	func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool {
		Swift.print("Want to change to page \(page)...")
		return true
	}

	func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int) {
		Swift.print("... New page is now \(page)")
	}


}
