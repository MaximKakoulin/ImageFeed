//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Максим on 13.06.2023.
//


import Foundation
import XCTest
@testable import ImageFeed

//MARK: - ЗАГЛУШКИ ДЛЯ ТЕСТОВ
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?

    func didLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {

    }

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
    }

    func setProgressHidden(_ isHidden: Bool) {
    }
}


//MARK: - Начало тестов
final class WebViewTests: XCTestCase {
    //MARK: - Тест № 1 - Связь webViewViewController & Presenter
    func testViewControllerCallsViewDidLoad() {
        //given
        let webViewViewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        webViewViewController.presenter = presenter
        presenter.view = webViewViewController
        //when
        _ = webViewViewController.view
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }

    //MARK: - Тест № 2 - Вызов loadRequest
    func testPresenterCallsLoadRequest () {
        //given
        let viewController = WebViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        presenter.didLoad()
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }

    //MARK: - Тест № 3 - ProgressView (меньше 0.0001)
    func testProgressVisibleLessThanOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        switch progress {
        case 1.0:
            XCTAssertTrue(shouldHideProgress)
            print("Загрузка завершена")
        case 0..<1.0:
            XCTAssertFalse(shouldHideProgress)
            print("Загрузка не окончена")
        default:
            return
        }
    }

    //MARK: - Тест № 4 - Тестируем Helper
    //Получение ссылки авторизации authURL
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        //when
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    // Тест, что AuthHelper корректно распознаёт код из ссылки.
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents?.url!
        let authHelper = AuthHelper()

        //when
        let code = authHelper.code(from: url!)

        //then
        XCTAssertEqual(code, "test code")
    }
}
