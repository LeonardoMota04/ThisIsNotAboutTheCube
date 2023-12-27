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

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

// VIEW
struct MovementsView: View {
    
    @State var numOfMovement: Int = 0
    @ObservedObject private var vc = ViewController()

    @StateObject var motionManager: MotionManager = .init()
    
    
    var body: some View {
        
        ZStack(alignment: .top) {
            (vc.numOfMovements > 1) ? Color.gray.ignoresSafeArea() : Color.purple.ignoresSafeArea()
            
            CubeView(viewController: vc)
            
            
            
            Text("\(vc.numOfMovements)")
                .font(.system(size: 100))
                
            
        }
        .onAppear(perform: motionManager.detectMotion)
        .onDisappear(perform: motionManager.stopMotionUpdates)
    }
}

#Preview {
    MovementsView()
}
