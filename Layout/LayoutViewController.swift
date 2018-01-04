//  Copyright © 2017 Schibsted. All rights reserved.

import UIKit

open class LayoutViewController: UIViewController, LayoutLoading, LayoutDelegate {

    @objc open var layoutNode: LayoutNode? {
        didSet {
            if layoutNode?._viewController == self {
                // TODO: should this use case be allowed at all?
                return
            }
            oldValue?.unmount()
            if let layoutNode = layoutNode {
                do {
                    try layoutNode.mount(in: self)
                    try layoutNode.throwUnhandledError()
                    layoutDidLoad(layoutNode)
                } catch {
                    layoutError(LayoutError(error, for: layoutNode))
                }
            }
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layoutNode = layoutNode {
            layoutNode.performWithoutUpdate {
                layoutNode.view.frame = view.bounds
            }
            layoutNode.update()
        }
    }

    /// Called immediately after the layoutNode is set. Will not be called
    /// in the event of an error, or if layoutNode is set to nil
    open func layoutDidLoad(_: LayoutNode) {
        // Mimic old behaviour if not overriden
        layoutDidLoad()
    }

    /// Called immediately after the layoutNode is set. Will not be called
    /// in the event of an error, or if layoutNode is set to nil
    @available(*, deprecated, message: "Use layoutDidLoad(_ layoutNode:) instead")
    open func layoutDidLoad() {
        // Override in subclass
    }

    open func layoutError(_ error: LayoutError) {
        LayoutConsole.showError(error)
    }
}
