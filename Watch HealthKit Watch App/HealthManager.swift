//
//  HealthManager.swift
//  Watch HealthKit Watch App
//
//  Created by William Souef on 05/02/2023.
//

import Foundation
import HealthKit


class HealthManager : NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
   
    
    @Published var state = WorkoutState.inactive
    @Published var totalEnergyBurned = 0.0
    @Published var totalDistance = 0.0
    @Published var lastHeartRate = 0.0
    
    enum WorkoutState {
        case inactive, active, paused
    }
    
    var healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    var workoutBuilder : HKLiveWorkoutBuilder?
    
    let activity = HKWorkoutActivityType.running
    
    func start() {
        let sampleTypes: Set<HKSampleType> = [
            .workoutType(),
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!]
        
        healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes) {
            success, error in
            if success {
                self.beginWorkout()
            }
        }
    
    }
    
    
    private func beginWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = activity
        config.locationType = .outdoor
        
        
        
        do {
            // Start Workout
           workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
           workoutBuilder = workoutSession?.associatedWorkoutBuilder()
           workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            
            workoutSession?.delegate = self
            workoutBuilder?.delegate = self
            
            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { success, error
                in
    guard success else {return}
                
                DispatchQueue.main.async {
                    self.state = .active
                }
            }
        }catch{
            // Errors
        }
        
        
    }
   
 
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running:
                self.state = .active
            case .paused:
                self.state = .paused
            case .ended:
                self.save()
            default:
                break
            }
        }
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {continue}
            guard let statistics = workoutBuilder.statistics(for: quantityType)
            else {continue}
            
            DispatchQueue.main.async {
                switch statistics.quantityType{
                case HKQuantityType.quantityType(forIdentifier: .heartRate) :
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    self.lastHeartRate =
                    statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) :
                    let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    self.totalEnergyBurned = value
                    
                default :
                    let distance = statistics.sumQuantity()?.doubleValue(for: .mile())
                    self.totalDistance = distance ?? 0
                }
            }
        }
        
    }
    func pause() {
        workoutSession?.pause()
    }
    
    func resume() {
        workoutSession?.resume()
    }
    
    func end() {
        workoutSession?.end()
    }
    
    
     private func save() {
      workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            self.workoutBuilder?.finishWorkout{ workout, error in
                DispatchQueue.main.async {
                    self.state = .inactive
                }
            }
        }
    }

    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Not useful now
    }
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Not useful now 
    }
}
