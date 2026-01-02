//
//  PurpleGradientCard.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//


import SwiftUI

struct PurpleGradientCard<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.9),
                                Color.blue.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 8,
                y: 4
            )
    }
}

