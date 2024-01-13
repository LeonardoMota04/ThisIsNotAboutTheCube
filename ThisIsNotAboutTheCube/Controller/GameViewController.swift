import UIKit
import SceneKit

class ViewController: UIViewController, ObservableObject{
    
    // MARK: - VARIABLES
    // SCREEN
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // SCENE
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var rubiksCube: RubiksCube!

    // TOUCHES
    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    var rotationAxis:SCNVector3!
    
    // CONTROL VARIABLES
    var animationLock = false
    var shouldFloat = true
    
    // PUBLISHED VARIABLES (SWIFTUI)
    @Published var numOfMovements: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createRubiksCube()
        setupFloatingAnimation()
        setupCamera()
        setupLights()
        setupGestureRecognizers()
    }
    
    // MARK: - SCENE
    func setupScene() {
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)

        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
    }

    // MARK: - CUBE
    func createRubiksCube() {
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
    }

    // MARK: - FLOATING ANIMATION (PHASE)
    func setupFloatingAnimation() {
        let floatUp = SCNAction.move(by: SCNVector3(0, 0.3, 0), duration: 1.0)
        let floatDown = SCNAction.move(by: SCNVector3(0, -0.3, 0), duration: 1.0)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let floatForever = SCNAction.repeatForever(floatSequence)

        if shouldFloat {
            //rubiksCube.runAction(floatForever)
        }
    }

    // MARK: - CAMERA
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)

        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
    }

    // MARK: - LIGHTS
    func setupLights() {
        // Sphere that follows the camera to illuminate the top of the cube
        let sphereGeometry = SCNSphere(radius: 0.1)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        sphereGeometry.materials = [orangeMaterial]
        sphereNode.position = SCNVector3(0, 1.5, -5)
        cameraNode.addChildNode(sphereNode)
        
        // Light above cube
        let light_Omni = SCNLight()
        light_Omni.type = .omni
        light_Omni.intensity = 1200
        light_Omni.color = UIColor.white
        let lightNode_Omni = SCNNode()
        lightNode_Omni.light = light_Omni
        lightNode_Omni.position = sphereNode.position
        sphereNode.addChildNode(lightNode_Omni)
        
        // Ambient light
        let light_Ambient = SCNLight()
        light_Ambient.type = .ambient
        light_Ambient.color = UIColor.white
        light_Ambient.intensity = 10
        let lightNode_Ambient = SCNNode()
        lightNode_Ambient.light = light_Ambient
        rootNode.addChildNode(lightNode_Ambient)
    }

    // MARK: - GESTURE RECOGNIZERS
    func setupGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneTouched(_:)))
        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2 {
            // ROTATIONS
            let old_Rotation = cameraNode.rotation as SCNQuaternion
            var new_Rotation = GLKQuaternionMakeWithAngleAndAxis(old_Rotation.w, old_Rotation.x, old_Rotation.y, old_Rotation.z)

            // VELOCITY
            let xVelocity = Float(recognizer.velocity(in: sceneView).x) * 0.1
            let yVelocity = Float(recognizer.velocity(in: sceneView).y) * 0.1
            let velocity = xVelocity + yVelocity
            
            // AXIS
            let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity/screenWidth, 0, 1, 0)
            let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity/screenHeight, 1, 0, 0)
            
            // NETS
            let rotation_Net = GLKQuaternionMultiply(rotX, rotY)
            new_Rotation = GLKQuaternionMultiply(new_Rotation, rotation_Net)
            
            // NEW AXIS AND ANGLE
            let axis = GLKQuaternionAxis(new_Rotation)
            let angle = GLKQuaternionAngle(new_Rotation)
            
            cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
        }

        
        // MARK: - 1 FINGER: CUBE
        // gets first touch
        if recognizer.numberOfTouches == 1
            && hitResults.count > 0
            && recognizer.state == UIGestureRecognizer.State.began
            && beganPanNode == nil {

            beganPanHitResult = hitResults[0]
            beganPanNode = hitResults[0].node
        }
        
        // when the touch ends
        else if recognizer.state == UIGestureRecognizer.State.ended
                    && beganPanNode != nil
                    && animationLock == false {
            animationLock = true
            
            // TOQUE
            let touch_Location = recognizer.location(in: sceneView); // posicao do toque
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates); // coordenadas do ponto inicial do toque em 3D
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(touch_Location.x),
                                                                      Float(touch_Location.y),
                                                                      projectedOrigin.z) );

            // PLANO
            var plane = "?";
            var direction = 1;
            
            //
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x; // movimento relativo desde o inicio do toque ate o momento atual
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y;
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z;
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            // LADO TOCADO
            var side:CubeSide!
            side = selectedCubeSide(hitResult: beganPanHitResult, edgeDistanceFromOrigin: 0.975)
            

            
            if side == CubeSide.none {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            // MARK: - DIRECTION
            // DIREITA ou ESQUERDA
            if side == CubeSide.right || side == CubeSide.left {
                if absYDiff > absZDiff {
                    plane = "Y";
                    if side == CubeSide.right {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
                else {
                    plane = "Z";
                    if side == CubeSide.right {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                }
            }
            
            // CIMA ou BAIXO
            else if side == CubeSide.up || side == CubeSide.down {
                if absXDiff > absZDiff {
                    plane = "X";
                    if side == CubeSide.up {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.up {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // TRÁS ou FRENTE
            else if side == CubeSide.back || side == CubeSide.front {
                if absXDiff > absYDiff {
                    plane = "X";
                    if side == CubeSide.back {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Y"
                    if side == CubeSide.back {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // MARK: - ROTATION AXIS && POSITIONS
            let nodesToRotate =  rubiksCube.childNodes { (child, _) -> Bool in
                
                // PLANO Z - DIREITA E ESQUERDA ou PLANO X - FRENTE E TRÁS
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Z")
                    || ((side == CubeSide.front || side == CubeSide.back) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,1,0) // Y
                    return child.position.y.nearlyEqual(b: self.beganPanNode.position.y, tolerance: 0.025)
                }
                
                
                // PLANO Y - DIREITA E ESQUERDA ou PLANO X - CIMA E BAIXO
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1) // Z
                        return child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: 0.025)
                }
                
                
                // PLANO Y - FRENTE E TRÁS ou PLANO Z - CIMA E BAIXO
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                        self.rotationAxis = SCNVector3(1,0,0) // X
                        return child.position.x.nearlyEqual(b: self.beganPanNode.position.x, tolerance: 0.025)
                }
                
                
                return false;
            }
            
            // this shouldnt happen, so exit
            if nodesToRotate.count <= 0 {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            // add nodes we want to rotate to a parent node so that we can rotate relative to the root
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                container.addChildNode(nodeToRotate)
            }
            
            // create action
            let rotationAngle = CGFloat(direction) * .pi/2;
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)
            
            let rotatedSide = selectedCubeSide(hitResult: beganPanHitResult, edgeDistanceFromOrigin: 0.975)
            let moveNotation = convertToMoveNotation(rotatedSide: rotatedSide, plane: plane, direction: direction)
           


            // TIRANDO NODES DO CONTAINER
            container.runAction(rotation_Action, completionHandler: { () -> Void in
                for node: SCNNode in nodesToRotate {
                    let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                self.numOfMovements += 1
                print("\n\nLADO NORTE RESOLVIDO: \(self.rubiksCube.isNorthWallSolved())")
                //print("CHILDNODE\(self.rubiksCube.childNodes.debugDescription)")
                print("\nROTACAO ANGULO: \(rotationAngle) / ROTACAOaxis: \(self.rotationAxis!)")
                print("lado: \(side!)")
                print("plano: \(plane)")
                print("direction: \(direction)")
                print("Move Notation: \(moveNotation)")
                print("NUM DE MOVIMENTOS: \(self.numOfMovements)")
                self.animationLock = false
                self.animationLock = false
                self.beganPanNode = nil
            })
        }
    }
    
    func convertToMoveNotation(rotatedSide: CubeSide, plane: String, direction: Int) -> String {
        let sideNotation: String
        let directionNotation: String

        // Identificar o lado rotacionado
        let rotatedSideNotation: String
        switch rotatedSide {
        case .up:
            rotatedSideNotation = "U"
        case .down:
            rotatedSideNotation = "D"
        case .right:
            rotatedSideNotation = "R"
        case .left:
            rotatedSideNotation = "L"
        case .front:
            rotatedSideNotation = "F"
        case .back:
            rotatedSideNotation = "B"
        case .none:
            rotatedSideNotation = ""
        }

        // Identificar o lado tocado (o lado oposto ao rotacionado)
        switch plane {
        case "X":
            sideNotation = direction > 0 ? "U" : "D"
        case "Y":
            sideNotation = direction > 0 ? "R" : "L"
        case "Z":
            sideNotation = direction > 0 ? "F" : "B"
        default:
            sideNotation = ""
        }

        // Identificar a direção da rotação
        directionNotation = direction < 0 ? "'" : ""

        // Se o lado rotacionado for diferente do lado tocado, então adicione a notação do lado rotacionado
        if rotatedSideNotation != sideNotation {
            return rotatedSideNotation + directionNotation
        }

        // Caso contrário, retorne a notação do lado tocado
        return sideNotation + directionNotation
    }

    
    private func selectedCubeSide(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float) -> CubeSide {
        
        // X
        if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return .right
        }
        else if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return .left
        }
        
        // Y
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return .up
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return .down
        }
        
        // Z
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return .front
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return .back
        }
        return .none
    }
}

