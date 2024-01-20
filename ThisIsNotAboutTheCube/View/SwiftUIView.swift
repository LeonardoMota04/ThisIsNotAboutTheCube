//
//  MovementsView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 22/12/23.
//

import SwiftUI

struct CubeView: UIViewControllerRepresentable {
    @ObservedObject var viewController: ViewController

    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        //uiViewController.cubePhases = viewController.cubePhases
        //uiViewController.currentPhaseIndex = viewController.currentPhaseIndex
        //uiViewController.numOfMovements = viewController.numOfMovements
    }
}

struct SwiftUIView: View {
    
    @ObservedObject private var vc = ViewController()
    
    @State private var cubeBackgroundColor: Color = .clear
    @State var numOfMovement: Int = 0
    @State private var titleLabel: String = ""
    @State private var actionLabel: String = ""
    @State private var textOpacity: Double = 1.0
    @State private var lineOffset: CGFloat = 0.0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            // CUBE
            CubeView(viewController: vc)
                .background(cubeBackgroundColor)

            // INFORMATION
            VStack {
                /// Title
                Text(titleLabel)
                    .font(.system(size: 100))
                    .foregroundStyle(.black)
                    .opacity(textOpacity)
               
                Text("\(vc.numOfMovements)")
                    .font(.system(size: 50))
                    .foregroundStyle(.black)
                    .opacity(textOpacity)
                
                Spacer()
                
                LinesView()
                    .offset(y: lineOffset)
                
                /// Action Label
                Text(actionLabel)
                    .font(.system(size: 50))
                    .foregroundStyle(.black)
                    .opacity(textOpacity)
            }

            
        }
        .onAppear {
            cubeBackgroundColor = vc.cubePhases.isEmpty ? .gray : vc.cubePhases[vc.currentPhaseIndex].backgroundColor
            titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.cubePhases[vc.currentPhaseIndex].title
            actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.cubePhases[vc.currentPhaseIndex].actionLabel
        }
        
        .onChange(of: vc.currentPhaseIndex) { _ , _ in
            
            withAnimation(.smooth){
                lineOffset -= 100
            }

            
            withAnimation(.easeIn(duration: 1.0)) {
                cubeBackgroundColor = vc.cubePhases.isEmpty ? Color.gray : vc.cubePhases[vc.currentPhaseIndex].backgroundColor
                
            }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                textOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.smooth(duration: 2.0)) {
                    titleLabel = vc.cubePhases.isEmpty ? "empty" : vc.cubePhases[vc.currentPhaseIndex].title
                    
                    actionLabel = vc.cubePhases.isEmpty ? "empty" : vc.cubePhases[vc.currentPhaseIndex].actionLabel
                    
                    textOpacity = 1.0
                }
            }
            
        }
    }
}



#Preview {
    SwiftUIView()
}


struct ContentView: View {
    @State private var showNextView = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if showNextView {
                NextView()
                    .transition(.slide)
            } else {
                LinesView()
                    .transition(.slide)
            }
            
            Spacer()
            
            Button("Next") {
                withAnimation {
                    showNextView.toggle()
                }
            }
        }
        .padding()
    }
}

struct LinesView: View {
    var body: some View {
        VStack(spacing: 20) {
            LineView()
            LineView()
            LineView()
        }
    }
}

struct LineView: View {
    var body: some View {
        Rectangle()
            .frame(height: 5)
            .foregroundColor(.white)
    }
}

struct NextView: View {
    var body: some View {
        Text("Next View")
            .font(.title)
            .foregroundColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

