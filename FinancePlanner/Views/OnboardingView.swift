//
//  OnboardingView.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import SwiftUI

struct OnboardingView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()

            Text("My Finance")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("""
Plan your monthly expenses,
track commitments,
and stay in control of your finances.
""")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()

            Button {
                hasSeenOnboarding = true
                onStart()
            } label: {
                Text("Start Planning")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Skip for now")
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 40)
        }
        .padding()
    }
}

