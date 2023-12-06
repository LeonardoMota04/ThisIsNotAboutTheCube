//
//  PageInfoModel.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 05/12/23.
//

import Foundation

struct InfoPage {
    let title: String
    let subtitle: String?
    let text: String?
    
    init(title: String, subtitle: String? = nil, text: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.text = text
    }
}

let pagesInfos: [InfoPage] = [
    InfoPage(title: "THIS IS NOT ABOUT \nTHE CUBE"),
    InfoPage(title: "HELP ME.", subtitle: "Everyone fights their demons daily.", text: "Sometimes we don’t know where to start – it’s just too much, but we have something: TIME."),
    InfoPage(title: "THIS IS NOT ABOUT \nTHE CUBE"),
]
