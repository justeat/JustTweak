//  Bundle+JustTweak.swift

import Foundation

public extension Bundle {
    class var justTweak: Bundle {
#if SWIFT_PACKAGE
        Bundle.module
#else
        Bundle(identifier: "org.cocoapods.JustTweak")!
#endif
    }
}
