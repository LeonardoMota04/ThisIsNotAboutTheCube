//
//  InfoView.swift
//  UIKITCOPIA
//
//  Created by Leonardo Mota on 05/12/23.
//

import UIKit
import SceneKit

class CubeInfoOverlayView: UIView {
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "JoystixMonospace-Regular", size: 70)
        label.numberOfLines = 0
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    func updateText(_ text: String) {
        label.text = text
    }
}
