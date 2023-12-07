//
//  PageInfoModel.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 05/12/23.
//

import Foundation
import SwiftUI

struct PageInfoModel {
    let title: String
    let subtitle: String?
    let text: String?
    let textColor: Color
    let bgColor: Color
    
    init(title: String, subtitle: String? = nil, text: String? = nil, textColor: Color, bgColor: Color) {
        self.title = title
        self.subtitle = subtitle
        self.text = text
        self.textColor = textColor
        self.bgColor = bgColor
    }
    
}

extension PageInfoModel {
    static var data: [PageInfoModel] = [
        PageInfoModel(title: "THIS IS NOT ABOUT \nTHE CUBE", textColor: Color.black, bgColor: Color.white),
        PageInfoModel(title: "HELP ME.", subtitle: "Everyone fights their demons daily.", text: "Sometimes we don’t know where to start – it’s just too much, but we have something: TIME.", textColor: Color.white, bgColor: Color.red.opacity(0.85)),
        PageInfoModel(title: "EVERY DAY IS A NEW \nCHALLENGE", subtitle: "43.252.003.274.489.856.000 different opportunities", text: "Every move you make is unique, probably no one has ever experienced this problem...", textColor: Color.white, bgColor: Color.orange),
    ]
}

