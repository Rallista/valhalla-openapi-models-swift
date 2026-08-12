import XCTest
@testable import ValhallaModels

public class ValhallaElevationTests: XCTestCase {

    private func encodedJSON(_ value: some Encodable) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func testRouteRequestWithElevationInterval() throws {
        let request = RouteRequest(
            locations: [
                RoutingWaypoint(lat: 45.843812, lon: -123.768205),
                RoutingWaypoint(lat: 45.869701, lon: -123.766121),
            ],
            costing: .auto,
            elevationInterval: 30
        )

        let json = try encodedJSON(request)

        XCTAssertEqual(json["elevation_interval"] as? Double, 30)
    }

    func testRouteRequestWithoutElevationIntervalOmitsIt() throws {
        let request = RouteRequest(
            locations: [
                RoutingWaypoint(lat: 45.843812, lon: -123.768205),
                RoutingWaypoint(lat: 45.869701, lon: -123.766121),
            ],
            costing: .auto
        )

        let json = try encodedJSON(request)

        XCTAssertNil(json["elevation_interval"])
    }

    func testMapMatchRequestWithElevationInterval() throws {
        let request = MapMatchRequest(
            encodedPolyline: "_grbgAh~{nhF?lBAzBFvB",
            costing: .pedestrian,
            elevationInterval: 30
        )

        let json = try encodedJSON(request)

        XCTAssertEqual(json["elevation_interval"] as? Double, 30)
    }

    func testRouteLegWithElevation() throws {
        let json = """
        {
          "maneuvers": [],
          "shape": "_grbgAh~{nhF?lBAzBFvB",
          "elevation_interval": 30.0,
          "elevation": [329.1, 331.4, 334.0],
          "summary": {
            "time": 120.0,
            "length": 1.2,
            "min_lat": 45.843812,
            "max_lat": 45.869701,
            "min_lon": -123.768205,
            "max_lon": -123.766121
          }
        }
        """

        let leg = try JSONDecoder().decode(RouteLeg.self, from: XCTUnwrap(json.data(using: .utf8)))

        XCTAssertEqual(leg.elevationInterval, 30)
        XCTAssertEqual(leg.elevation, [329.1, 331.4, 334.0])
    }

    func testRouteLegWithoutElevation() throws {
        let json = """
        {
          "maneuvers": [],
          "shape": "_grbgAh~{nhF?lBAzBFvB",
          "summary": {
            "time": 120.0,
            "length": 1.2,
            "min_lat": 45.843812,
            "max_lat": 45.869701,
            "min_lon": -123.768205,
            "max_lon": -123.766121
          }
        }
        """

        let leg = try JSONDecoder().decode(RouteLeg.self, from: XCTUnwrap(json.data(using: .utf8)))

        XCTAssertNil(leg.elevationInterval)
        XCTAssertNil(leg.elevation)
    }
}
