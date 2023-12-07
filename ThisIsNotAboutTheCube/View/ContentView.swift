//
//  ContentView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 06/12/23.
//

import SwiftUI

struct ContentView: View {
    var data = PageInfoModel.data
    
    var body: some View {
        //Group {
        ZStack {
            PagesViewPure(data: data)
            CubeView()
        }
        //}
    }
}

#Preview {
    ContentView()
}
