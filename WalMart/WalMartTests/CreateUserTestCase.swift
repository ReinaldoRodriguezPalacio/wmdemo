//
//  CreateUserTestCase.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/22/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import XCTest

class CreateUserTestCase: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCUIDevice.shared().orientation = .portrait
        XCUIDevice.shared().orientation = .portrait
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        let tabbarMenuButton = app.buttons["tabBar menu"]
        tabbarMenuButton.tap()
        app.buttons["iniciar sesión"].tap()
        
        XCUIApplication().buttons["Crear una Cuenta"].tap()
        XCUIDevice.shared().orientation = .faceUp
        XCUIDevice.shared().orientation = .portrait
       
        
        let nombreTextField = app.scrollViews.textFields["*Nombre"]
        let apellidoPaternoTextField = app.textFields["*Apellido Paterno"]
        let mailTextField = app.textFields["*Correo Electrónico"]
        let passTextField = app.textFields["*Contraseña"]
        let conPassTextField = app.textFields["*Confirmar Contraseña"]
        
        nombreTextField.typeText("Test")
        apellidoPaternoTextField.typeText("Test")
        mailTextField.typeText("Test")
        passTextField.typeText("Test")
        conPassTextField.typeText("Test")
        
        
        
    }
    
}
