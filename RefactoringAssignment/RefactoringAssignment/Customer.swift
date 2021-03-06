//
//  Customer.swift
//  RefactoringAssignment
//
//  Created by Ahmed Meguid on 1/30/20.
//  Copyright © 2020 LintSchool. All rights reserved.
//

import Foundation
 
struct Receipt: Encodable {
    let customerName: String
    let costPerRide: [Double]
    let totalCost: Double
    let totalPoints: Double
}

protocol ReceiptPrinter {
    func print(receipt: Receipt) -> String
}

class ReceiptStringPrinter: ReceiptPrinter {
    func print(receipt: Receipt) -> String {
        let receiptHeader = "Receipt for: \(receipt.customerName)"
        let receiptBody = receipt.costPerRide
            .map { String(format: "LE %.2f", $0) }.joined(separator: "\n")
        let receiptFooter = String(format:"Amount owed is LE %.2f, and %.2f point\n", receipt.totalCost, receipt.totalPoints)
        return [receiptHeader, receiptBody, receiptFooter].joined(separator: "\n")
    }
}

class ReceiptJSONPrinter: ReceiptPrinter {
    func print(receipt: Receipt) -> String {
        return String(describing: receipt.asDictionary())
    }
}

class Customer {
    
    let receiptPrinter: ReceiptPrinter
    
    var name: String
    var familyRides: [Ride]
    
    init(name:String, receiptPrinter: ReceiptPrinter) {
        self.name = name
        self.receiptPrinter = receiptPrinter
        familyRides = []
    }
    
    func addFamilyRide(ride:Ride) {
        familyRides.append(ride)
    }
    
    /// Resposnibilities
    /// 1. accumlate ride costs, points and feed them to receipt printer
    func receipt() -> String {
        var totalCost: Double = 0.0
        var totalPoints: Double = 0.0
        var costPerRide: [Double] = []
        
        familyRides.forEach { ride in
            let rideCost = ride.calculateRideAmount()
            let ridePoints = ride.calculatePoints()
            
            totalCost += rideCost
            totalPoints += ridePoints
            costPerRide.append(rideCost)
        }
        
        let receipt = Receipt(customerName: name,
                              costPerRide: costPerRide,
                              totalCost: totalCost,
                              totalPoints: totalPoints)
        
        return receiptPrinter.print(receipt: receipt)
    }
}
 
protocol ServiceProtocol {
    var maxUsers: Int { get }
    var isPopular: Bool { get }
    var type: Int { get }
    
    func applyTimeMultiplier(time: Int) -> Double
    func applyExtraCost(kilometers: Int, time: Int) -> Double
    func applyBaseFare() -> Double
    func applyTolls(tolls: [Int]) -> Double
    func applyDistanceLimitMutliplier(kilometers: Int, time: Int) -> Double
    func applySurgeMutliplier(isSurged: Bool, surgeRate: Double) -> Double
    
    func applyBasePoints(rideAmount: Double) -> Double
    func applySurgePoints(isSurged: Bool, surgeRate: Double) -> Double
    func applySurgePointsForServiceType(totalPoints: Double) -> Double
}

enum ServiceType {
    case uberX
    case chopper
    case uberBlack
}

extension ServiceType: ServiceProtocol {
    func applyBasePoints(rideAmount: Double) -> Double {
        return rideAmount / 10
    }
    
    func applySurgePoints(isSurged: Bool, surgeRate: Double) -> Double {
        guard self == .uberX else { return 0 }
        return surgeRate * 10 - 10
    }
    
    func applySurgePointsForServiceType(totalPoints: Double) -> Double {
        switch self {
        case .uberX:
            return 0
        case .uberBlack:
            return 5
        case .chopper:
            return totalPoints * 2
        }
    }
    
    var maxUsers: Int {
        return 1000 // dummy
    }
    
    var isPopular: Bool {
        switch self {
        default:
            return true // dummy
        }
    }
    
    var type: Int {
        return -1 // dummy
    }
    
    func applyTimeMultiplier(time: Int) -> Double {
        switch self {
        case .uberX:
            return Double(100 * time)
        case .uberBlack:
            return Double(150 * time)
        case .chopper:
            return Double(200 * time)
        }
    }
    
    func applyExtraCost(kilometers: Int, time: Int) -> Double {
        switch self {
        case .uberX:
            let didPassLimitToApplyExtraCost = kilometers > time * 50
            return didPassLimitToApplyExtraCost ? Double((kilometers - time * 50) * 2) : 0
        case .uberBlack:
            let didPassLimitToApplyExtraCost = kilometers > time * 70
            return didPassLimitToApplyExtraCost ? Double((kilometers - time * 70) * 2) : 0
        case .chopper:
            return 0
        }
    }
    
    func applyBaseFare() -> Double {
        switch self {
        case .uberX:
            return 50
        case .chopper:
            return 0
        case .uberBlack:
            return 60
        }
    }
    
    func applyTolls(tolls: [Int]) -> Double {
        switch self {
        case .uberX:
            return Double(tolls.reduce(0, +))
        case .uberBlack:
            return Double(tolls.reduce(0, +))
        case .chopper:
            return 0
        }
    }
    
    func applyDistanceLimitMutliplier(kilometers: Int, time: Int) -> Double {
        let didPassDistanceLimit = kilometers > 200
        let didPassTimeLimit = time > 120
        
        guard didPassDistanceLimit else { return 0 }
        
        switch self {
        case .uberBlack:
            return didPassTimeLimit ? 0.05 : 0
        case .uberX:
            return 0.05
        case .chopper:
            return 0
        }
    }
    
    func applySurgeMutliplier(isSurged: Bool, surgeRate: Double) -> Double {
        guard isSurged else { return 0 }
        switch self {
        case .uberX:
            return surgeRate
        case .uberBlack:
            return 0
        case .chopper:
            return 0
        }
    }
}

class Ride {
    
    var service: ServiceProtocol
    var kilometers: Int
    var time: Int
    var tolls: [Int]
    var isSurged: Bool
    var surgeRate: Double
    
    init(service: ServiceProtocol, kilometers: Int, time: Int, tolls: [Int], isSurged: Bool, surgeRate: Double) {
        self.service = service
        self.kilometers = kilometers
        self.time = time
        self.tolls = tolls
        self.isSurged = isSurged
        self.surgeRate = surgeRate
    }
    
    func calculateRideAmount() -> Double {
        var rideAmount = 50.0
        rideAmount += service.applyBaseFare()
        rideAmount += service.applyTimeMultiplier(time: time)
        rideAmount += service.applyExtraCost(kilometers: kilometers, time: time)
        rideAmount += rideAmount * service.applyDistanceLimitMutliplier(kilometers: kilometers, time: time)
        rideAmount += service.applyTolls(tolls: tolls)
        rideAmount += rideAmount * service.applySurgeMutliplier(isSurged: isSurged, surgeRate: surgeRate)
        return rideAmount
    }
    
    func calculatePoints() -> Double {
        var points = 0.0
        points += service.applyBasePoints(rideAmount: calculateRideAmount())
        points += service.applySurgePoints(isSurged: isSurged, surgeRate: surgeRate)
        points += service.applySurgePointsForServiceType(totalPoints: points)
        return points
    }
}

extension Encodable {
    func asDictionary() -> [String: Any] {
        let serialized = (try? JSONSerialization.jsonObject(with: self.encode(), options: .allowFragments)) ?? nil
        return serialized as? [String: Any] ?? [String: Any]()
    }
    
    func encode() -> Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}
