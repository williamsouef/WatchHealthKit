//
//  WorkoutView.swift
//  Watch HealthKit Watch App
//
//  Created by William Souef on 17/02/2023.
//

import SwiftUI

struct WorkoutView: View {
    

    enum WorkoutState {
        case active, paused
    }
    @State private var workoutState : WorkoutState = .paused
    @ObservedObject var vm : HealthManager
    
    var distanceQuantity : String {
        let miles = vm.totalDistance
        var distanceString = String(format: "%.2f", miles)
        if miles >= 10 {
            distanceString = String(format: "%.1f", miles)
        }
        return distanceString
    }
    
    var caloriesQuantity : String {
        return String(format: "%.Of", vm.totalEnergyBurned)
    }
    
    var heartRateQuantity : String {
        return String(Int(vm.lastHeartRate))
    }
    
    var body: some View {
        VStack{
       
        
                StatisticsView(quantity: distanceQuantity, unit: "miles")
                    .foregroundColor(Color.green)
                StatisticsView(quantity: caloriesQuantity, unit: "cal")
                    .foregroundColor(Color.orange)
                StatisticsView(quantity: heartRateQuantity, unit: "BPM")
                    .foregroundColor(Color.red)
            
                    
            if workoutState == .active {
                Button("Pause"){
                    vm.pause()
                    workoutState = .paused
                    
                }
                .background(Color.blue)
                .foregroundColor(.black)
                .cornerRadius(10)
            } else {
                HStack{
                    Button("Resume"){
                        vm.resume()
                        workoutState = .active
                        
                    }
                    Button("End"){
                        vm.end()
                    }
                    .background(Color.red)
                    .foregroundColor(.black)
                    .cornerRadius(20)
                }
                
            }
           
            
            
        }
    }
}



struct StatisticsView : View {
    
    var quantity : String
    var unit : String
    
    var body: some View {
        VStack{
            Text(quantity)
                .font(.largeTitle)
            
            Text(unit)
                .font(.caption2)
        }
    }
}







struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(vm: HealthManager())
    }
}
