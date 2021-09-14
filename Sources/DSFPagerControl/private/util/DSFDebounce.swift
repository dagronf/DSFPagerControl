
import Foundation
import Dispatch

public class DSFDebounce {
	
	// MARK: - Properties
	private let queue = DispatchQueue.main
	private var workItem = DispatchWorkItem(block: {})
	private var interval: TimeInterval
	
	// MARK: - Initializer
	init(seconds: TimeInterval) {
		self.interval = seconds
	}
	
	// MARK: - Debouncing function
	func debounce(action: @escaping (() -> Void)) {
		workItem.cancel()
		workItem = DispatchWorkItem(block: { action() })
		queue.asyncAfter(deadline: .now() + interval, execute: workItem)
	}
}




extension DispatchQueue {
	
	/**
	 - parameters:
	 - target: Object used as the sentinel for de-duplication.
	 - delay: The time window for de-duplication to occur
	 - work: The work item to be invoked on the queue.
	 Performs work only once for the given target, given the time window. The last added work closure
	 is the work that will finally execute.
	 Note: This is currently only safe to call from the main thread.
	 Example usage:
	 ```
	 DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
	 self?.doTheWork()
	 }
	 ```
	 */
	public func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
		let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
		if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
			existingWorkItem.cancel()
			NSLog("Deduped work item: \(dedupeIdentifier)")
		}
		let workItem = DispatchWorkItem {
			DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)
			
			for ptr in DispatchQueue.weakTargets.allObjects {
				if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
					work()
					NSLog("Ran work item: \(dedupeIdentifier)")
					break
				}
			}
		}
		
		DispatchQueue.workItems[dedupeIdentifier] = workItem
		DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())
		
		asyncAfter(deadline: .now() + delay, execute: workItem)
	}
	
}

// MARK: - Static Properties for De-Duping
private extension DispatchQueue {
	
	static var workItems = [AnyHashable : DispatchWorkItem]()
	
	static var weakTargets = NSPointerArray.weakObjects()
	
	static func dedupeIdentifierFor(_ object: AnyObject) -> String {
		return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
	}
	
}
