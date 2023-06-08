//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Максим on 08.06.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService()

        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }

        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)

        XCTAssertEqual(service.photos.count, 10)
    }
}
