import Foundation

/// Loads bundled shloka content into `[Shloka]`.
///
/// Phase 0 is a stub returning the hardcoded samples — the real `gita.json` and the build-time
/// fetch pipeline (RapidAPI via MCP) are Phase 1 (impl plan §7 Milestone 1, gita-security.md §5).
/// The interface exists now so views/stores depend on it rather than on `ContentStore.sampleShlokas`
/// directly, making the Phase 1 swap a one-line change.
public struct ContentLoader: Sendable {
    public init() {}

    /// Phase 1 will decode `gita.json` from the given bundle. For now, return the samples.
    public func load(from bundle: Bundle = .main) -> [Shloka] {
        // Phase 1:
        //   guard let url = bundle.url(forResource: "gita", withExtension: "json"),
        //         let data = try? Data(contentsOf: url) else { return [] }
        //   return (try? JSONDecoder().decode([Shloka].self, from: data)) ?? []
        ContentStore.sampleShlokas
    }
}
