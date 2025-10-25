//
//  Views/TodayTodos/TimeBudgetView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.10.25.
//

import SwiftUI

struct TimeBudgetView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @Binding var energyLevel: Float
    
    @State private var showingInfo = false
    
    @State private var viewID = UUID()
    
    private var totalEstimatedTime: Int64 {
        let defaultEstimatedTime = settingsViewModel.settings.defaultTimeForEnergyLevelCalculation
        return Int64(todoViewModel.getTotalEstimatedTime(defaultEstimatedTime: defaultEstimatedTime))
    }

    private var maxEstimatedTime: Int64 {
        EnergyManager.getMaxEstimatedTime(energyLevel: energyLevel)
    }

    var body: some View {
        VStack {
            if totalEstimatedTime > 0 {
                Section {
                    VStack {
                        
                        let maxEstimatedTime: Int64 = EnergyManager.getMaxEstimatedTime(energyLevel: energyLevel)
                        
                        Text("\(Localization.labels.estimatedTime): \(totalEstimatedTime)\(Localization.labels.estimatedTimeUnit).")
                            .font(Font.app.normal)
                            .foregroundColor(totalEstimatedTime > maxEstimatedTime ? Color.theme.red : Color.theme.primary)
                            .fontWeight(totalEstimatedTime > maxEstimatedTime ? .bold : .regular)
                            .padding(.top, 14)
                            .padding(.bottom, 14)
                        HStack {
                            Text(Localization.messages.energyLevelLow)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Text(Localization.messages.energyLevel)
                            Button(action: {
                                self.showingInfo.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .font(Font.app.tiny)
                            }
                            .accessibilityIdentifier("infoButton")
                            .sheet(isPresented: $showingInfo) {
                                InfoView(
                                    isPresented: $showingInfo,
                                    title: Localization.info.infoTimebudgetTitle,
                                    explanationText: Localization.info.infoTimebudgetText,
                                    buttonText: nil,
                                    buttonAction: nil
                                )
                            }
                            
                            Spacer()
                            
                            Text(Localization.messages.energyLevelHigh)
                                .multilineTextAlignment(.trailing)
                        }
                        .font(Font.app.tiny)
                        .padding(.horizontal,64)
                        
                        Slider(value: $energyLevel, in: 1...3, step: 1)
                            .padding(.horizontal,64)
                            .accentColor(Color.theme.accent)
                            .accessibilityIdentifier("timeBudgetSlider")
                    }
                }
                .padding(.bottom, 14)
                .id(viewID)
            }
        }
        .onReceive(todoViewModel.objectWillChange) { _ in
            viewID = UUID()
        }
    }
}
