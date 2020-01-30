//
//  Customer.swift
//  RefactoringAssignment
//
//  Created by Ahmed Meguid on 1/30/20.
//  Copyright © 2020 LintSchool. All rights reserved.
//

import Foundation
 
class Customer {
    
    var name: String
    var familyRides: [Ride]
    
    init(name:String) {
        self.name = name
        familyRides = []
    }
    
    func addFamilyRide(ride:Ride) {
        familyRides.append(ride)
    }
    
    /// Resposnibilities
    /// 1. calculate totalAmount
    ///     1. depend on KM
    ///     2. depend on Time
    ///     3. depend on Tolls
    ///     4. depend on Surge
    /// 2. caluclate totalPoints
    ///     1. depend on RideAmount
    ///     2. depend on Ride Type if chopper or UberBlack
    /// 3. handle ride type and calculates each ride's cost
    ///     1. applys time multiplier to ride amount
    ///     2. applys extra cost after time limit
    ///     3. applys base fare
    ///     4. applys tolls on certain ride types
    ///     5. if certain distance limit is reached, ride amount increases by 0.05%
    ///     6. applys surge amount
    /// 4.  print receipt
    func receipt() -> String {
        
        var totalAmount : Double = 0.0
        var totalPoints : Double = 0.0

        var result:String = "Receipt for:" + self.name + "\n"
        
        for ride in familyRides {
            
            var rideAmount: Double = 50.0
            
            switch (ride.service) {
                
            case Service.uberX:
                
                rideAmount += Double(100*ride.time) // Time Multiplier
                
                if ride.kilometers > ride.time*50  { // Limit to apply extra cost
                    rideAmount += Double((ride.kilometers - ride.time*50) * 2)
                }
                
                rideAmount += 50 // Base Fare
                
            case Service.chopper:
                
                rideAmount += Double(200*ride.time) // Time Multiplier
                
            case Service.uberBlack:
                
                rideAmount += Double(150*ride.time) // Time Multiplier
                
                if ride.kilometers > ride.time*70 { // Time Limit to apply extra cost
                    rideAmount += Double((ride.kilometers - ride.time*70) * 2)
                }
                
                rideAmount += 60 // Base Fare
 
            default:
                rideAmount += 0.0
            }
            
            if ride.kilometers>200 { // Past 200 Kilos
                if ride.time>120 && ride.service == Service.uberBlack { // past 120 minutes and is UberBlack
                    
                    rideAmount+=rideAmount*0.05 // Increase ride amount by 0.05%
                
                } else if ride.service==Service.uberX { // Is Uber X
                    
                    rideAmount+=rideAmount*0.05 // Increase ride amount by 0.05% directly
                }
            }
            
            if ride.service == Service.uberX || ride.service == Service.uberBlack {
                for toll in ride.tolls {
                    rideAmount += Double(toll) // if UberX or black, add tolls
                }
            }
            
            if ride.isSurged {
                if ride.service == Service.uberX {
                    rideAmount *= ride.surgeRate // if UberX add surgeRate to rideAmount
                    totalPoints += (ride.surgeRate * 10 - 10) // and increase totalPoints
                }
            }
            
            totalPoints += rideAmount / 10.0 // increase total points by 10th of ride amount
            
            if ride.service == Service.chopper {
                totalPoints *= 2 // if service is chopper, double totalPoints
            } else if ride.service == Service.uberBlack {
                totalPoints += 5 // if uberBlack add 5 points
            }

            result+=String(format:"LE %.2f\n",rideAmount)
            
            totalAmount+=rideAmount;
        }
        
        result+=String(format:"Amount owed is LE %.2f, and %.2f point\n",totalAmount, Int(totalPoints));
        
        return result;
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
        guard self == .uberX || self == .uberBlack else { return 0 }
        return Double(tolls.reduce(0, +))
    }
    
    func applyDistanceLimitMutliplier(kilometers: Int, time: Int) -> Double {
        let didPassDistanceLimit = kilometers > 200
        let didPassTimeLimit = time > 120
        
        guard didPassDistanceLimit else { return 0 }
        
        if self == .uberBlack && didPassTimeLimit {
            return 0.05
        } else if self == .uberX {
            return 0.05
        } else {
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
}
 
class Service {
    
    static let uberX:Int = 1
    static let chopper:Int = 2
    static let uberBlack:Int = 3
    
    var maxUsers: Int
    var isPopular: Bool
    var type: Int
    
    init(maxUsers: Int, isPopular: Bool, type: Int) {
        self.maxUsers = maxUsers
        self.isPopular = isPopular
        self.type = type
    }
}
