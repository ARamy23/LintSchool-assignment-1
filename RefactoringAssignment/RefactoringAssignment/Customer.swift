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
 
class Ride {
    
    var service: Int
    var kilometers: Int
    var time: Int
    var tolls: [Int]
    var isSurged: Bool
    var surgeRate: Double
    
    init(service: Int, kilometers: Int, time: Int, tolls: [Int], isSurged: Bool, surgeRate: Double) {
        self.service = service
        self.kilometers = kilometers
        self.time = time
        self.tolls = tolls
        self.isSurged = isSurged
        self.surgeRate = surgeRate
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
