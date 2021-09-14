//
//  ViewController.swift
//  DSFPagerControl Demo
//
//  Created by Darren Ford on 14/9/21.
//

import Cocoa
import DSFPagerControl

class ViewController: NSViewController {

	@IBOutlet weak var customHorizontal: DSFPagerControl!
	@IBOutlet weak var customVertical: DSFPagerControl!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		customHorizontal.selectedFillColorBlock = {
			return .systemPink
		}
		customHorizontal.unselectedStrokeColorBlock = {
			return .systemPurple
		}

		customVertical.selectedFillColorBlock = {
			return .systemTeal
		}
		customVertical.unselectedStrokeColorBlock = {
			return .systemBlue
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
