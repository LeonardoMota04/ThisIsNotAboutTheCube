//
//  CubeModel.swift
//  RubiksCubeSceneKit
//
//  Created by Leonardo Mota on 29/11/23.
//

import SceneKit

enum CubeSide {
    case front  // F
    case back   // B

    case right  // R
    case left   // L
    
    case up     // U
    case down   // D
    
    case none
}

class RubiksCube: SCNNode {
    
    let cubeWidth:CGFloat = 1
    //let spaceBetweenCubes:Float = 0.05
    let colors:[UIColor] = [.orange, .green, .red, .blue, .yellow, .white]

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        
        super.init()
        
        // MARK: - TESTE ========================================================================
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellow
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        // MARK: - TESTE ========================================================================

        
        let cubeOffsetDistance = self.cubeOffsetDistance()
        var xPos:Float = -cubeOffsetDistance
        var yPos:Float = -cubeOffsetDistance
        var zPos:Float = -cubeOffsetDistance
        
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    let cubeGeometry = SCNBox(width: cubeWidth,
                                              height: cubeWidth,
                                              length: cubeWidth,
                                              chamferRadius: 0.15)
                    if i == 0 && j == 0 {
                        cubeGeometry.materials = (k % 2 == 0) 
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, whiteMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 0 && j == 1 {
                        cubeGeometry.materials = (k % 2 == 0) 
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, yellowMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        cubeGeometry.materials = (k % 2 == 0) 
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, whiteMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 1 && j == 1 {
                        cubeGeometry.materials = (k % 2 == 0) 
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, yellowMaterial, blackMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
                    
                    
                    let cube = SCNNode(geometry: cubeGeometry)
                    cube.position = SCNVector3(x: xPos, y: yPos, z: zPos)
                    xPos += Float(cubeWidth) //+ spaceBetweenCubes
                    
                    self.addChildNode(cube)
                }
                xPos = -cubeOffsetDistance
                yPos += Float(cubeWidth) //+ spaceBetweenCubes
            }
            xPos = -cubeOffsetDistance
            yPos = -cubeOffsetDistance
            zPos += Float(cubeWidth) //+ spaceBetweenCubes
        }
    }
    
    private func cubeOffsetDistance()->Float {
        return Float((cubeWidth) / 2)
    }
    
    func getSouthWall() -> [SCNNode] {
        let southWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(b: self.cubeOffsetDistance(), tolerance: 0.01)
        }
        return southWallNodes
    }
    
    func getNorthWall() -> [SCNNode] {
        let northWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(b: -self.cubeOffsetDistance(), tolerance: 0.01)
        }
        return northWallNodes
    }
    
    func isNorthWallSolved() -> Bool {
        let northWallNodes = getNorthWall()
        let material = northWallNodes[0].geometry?.materials[0]
        for i in 1..<northWallNodes.count {
            if material != northWallNodes[i].geometry?.materials[0] {
                return false
            }
        }
        return true
    }
    
    func isSolved() -> Bool {
        return false
    }
    
    
}


extension Float {
//    func nearlyEqual(b: Float, tolerance: Float) -> Bool {
//        
//        let difference = abs(self - b)
//        // if the difference is irrelevant OR the greatest of them is smaller than the tolerance
//        return difference < tolerance || difference / max(abs(self), abs(b)) < tolerance
//        
//    }
    
    func nearlyEqual(b: Float, tolerance: Float) -> Bool {
        let a = self
        let absA = abs(a)
        let absB = abs(b)
        let diff = abs(a - b)
        
        if (a == b) {
            // Se a e b são iguais, não há necessidade de verificar mais nada.
            return true
        } else if (a == 0 || b == 0 || diff < Float.leastNormalMagnitude) {
            // Se a ou b é zero ou ambos são extremamente próximos de zero,
            // a comparação de erro relativo é menos significativa aqui.
            return diff < (tolerance * Float.leastNormalMagnitude)
        } else {
            // Usar erro relativo.
            return diff / (absA + absB) < tolerance
        }
    }

}

