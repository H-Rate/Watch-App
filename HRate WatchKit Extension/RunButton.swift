//
//  RunButton.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 06/02/21.
//

import SwiftUI

struct RunStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.orange.withAlphaComponent(0.8)))
                .frame(width: 150, height: 150)
            Circle()
                .fill(Color(UIColor.orange))
                .overlay(
                    configuration.label
                        .foregroundColor(.black)
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                )
                .frame(width: 130, height: 130)
        }
    }
}

struct RunButton: View {
    var action = {}
    
    var body: some View {
        Button(action: action) {
            Text("START")
        }
        .buttonStyle(RunStyle())
    }
}

struct RunButton_Previews: PreviewProvider {
    static var previews: some View {
        RunButton()
    }
}
