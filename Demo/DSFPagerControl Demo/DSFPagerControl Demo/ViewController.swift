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

	override func viewDidLoad() {
		super.viewDidLoad()

		imagePager.selectedPage = 0
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
		nextPageButton.isEnabled = !imagePager.isLastPage
		previousPageButton.isEnabled = !imagePager.isFirstPage
	}

	@IBAction func prevPage(_ sender: Any) {
		imagePager.moveToPreviousPage()
		updateDisplay()
	}

	@IBAction func nextPage(_ sender: Any) {
		imagePager.moveToNextPage()
		updateDisplay()
	}
}

extension ViewController: DSFPagerControlHandling {
	func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool {
		Swift.print("Wanting to change to page \(page)...")
		return true
	}

	func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int) {
		Swift.print("... New page is now \(page)")
	}
}
