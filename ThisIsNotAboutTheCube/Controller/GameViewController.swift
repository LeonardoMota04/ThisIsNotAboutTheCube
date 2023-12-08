import UIKit
import SceneKit

class ViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var rubiksCube: RubiksCube!

    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    var rotationAxis:SCNVector3!
    
    var animationLock = false
    
    var shouldFloat = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllerModel()
        
        
        
        // SCREEN
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)
        
        // SETUP SCENE
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear//UIColor(white: 0.9, alpha: 1.0)
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
        
       
        // criando CUBO e adicionando na cena
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
        
        // Criando a animação de flutuação
        let floatUp = SCNAction.move(by: SCNVector3(0, 0.3, 0), duration: 1.0)
        let floatDown = SCNAction.move(by: SCNVector3(0, -0.3, 0), duration: 1.0)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let floatForever = SCNAction.repeatForever(floatSequence)

        // Aplicando a animação ao cubo
        if shouldFloat {
            //rubiksCube.runAction(floatForever)
        }
        
        // criando CAMERA e adicionando na cena
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true;
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0);
        cameraNode.eulerAngles = .init(x: -0.8, y: 0.8, z: 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10);
 
        // gesture recognizers
        //let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(sceneRotated(_:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneTouched(_:)))

        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    
    // gesture handlers
    @objc
    func sceneRotated(_ recognizer: UIRotationGestureRecognizer) {
        let originalRotation = cameraNode.rotation as SCNQuaternion; // rotação atual, SCNQuaternion representa rotações tridimensionais
        var newRotation = GLKQuaternionMakeWithAngleAndAxis(originalRotation.w, originalRotation.x, originalRotation.y, originalRotation.z) // nova rotação
        let rotationSpeed: CGFloat = 1
        
        var velocity = recognizer.velocity
        if recognizer.velocity > 1 {
            velocity = rotationSpeed
        } else if recognizer.velocity < -1 {
            velocity = -rotationSpeed
        }

        let rotZ = GLKQuaternionMakeWithAngleAndAxis(0.1*Float((velocity)), 0, 0, 1) // rotação do cubo em espiral
        
        newRotation = GLKQuaternionMultiply(newRotation, rotZ)
        
        // Pegando o EIXO e ANGULO da rotação
        let axis = GLKQuaternionAxis(newRotation)
        let angle = GLKQuaternionAngle(newRotation)
        
        cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
    }

    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        // MARK: - DOIS DEDOS: MANIPULAR CAMERA
        if recognizer.numberOfTouches == 2 {
            // ROTATIONS
            let old_Rotation = cameraNode.rotation as SCNQuaternion;
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

        
        // MARK: - 1 DEDO: MANIPULAR CUBO
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
            let touch_Location = recognizer.location(in: sceneView);
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates);
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(touch_Location.x), 
                                                                      Float(touch_Location.y),
                                                                      projectedOrigin.z) );

            // PLANO
            var plane = "?";
            var direction = 1;
            
            // PONTO APROXIMADO
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x;
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y;
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z;
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            // LADO TOCADO
            var side:CubeSides!
            side = resolveCubeSize(hitResult: beganPanHitResult, edgeDistanceFromOrigin: 0.975)
            
            if side == CubeSides.none {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            // DIREITA ou ESQUERDA
            if side == CubeSides.right || side == CubeSides.left {
                if absYDiff > absZDiff {
                    plane = "Y";
                    if side == CubeSides.right {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Z";
                    if side == CubeSides.right {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // CIMA ou BAIXO
            else if side == CubeSides.up || side == CubeSides.down {
                if absXDiff > absZDiff {
                    plane = "X";
                    if side == CubeSides.up {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSides.up {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                }
            }
            
            // TRÁS ou FRENTE
            else if side == CubeSides.back || side == CubeSides.front {
                if absXDiff > absYDiff {
                    plane = "X";
                    if side == CubeSides.back {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Y"
                    if side == CubeSides.back {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // PEGANDO NODES QUE SERÃO ANIMADOS
            let nodesToRotate =  rubiksCube.childNodes { (child, _) -> Bool in
                // PLANO Z - DIREITA E ESQUERDA ou PLANO X - FRENTE E TRÁS
                if ((side == CubeSides.right || side == CubeSides.left) && plane == "Z")
                    || ((side == CubeSides.front || side == CubeSides.back) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,1,0) // Y
                    return child.position.y.nearlyEqual(b: self.beganPanNode.position.y, tolerance: 0.025)
                }
                // PLANO Y - DIREITA E ESQUERDA ou PLANO X - CIMA E BAIXO
                if ((side == CubeSides.right || side == CubeSides.left) && plane == "Y")
                    || ((side == CubeSides.up || side == CubeSides.down) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1) // Z
                        return child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: 0.025)
                }
                // PLANO Y - FRENTE E TRÁS ou PLANO Z - CIMA E BAIXO
                if ((side == CubeSides.front || side == CubeSides.back) && plane == "Y")
                    || ((side == CubeSides.up || side == CubeSides.down) && plane == "Z") {
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
            let rotationAngle = -CGFloat(direction) * .pi/2;
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.3)
            
            // TIRANDO NODES DO CONTAINER
            container.runAction(rotation_Action, completionHandler: { () -> Void in
                for node: SCNNode in nodesToRotate {
                    let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                print(self.rubiksCube.isNorthWallSolved())
                self.animationLock = false
                self.beganPanNode = nil
            })
        }
    }
    
    private func resolveCubeSize(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float)->CubeSides {
        
        if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.right
        }
        else if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.left
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.up
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.down
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.back
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: 0.025) {
            return CubeSides.front
        }
        return CubeSides.none
    }
    
    
}

extension ViewController: ViewControllerModel {
    func addSubviews() {
        //view.addSubview(pageTitle)
    }
    
    func addStyle() {
        //self.sceneView.backgroundColor = .systemGray
    }
    
    func addConstraints() {
        
    }
    
    
}

protocol ViewControllerModel {
    func addSubviews()
    func addStyle()
    func addConstraints()
}

extension ViewControllerModel {
    func setupViewControllerModel() {
        addSubviews()
        addStyle()
        addConstraints()
        
    }
}
