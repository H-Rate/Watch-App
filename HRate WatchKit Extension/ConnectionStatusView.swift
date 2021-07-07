//
//  SwiftUIView.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 21/06/21.
//

import SwiftUI

struct ConnectionStatusView: View {
    
    @ObservedObject var watchService: WatchService
    @ObservedObject var contentViewModel: ContentViewModel
    
    private let screenHeight = WKInterfaceDevice.current().screenBounds.size.height
    
    private var status: String {
        if (watchService.connectionStatus == .Failed || watchService.connectionStatus == .Disconnected) {
            return "Unable to connect to phone"
        } else if (contentViewModel.socketConnection == .Failed) {
            return "Unable to connect to server"
        } else if (contentViewModel.socketConnection == .Disconnected) {
            return "Disconnected from server"
        }
        
        return "Connecting"
    }
    
    private var isConnected: Bool {
        watchService.connectionStatus == .Connected && contentViewModel.socketConnection == .Connected
    }
    
    private var overviewOffset: CGSize {
        let height = isConnected ? self.screenHeight : 0
        return CGSize(width: 0, height: height)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            Text(status).multilineTextAlignment(.center)
        }
        .offset(overviewOffset)
        .animation(.easeInOut(duration: 0.3))
    }
}

struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionStatusView(watchService: WatchService(), contentViewModel: ContentViewModel())
    }
}
