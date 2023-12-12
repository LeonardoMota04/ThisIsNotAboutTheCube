//
//  SwiftUIView.swift
//  UIKITCOPIA
//
//  Created by Leonardo Mota on 05/12/23.
//

import SwiftUI
import SceneKit

struct MyView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        return vc
    }
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}



struct SwiftUIView: View {

    
    var body: some View {
        ZStack {
            Color.purple.ignoresSafeArea()
            MyView()
        } 
    }

}


#Preview {
    SwiftUIView()
}
