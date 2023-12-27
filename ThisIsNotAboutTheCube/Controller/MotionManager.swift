//
//  MotionManager.swift
//  ThisIsNotAboutTheCube
//
//  Created by Leonardo Mota on 26/12/23.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    
    // Motion Manager Properties
    @Published var manager: CMMotionManager = .init()
    @Published var xValue: CGFloat = 0
    @Published var yValue: CGFloat = 0
    private var initialAttitude: CMAttitude?

    // Callback para notificar sobre as atualizações
    var onUpdate: ((CGFloat, CGFloat) -> Void)?
    
    
    func detectMotion() {
        if !manager.isDeviceMotionActive {
            manager.deviceMotionUpdateInterval = 1/60
            manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                if let attitude = motion?.attitude {
                    // Garantir que a posicao inicial seja a que o usuario estiver segurando (nao ta funcionando)
                    if self?.initialAttitude == nil {
                        self?.initialAttitude = attitude
                    }
                    print ("Acceleration X \(motion!.userAcceleration.x)")
                    print ("Acceleration Y \(motion!.userAcceleration.y)")
                    print ("Acceleration Z \(motion!.userAcceleration.z)\n\n")
                    
                    print ("Rotation X \(motion!.rotationRate.x)")
                    print ("Rotation Y \(motion!.rotationRate.y)")
                    print ("Rotation Z \(motion!.rotationRate.z)\n\n")
                    
                    print("Gravity X \(motion!.gravity.x)")
                    print("Gravity Y \(motion!.gravity.y)")
                    print("Gravity Z \(motion!.gravity.z)\n\n")
                    // Calcular as diferenças nas rotações em relação à atitude inicial
                    let rotationX = Float(attitude.roll - (self?.initialAttitude?.roll ?? 0))
                    let rotationY = Float(attitude.pitch - (self?.initialAttitude?.pitch ?? 0))

                    // Notificar sobre a atualização usando o callback
                    self?.onUpdate?(CGFloat(rotationX), CGFloat(rotationY))
                }
            }
        }
    }
    
    // Parando atualizacoes quando nao sao necessarias
    func stopMotionUpdates() {
        manager.stopDeviceMotionUpdates()
    }
}
