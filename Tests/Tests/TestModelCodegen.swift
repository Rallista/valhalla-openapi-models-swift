import XCTest
@testable import ValhallaModels
@testable import ValhallaConfigModels

public class ValhallaModelsTests: XCTestCase {
    
    func testInitFromConfig() {
        let additionalData = AdditionalData()
        XCTAssertEqual(additionalData.elevation, "/custom_files/elevation_data")
    }
    
    func testFromModels() {
        let administrative = Administrative()
        XCTAssertNil(administrative.country)
    }

    func testHeightResponseDecodesNullAndDecimalHeights() throws {
        let json = Data(#"{"height":[100.5,null,37],"range_height":[[0,100.5],[50.2,null]]}"#.utf8)
        let response = try JSONDecoder().decode(HeightResponse.self, from: json)
        XCTAssertEqual(response.height, [100.5, nil, 37])
        XCTAssertEqual(response.rangeHeight, [[0, 100.5], [50.2, nil]])

        let reencoded = try JSONDecoder().decode(
            HeightResponse.self, from: JSONEncoder().encode(response))
        XCTAssertEqual(reencoded, response)
    }

    /// `sources`/`targets` come back as one location per source/target, in request order - not
    /// nested per row like `sources_to_targets`. A response modeled with the nested shape fails
    /// to decode Valhalla's actual output, which is how this was found: valhalla-mobile's typed
    /// `matrix(request:)` wrapper threw against a real engine response
    /// (Rallista/valhalla-mobile#107).
    func testMatrixResponseDecodesFlatSourcesAndTargets() throws {
        let json = Data(#"""
            {
              "sources": [{"lat":40.744014,"lon":-73.990508},{"lat":40.739735,"lon":-73.979713}],
              "targets": [{"lat":40.752522,"lon":-73.985015}],
              "sources_to_targets": [[{"distance":1.2,"time":300,"from_index":0,"to_index":0}],
                                      [{"distance":0.0,"time":0,"from_index":1,"to_index":0}]],
              "units": "kilometers"
            }
            """#.utf8)

        let response = try JSONDecoder().decode(MatrixResponse.self, from: json)

        XCTAssertEqual(
            response.sources,
            [Coordinate(lat: 40.744014, lon: -73.990508), Coordinate(lat: 40.739735, lon: -73.979713)])
        XCTAssertEqual(response.targets, [Coordinate(lat: 40.752522, lon: -73.985015)])
        XCTAssertEqual(response.sourcesToTargets[0][0].distance, 1.2)
        XCTAssertEqual(response.sourcesToTargets[1][0].distance, 0.0)
    }
}
