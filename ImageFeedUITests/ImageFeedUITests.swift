//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Максим on 14.06.2023.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так

        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        // тестируем сценарий авторизации
        sleep(5)
        let enterButton = app.buttons["enterButton"]
        XCTAssert(enterButton.exists)
        enterButton.tap()
        sleep(5)
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        app.toolbars["Toolbar"].buttons["Done"].tap()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        app.toolbars["Toolbar"].buttons["Done"].tap()

        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()


        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        print(app.debugDescription)
    }

    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(3)

        tablesQuery.element.swipeUp()
        tablesQuery.element.swipeDown()

        let firstCell = tablesQuery.cells.element(boundBy: 0)
        let likeButton = firstCell.buttons["LikeButton"]
        likeButton.tap()
        sleep(3)

        likeButton.tap()
        sleep(3)

        firstCell.tap()
        sleep(5)

        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        sleep(3)

        image.pinch(withScale: 0.5, velocity: -1)
        sleep(3)

        app.buttons["BackButton"].tap()
        sleep(3)
    }

    func testProfile() throws {
        // тестируем сценарий профиля
        let imagesListTab = app.tabBars.buttons["ImagesList"]
        XCTAssertTrue(imagesListTab.waitForExistence(timeout: 5))

        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        sleep(3)

        let nameLabel = app.staticTexts["NameLabel"]
        let loginLabel = app.staticTexts["loginNameLabel"]
        //let descriptionLabel = app.staticTexts["DescriptionLabel"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5))
        //XCTAssertTrue(descriptionLabel.waitForExistence(timeout: 5))

        let logoutButton = app.buttons["LogoutButton"]
        logoutButton.tap()
        sleep(3)

        let alert = app.alerts["Пока, Пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        let confirmButton = alert.buttons["yesAction"]
        confirmButton.tap()
        sleep(3)

        XCTAssertTrue(app.staticTexts["Войти"].exists)
    }
}
