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
    
    func receipt() -> String {
        
        var totalAmount : Double = 0.0
        var totalPoints : Double = 0.0

        var result:String = "Receipt for:" + self.name + "\n"
        
        for ride in familyRides {
            
            var rideAmount: Double = 50.0
            
            switch (ride.service) {
                
            case Service.uberX:
                
                rideAmount += Double(100*ride.time)
                
                if ride.kilometers > ride.time*50  {
                    rideAmount += Double((ride.kilometers - ride.time*50) * 2)
                }
                
                rideAmount += 50
                
            case Service.chopper:
                
                rideAmount += Double(200*ride.time)
                
            case Service.uberBlack:
                
                rideAmount += Double(150*ride.time)
                
                if ride.kilometers > ride.time*70 {
                    rideAmount += Double((ride.kilometers - ride.time*70) * 2)
                }
                
                rideAmount += 60
 
            default:
                rideAmount += 0.0
            }
            
            if ride.kilometers>200 {
                if ride.time>120 && ride.service == Service.uberBlack {
                    
                    rideAmount+=rideAmount*0.05
                
                } else if ride.service==Service.uberX {
                    
                    rideAmount+=rideAmount*0.05
                }
            }
            
            if ride.service == Service.uberX || ride.service == Service.uberBlack {
                for toll in ride.tolls {
                    rideAmount += Double(toll)
                }
            }
            
            if ride.isSurged {
                if ride.service == Service.uberX {
                    rideAmount *= ride.surgeRate
                    totalPoints += (ride.surgeRate * 10 - 10)
                }
            }
            
            totalPoints += rideAmount / 10.0
            
            if ride.service == Service.chopper {
                totalPoints *= 2
            } else if ride.service == Service.uberBlack {
                totalPoints += 5
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
