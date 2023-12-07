//
//  SwiftUIView.swift
//  UIKITCOPIA
//
//  Created by Leonardo Mota on 05/12/23.
//

import SwiftUI
import SceneKit

struct CubeView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        return vc
    }
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}



struct SwiftUIView: View {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var title: String = ""
    @State private var index: Int = 0
    @State private var showCube = false
    @State private var circleSize: CGFloat = 100
    @State private var dragOffset: CGFloat = 0
    
    
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Circle()
                .frame(width: circleSize)
                .foregroundStyle(.red)
                .offset(x: dragOffset, y: 0)
            //if showCube {
                CubeView().ignoresSafeArea()
            //}
            
                
            VStack {
                Text(title)
                    .font(.custom("JoystixMonospace-Regular", size: 50))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .onReceive(timer) { _ in
                        let titleString = "THIS IS NOT ABOUT \nTHE CUBE"
                        if index < titleString.count {
                            let letter = titleString[titleString.startIndex...titleString.index(titleString.startIndex, offsetBy: index)]
                            self.title = "\(letter)"
                            index += 1
                        } else {
                            //withAnimation {
                            //    showCube = true
                            //}
                        }
                    }
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Text("Swipe to start")
                            .font(.custom("JoystixMonospace-Regular", size: 15))
                            .foregroundStyle(.gray)
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.gray)
                            .font(.system(size: 100))
                    }
                }.padding()
                
                
                
            }
            .padding()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    dragOffset = 0
                    
                    if value.translation.width < 0 {
                        withAnimation {
                            circleSize += 300
                        }
                    }
                }
        )
    }
}

#Preview {
    SwiftUIView()
}
