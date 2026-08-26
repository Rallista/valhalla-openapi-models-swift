import XCTest
@testable import ValhallaConfigModels

/// Pins these models against a real valhalla config.
///
/// `Resources/valhalla-default.json` is the output of valhalla's own
/// `scripts/valhalla_build_config`, copied from valhalla-mobile, which generates it from the
/// version of valhalla it is pinned to.
///
/// Every key valhalla writes has to survive a round trip through these models. When it does not,
/// the config an app hands to the engine quietly loses settings: three misspelled keys
/// (`heirarchy_limits`, `max_interations`, `allow_modifications`) used to drop all 32 of the
/// hierarchy-limit keys on the floor, on both platforms, without any error.
///
/// A failure here means the spec has drifted from valhalla. Refresh the fixture from
/// valhalla-mobile's `scripts/generate_default_config.sh`, then reconcile `openapi.yaml` with it.
final class TestDefaultConfigCoverage: XCTestCase {

    private func defaultConfigData() throws -> Data {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "valhalla-default", withExtension: "json"),
            "valhalla-default.json is missing from the test resources"
        )
        return try Data(contentsOf: url)
    }

    /// Nothing valhalla wrote is missing after a decode and a re-encode.
    ///
    /// `JSONDecoder` ignores a key it does not know, so a decode on its own proves nothing —
    /// which is exactly how the misspellings went unnoticed. Comparing the key paths either side
    /// of a round trip is what makes a dropped key visible.
    func testRoundTripKeepsEveryKey() throws {
        let original = try defaultConfigData()

        let config = try JSONDecoder().decode(ValhallaConfig.self, from: original)
        let roundTripped = try JSONEncoder().encode(config)

        let before = try keyPaths(of: original)
        let after = try keyPaths(of: roundTripped)

        // Only one direction is asserted. Encoding also writes keys valhalla left out, because it
        // omits values that are empty and the models carry a default for them regardless.
        let lost = before.subtracting(after)
        XCTAssertEqual(lost, [], "these keys did not survive the round trip: \(lost.sorted())")
    }

    /// The hierarchy limits in particular, since those are what the misspelling dropped.
    func testHierarchyLimitsSurvive() throws {
        let config = try JSONDecoder().decode(ValhallaConfig.self, from: try defaultConfigData())

        XCTAssertNotNil(config.thor?.costmatrix?.hierarchyLimits)
        XCTAssertNotNil(config.thor?.bidirectionalAstar?.hierarchyLimits)
        XCTAssertNotNil(config.thor?.unidirectionalAstar?.hierarchyLimits)
        XCTAssertEqual(config.thor?.costmatrix?.maxIterations, 2800)
        XCTAssertEqual(config.serviceLimits?.hierarchyLimits?.allowModification, false)
    }

    /// `tile_url` and `tile_url_gz` are what a tile-fetching config is expressed with.
    func testTileUrlKeysAreModelled() throws {
        var config = try JSONDecoder().decode(ValhallaConfig.self, from: try defaultConfigData())
        config.mjolnir?.tileUrl = "https://tiles.example/{tilePath}"
        config.mjolnir?.tileUrlGz = true

        let encoded = try keyPaths(of: try JSONEncoder().encode(config))

        XCTAssertTrue(encoded.contains("mjolnir.tile_url"))
        XCTAssertTrue(encoded.contains("mjolnir.tile_url_gz"))
    }

    /// Every leaf path in the document, as dotted keys.
    private func keyPaths(of data: Data) throws -> Set<String> {
        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        return keyPaths(of: object)
    }

    private func keyPaths(of object: [String: Any], prefix: String = "") -> Set<String> {
        var paths: Set<String> = []
        for (key, value) in object {
            let path = prefix.isEmpty ? key : "\(prefix).\(key)"
            if let nested = value as? [String: Any] {
                paths.formUnion(keyPaths(of: nested, prefix: path))
            } else {
                paths.insert(path)
            }
        }
        return paths
    }
}
