//
//  MovementsView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 22/12/23.
//

import SwiftUI

// MARK: - View Controller Representable
struct CubeControllerView: UIViewControllerRepresentable {
    @ObservedObject var viewController: ViewController

    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

// MARK: - SwiftUI View
struct CubeView: View {
    
    @State var numOfMovement: Int = 0
    @ObservedObject private var vc = ViewController()

    var body: some View {
        
        ZStack(alignment: .top) {
            Color.purple.ignoresSafeArea()
            CubeControllerView(viewController: vc)
            VStack {
                Text("\(vc.numOfMovements)")
                    .font(.system(size: 100))
                
            }
            
        }
    }
}

#Preview {
    CubeView()
}
