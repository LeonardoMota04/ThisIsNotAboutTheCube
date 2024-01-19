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

struct MovementsView: View {
    
    @State var numOfMovement: Int = 0
    @ObservedObject private var vc = ViewController()

    var body: some View {
        
        ZStack(alignment: .top) {
            
            withAnimation(.easeInOut) {
            CubeView(viewController: vc)
                .background(vc.cubePhases.isEmpty ? Color.red: vc.cubePhases[vc.currentPhaseIndex].backgroundColor)
            }

            VStack {
                Text("\(vc.cubePhases.isEmpty ? "empty" : vc.cubePhases[vc.currentPhaseIndex].title)")
                    .font(.system(size: 100))
                    .foregroundStyle(.black)
                
                Text("\(vc.numOfMovements)")
                    .font(.system(size: 50))
                    .foregroundStyle(.black)
            }
            
        }
    }
}

#Preview {
    MovementsView()
}
