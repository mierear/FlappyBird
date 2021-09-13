//
//  GameScene.swift
//  FlappyBird
//
//  Created by Danny Ruiz Galia on 10/29/18.
//  Copyright © 2018 com.dannyruizgalia.FlappyBird. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var pajaro = SKSpriteNode()
    var colorCielo = SKColor()
    var texturaTubo1 = SKTexture()
    var texturaTubo2 = SKTexture()
    var searacionTubos = 150
    var controlTubo = SKAction()
    
    let categoriaPajaro: UInt32 = 1 << 0
    let categoriaSuelo: UInt32 = 1 << 1
    let categoriaTubos: UInt32 = 1 << 2
    
    let movimiento = SKNode()
    var reset = false
    let conjuntoTubo = SKNode()
    
    override func didMove(to view: SKView){
        
        //agregar gravedad a la escena
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5)
        //asociar el contacto (notificar que ha habido un contacto entre los elementos
        self.physicsWorld.contactDelegate = self
        
        let texturaPajaro1 = SKTexture(imageNamed: "pajaro1")
        let texturaPajaro2 = SKTexture(imageNamed: "pajaro2")
        texturaPajaro1.filteringMode = SKTextureFilteringMode.nearest
        texturaPajaro2.filteringMode = SKTextureFilteringMode.nearest
        
        let aleteo = SKAction.animate(with: [texturaPajaro1,texturaPajaro2], timePerFrame: TimeInterval(0.1))
        let vuelo = SKAction.repeatForever(aleteo)
        
        pajaro = SKSpriteNode(texture: texturaPajaro1)
        pajaro.position = CGPoint(x: self.frame.midX/2.75,
                                  y: self.frame.midY)
        //Profundidad del pajaro en pantalla
        pajaro.zPosition = 0
        pajaro.run(vuelo)
        //pajaro.size = CGSize(width: 80, height: 60)
        
        //Agregar gravedad al pajaro
        //Darle forma fisica
        pajaro.physicsBody = SKPhysicsBody(circleOfRadius: pajaro.size.width/2)
        //Indicar si el pajaro es afectado por la fisica
        pajaro.physicsBody?.isDynamic = true
        //Indicar si la fisica lo harà rotar
        pajaro.physicsBody?.allowsRotation = false
        
        //Deteccion de colisiones
        pajaro.physicsBody?.categoryBitMask = categoriaPajaro
        //detectar colisiones con el suelo o tubos
        pajaro.physicsBody?.collisionBitMask = categoriaSuelo | categoriaTubos
        //hacer test de con quien ha chocado
        pajaro.physicsBody?.contactTestBitMask = categoriaSuelo | categoriaTubos
        
        
        //Agregar pajaro a la escena
        self.addChild(pajaro)
        
        //Cielo
        let texturaCielo = SKTexture(imageNamed: "cielo")
        
        texturaCielo.filteringMode = SKTextureFilteringMode.nearest
        
        //Animar cielo
        let movimientoCielo = SKAction.moveBy(x: -texturaCielo.size().width, y:0.0,
                                              duration: TimeInterval(0.018*texturaCielo.size().width))
        let resetCielo = SKAction.moveBy(x: texturaCielo.size().width, y: 0.0, duration: 0.0)
        let movimientoCieloContinuo = SKAction.repeatForever(SKAction.sequence([movimientoCielo, resetCielo]))
        
        //Agregar cielo
        var tope = Int(2 + self.frame.size.width/(texturaCielo.size().width))
        for i in 0...tope{
            let fraccionCielo = SKSpriteNode(texture: texturaCielo)
            fraccionCielo.zPosition = -99
            fraccionCielo.position = CGPoint(x: CGFloat(i) * fraccionCielo.size.width
                                            , y: fraccionCielo.size.height-99 )
            fraccionCielo.run(movimientoCieloContinuo)
            movimiento.addChild(fraccionCielo)
        }
        
        //color cielo
        colorCielo = SKColor(red: 115/255, green: 195/225, blue: 207/255, alpha:1.0)
        self.backgroundColor = colorCielo
        
        
        //Piso
        let texturaPiso = SKTexture(imageNamed: "suelo")
        texturaPiso.filteringMode = SKTextureFilteringMode.nearest
        
        //Animar piso
        let movimientoPiso = SKAction.moveBy(x: -texturaPiso.size().width, y: 0.0, duration: TimeInterval(0.004*texturaPiso.size().width))
        let resetPiso = SKAction.moveBy(x: texturaPiso.size().width, y: 0.0, duration: 0.0)
        let movimientoPisoContinuo = SKAction.repeatForever(SKAction.sequence([movimientoPiso, resetPiso]))
        
        //Agregar Piso
        var topePiso = Int(2 + self.frame.size.width/(texturaPiso.size().width))
        for i in 0...topePiso{
            let fraccionPiso = SKSpriteNode(texture: texturaPiso)
            fraccionPiso.zPosition = -30
            fraccionPiso.position = CGPoint(x: CGFloat(i) * fraccionPiso.size.width
                , y: fraccionPiso.size.height-48 )
            fraccionPiso.run(movimientoPisoContinuo)
            movimiento.addChild(fraccionPiso)
        }
        
        // Agregar tope invisible a nivel del suelo
        let topeSuelo = SKNode()
        topeSuelo.position = CGPoint(x: 0, y: texturaPiso.size().height/2)
        topeSuelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: texturaPiso.size().height))
        topeSuelo.physicsBody?.isDynamic = false
        
        //Agregar deteccion de colisiones:
        topeSuelo.physicsBody?.categoryBitMask = categoriaSuelo
        //detectar colision con el pajaro
        topeSuelo.physicsBody?.contactTestBitMask = categoriaPajaro
        self.addChild(topeSuelo)
        
        
        
        //Tubos
        texturaTubo1 = SKTexture(imageNamed: "tubo1")
        texturaTubo1.filteringMode = SKTextureFilteringMode.nearest
        
        texturaTubo2 = SKTexture(imageNamed: "tubo2")
        texturaTubo2.filteringMode = SKTextureFilteringMode.nearest
        
       
        
        let distanciaMovimiento = CGFloat(self.frame.size.width + 2 * texturaTubo1.size().width)
        let movimientoTubo = SKAction.moveBy(x: -distanciaMovimiento, y: 0.0, duration: TimeInterval(0.01*distanciaMovimiento))
        let eliminarTubo = SKAction.removeFromParent()
        controlTubo = SKAction.sequence([movimientoTubo, eliminarTubo])
        
        
        let crearTubo = SKAction.run {
            self.gestionTubos()
        }
        let retardo = SKAction.wait(forDuration: TimeInterval(2.5))
        let crearSiguienteTubo = SKAction.sequence([crearTubo,retardo])
        let crearTuboTrasTubo = SKAction.repeatForever(crearSiguienteTubo)
        
        self.run(crearTuboTrasTubo)
        
        self.addChild(movimiento)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //si movimiento tiene una velocidad mayor a cero, el pajaro podra moverse
        if(movimiento.speed > 0){
            //restarle velocidad al pajaro
            pajaro.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            //Hacer el pajaro volar con un click
            pajaro.physicsBody!.applyImpulse(CGVector.init (dx:0,dy:15))
        }else{
            self.resetJuego()
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        pajaro.zRotation = //pajaro.physicsBody!.velocity.dy > 0 ? 0.3: -1.2
            
            self.rotacion(min: -1, max: 0.5,
                                         valorActual: pajaro.physicsBody!.velocity.dy/400 + (pajaro.physicsBody!.velocity.dy < 0 ? 0.0003 : 0.0001 ))
        //print((pajaro.physicsBody!.velocity.dy/100).description)
    }
    
    func gestionTubos(){
        
        conjuntoTubo.position = CGPoint(x: self.frame.size.width + texturaTubo1.size().width, y: 0.0)
        conjuntoTubo.zPosition = -90
        
        let altura = UInt(self.frame.size.height / 3)
        //random
        let yy = UInt(arc4random())%altura
        
        let tubo1 = SKSpriteNode(texture: texturaTubo1)
        tubo1.position = CGPoint(x: Int(0), y: Int(yy))
        tubo1.physicsBody = SKPhysicsBody.init(rectangleOf: tubo1.size)
        tubo1.physicsBody!.isDynamic = false
        //detectar colisionescon el pajaro
        tubo1.physicsBody!.categoryBitMask = categoriaTubos
        tubo1.physicsBody!.contactTestBitMask = categoriaPajaro
        conjuntoTubo.addChild(tubo1)
        
        
        let tubo2 = SKSpriteNode(texture: texturaTubo2)
        tubo2.position = CGPoint(x: Int(0), y: Int(yy) + Int(tubo1.size.height) + Int(searacionTubos))
        tubo2.physicsBody = SKPhysicsBody.init(rectangleOf: tubo2.size)
        tubo2.physicsBody!.isDynamic = false
        //detectar colisionescon el pajaro
        tubo2.physicsBody!.categoryBitMask = categoriaTubos
        tubo2.physicsBody!.contactTestBitMask = categoriaPajaro
        conjuntoTubo.addChild(tubo2)
        
        conjuntoTubo.run(controlTubo)
        movimiento.addChild(conjuntoTubo)
        
    }
    
    func rotacion(min: CGFloat, max: CGFloat, valorActual:CGFloat)-> CGFloat{
        if(valorActual > max){
            //print( "max" + max.description)
            return max
        }else if(valorActual < min){
            //print ("min" + min.description)
            return min
        }else{
            //print("valorActual" + valorActual.description)
            return valorActual
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(movimiento.speed > 0){
            movimiento.speed = 0
            self.backgroundColor = UIColor.red
            //self.resetJuego()
            
        }
    }
    
    func resetJuego(){
        //color cielo
        
        /*
        colorCielo = SKColor(red: 115/255, green: 195/225, blue: 207/255, alpha:1.0)
        self.backgroundColor = colorCielo
        
        reset = true
        
        pajaro.position = CGPoint(x: self.frame.midX/2.75,
                                  y: self.frame.midY)
 
 */
        //movimiento.speed = 5
        
    }
    
    
}
