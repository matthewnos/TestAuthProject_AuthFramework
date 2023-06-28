//
//  ContentView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var athm: AuthManager
    var body: some View {
        VStack {
            HomeScreen().environmentObject(athm)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
