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
}
