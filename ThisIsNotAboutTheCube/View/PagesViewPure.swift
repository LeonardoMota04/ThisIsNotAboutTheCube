//
//  IndividualPageView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 06/12/23.
//

import SwiftUI
import SceneKit

struct PagesViewPure: View {
    // TIMER
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var index: Int = 0
    @State private var showCube = false
    
    
    @State private var circleSize: CGFloat = 100
    // INFO PAGES
    var data: [PageInfoModel]
    //var doneFunction: () -> ()
    @State var slideGesture: CGSize = CGSize.zero
    @State var currentPageIndex = 0
    var distance: CGFloat = UIScreen.main.bounds.size.width
    
    
    var body: some View {
            ZStack {
                ForEach(0..<data.count) { i in
                    ZStack {
                        Color(data[i].bgColor).ignoresSafeArea()
                        IndividualPageView(data: self.data[i])
                    }
                    
                        .offset(x: CGFloat(i) * self.distance)
                        .offset(x: self.slideGesture.width - CGFloat(self.currentPageIndex) * self.distance)
                        .animation(.spring())
                        .gesture(DragGesture().onChanged { value in
                            self.slideGesture = value.translation
                        }
                        .onEnded { value in
                            if self.slideGesture.width < -50 {
                                if self.currentPageIndex < self.data.count - 1 {
                                    withAnimation {
                                        self.currentPageIndex += 1
                                    }
                                }
                            }
                            if self.slideGesture.width > 50 {
                                if self.currentPageIndex > 0 {
                                    withAnimation {
                                        self.currentPageIndex -= 1
                                    }
                                }
                            }
                            self.slideGesture = .zero
                        })
                }
                //MyView()

            }
    }
}


struct PagesViewPure_Previews: PreviewProvider {
    static let sample = PageInfoModel.data
    static var previews: some View {
        PagesViewPure(data: sample)
    }
}

