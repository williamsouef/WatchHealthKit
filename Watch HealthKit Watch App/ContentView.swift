//
//  ContentView.swift
//  Watch HealthKit Watch App
//
//  Created by William Souef on 05/02/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    @StateObject var vm = HealthManager()
    
    
    var body: some View {
        
        if vm.state == .inactive {
            VStack {
                
                Text("Furious")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Button("Start Run") {
                    guard
                        HKHealthStore.isHealthDataAvailable() else { return }
                    vm.start()
                 }
             }
        } else {
                    WorkoutView(vm: vm)
                }
                
                
                
            }
            
        }
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
