//
//  CustomerTests.swift
//  RefactoringAssignmentTests
//
//  Created by Ahmed Ramy on 1/30/20.
//  Copyright © 2020 LintSchool. All rights reserved.
//

import XCTest
@testable import RefactoringAssignment

class CustomerTests: XCTestCase {

    var sut: Customer!
    
    override func setUp() {
        sut = Customer(name: "Ahmed", receiptPrinter: ReceiptStringPrinter())
    }

    override func tearDown() {
        sut = nil
    }

    func testReceiptReturnsGivenStringInAssignment() {
        // Given
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberBlack, kilometers: 300, time: 150, tolls: [5,4,6], isSurged: true, surgeRate: 1.5))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberX, kilometers: 200, time: 66, tolls: [5,6,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.chopper, kilometers: 160, time: 55, tolls: [5,4,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberBlack, kilometers: 3, time: 22, tolls: [5,6,6], isSurged: true, surgeRate: 1.4))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberX, kilometers: 200, time: 90, tolls: [5,4,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.chopper, kilometers: 140, time: 130, tolls: [5,6,6], isSurged: true, surgeRate: 1.3))
        
        // When
        let returnedString = sut.receipt()
        
        // Then
        let expectedString = """
                            Receipt for:Ahmed
                            LE 23755.50
                            LE 6717.00
                            LE 11050.00
                            LE 3427.00
                            LE 9115.00
                            LE 26050.00
                            Amount owed is LE 80114.50, and 15421.45 point\n
                            """
        
        XCTAssert(expectedString == returnedString)
    }
    
    func testReceiptWithJSONPrinterMatchesExpectedString() {
        // Given
        sut = Customer(name: "Ramy", receiptPrinter: ReceiptJSONPrinter())
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberBlack, kilometers: 300, time: 150, tolls: [5,4,6], isSurged: true, surgeRate: 1.5))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberX, kilometers: 200, time: 66, tolls: [5,6,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.chopper, kilometers: 160, time: 55, tolls: [5,4,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberBlack, kilometers: 3, time: 22, tolls: [5,6,6], isSurged: true, surgeRate: 1.4))
        sut.addFamilyRide(ride: Ride(service: ServiceType.uberX, kilometers: 200, time: 90, tolls: [5,4,6], isSurged: false, surgeRate: 0))
        sut.addFamilyRide(ride: Ride(service: ServiceType.chopper, kilometers: 140, time: 130, tolls: [5,6,6], isSurged: true, surgeRate: 1.3))
        
        // When
        let returnedString = sut.receipt()
        
        // Then
        
        // NOTE: we are comparing this way since dictionaries orders
        // its elements randomly
        
        let namePattern = "\"customerName\": Ramy"
        let totalCostPattern = "\"totalCost\": 80114.5"
        let totalPointsPattern = "\"totalPoints\": 15421.45"
        
        XCTAssert(returnedString.contains(namePattern))
        XCTAssert(returnedString.contains(totalCostPattern))
        XCTAssert(returnedString.contains(totalPointsPattern))
    }

}
