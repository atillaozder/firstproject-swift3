//
//  RippleEffect.swift
//  FirstProject
//
//  Created by FirstProject on 8.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import QuartzCore

final class RippleEffect: CAReplicatorLayer {
    
    // MARK: - Properties
    
    fileprivate var _animationKey: String?
    fileprivate var _baseLayer: CALayer?
    fileprivate var _animationGroup: CAAnimationGroup?
    
    var animationKey: String {
        get {
            return _animationKey!
        }
        set {
            _animationKey = newValue
        }
    }

    var animationGroup: CAAnimationGroup {
        get {
            return _animationGroup!
        }
    }
    
    var animationDuration: CFTimeInterval = 3.0 {
        didSet {
            updateInstanceDelay()
        }
    }
    
    var numberOfLayers: Float = 0 {
        didSet {
            if numberOfLayers < 1 {
                numberOfLayers = 1
            }
            instanceCount = Int(numberOfLayers)
            updateInstanceDelay()
        }
    }
    
    var interval: TimeInterval = 0 {
        didSet {
            updateInstanceDelay()
        }
    }
    
    var radius: CGFloat = 150.0 {
        didSet {
            updateLayer()
        }
    }
    
    var initialLayerScale: Float = 0.0 {
        didSet {
            updateLayer()
        }
    }
    
    var opacityValues: [NSNumber] = [0.0, 0.0, 0.0] {
        didSet {
            updateLayer()
        }
    }
    
    var isAnimating: Bool {
        guard _animationGroup != nil else {
            return false
        }
        return true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    // MARK: - Constructor
    
    override init() {
        super.init()
        repeatCount = Float.infinity
        _baseLayer = CALayer()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(pause), name: .UIApplicationDidEnterBackground, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(resume), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        instanceDelay = 0.4
        instanceCount = Int(numberOfLayers)
    }
    
    // MARK: - Actions
    
    func start() {
        setupBaseLayer()
        setupAnimationGroup()
        _baseLayer?.add(_animationGroup!, forKey: _animationKey!)
    }
    
    func stop() {
        _baseLayer?.removeAnimation(forKey: animationKey)
        _animationGroup = nil
    }
    
    // MARK: - Helpers
    
    private func updateLayer() {
        let diameter: CGFloat = radius * 2
        _baseLayer?.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        _baseLayer?.cornerRadius = radius
    }
    
    private func updateInstanceDelay() {
        instanceDelay = (animationDuration - interval) / Double(numberOfLayers)
    }
    
    private func setupBaseLayer() {
        _baseLayer?.contentsScale = UIScreen.main.scale
        _baseLayer?.opacity = 0
        addSublayer(_baseLayer!)
    }
    
    private func setupAnimationGroup() {
        _animationGroup = CAAnimationGroup()
        _animationGroup?.duration = animationDuration
        _animationGroup?.repeatCount = self.repeatCount
        _animationGroup?.isRemovedOnCompletion = false
        _animationGroup?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        _animationGroup?.animations = [createScaleAnimation(), createOpacityAnimation()]
        _animationGroup?.delegate = self
    }
    
    private func createScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: initialLayerScale)
        scaleAnimation.toValue = NSNumber(value: 1.0)
        scaleAnimation.duration = animationDuration
        
        return scaleAnimation
    }
    
    private func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = opacityValues
        opacityAnimation.keyTimes = [0, 0.2, 1.0]
        
        return opacityAnimation
    }
    
    func setColorAndBorder(color: CGColor, borderColor: CGColor = UIColor.clear.cgColor, borderWidth: CGFloat = 0.0) {
        _baseLayer?.backgroundColor = color
        _baseLayer?.borderColor = borderColor
        _baseLayer?.borderWidth = borderWidth
    }
    
    // MARK: - To String
    
    func toString() -> String {
        return "BaseLayer: \(String(describing: _baseLayer!.animation(forKey: animationKey))), radius: \(radius), initialLayerScale: \(initialLayerScale), interval: \(interval), opacityValues: \(opacityValues.count), animationKey: \(animationKey), backgroundColor: \(String(describing: _baseLayer!.backgroundColor)), borderWidth: \(_baseLayer!.borderWidth), borderColor: \(String(describing: _baseLayer!.borderColor)))"
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    func pause() {
//        let pausedTime: CFTimeInterval = _baseLayer.convertTime(CACurrentMediaTime(), from: nil)
//        _baseLayer.speed = 0.0
//        _baseLayer.timeOffset = pausedTime
//    }
//    
//    func resume() {
//        if _baseLayer.superlayer == nil {
//            addSublayer(_baseLayer)
//        }
//        
//        let pausedTime: CFTimeInterval = _baseLayer.timeOffset
//        _baseLayer.speed = 1.0
//        _baseLayer.timeOffset = 0.0
//        _baseLayer.beginTime = 0.0
//        let timeSincePause: CFTimeInterval = _baseLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
//        _baseLayer.beginTime = timeSincePause
//    }
    
}

extension RippleEffect: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let keys = _baseLayer?.animationKeys(), keys.count > 0 {
            _baseLayer?.removeAllAnimations()
        }
        _baseLayer?.removeFromSuperlayer()
    }
}
