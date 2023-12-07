//
//  IndividualPageView.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 06/12/23.
//

import SwiftUI
import SceneKit

struct IndividualPageView: View {
    var data: PageInfoModel
    
    var body: some View {
            VStack {
                Text(data.title)
                    .font(.custom("JoystixMonospace-Regular", size: 80))
                    .foregroundStyle(data.textColor)
                    .multilineTextAlignment(.center)

                Text(data.subtitle ?? "")
                    .font(.custom("Terminal-Grotesque", size: 40))
                    .foregroundStyle(data.textColor)
                
                Spacer()
                
                Text(data.text ?? "")
                    .font(.custom("Terminal-Grotesque", size: 35))
                    .foregroundStyle(data.textColor)
            }
            .padding()
    }
}

struct IndividualPageView_Previews: PreviewProvider {
    static let sample = PageInfoModel.data[1]
    static var previews: some View {
        IndividualPageView(data: sample)
    }
}
