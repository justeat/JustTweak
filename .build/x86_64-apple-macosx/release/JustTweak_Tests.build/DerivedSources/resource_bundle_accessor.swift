import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("JustTweak_JustTweak_Tests.bundle").path
        let buildPath = "/Users/marium.hassan/JustTweak/.build/x86_64-apple-macosx/release/JustTweak_JustTweak_Tests.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}