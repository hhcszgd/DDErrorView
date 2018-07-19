//
//  DDErrorView.swift
//  Project
//
//  Created by WY on 2018/6/29.
//  Copyright © 2018年 HHCSZGD. All rights reserved.
//

import UIKit

class DDErrorView: UIView {
    var isHideWhenWhitespaceClick = false
    weak var currentSuperView : UIView?
    var deinitHandle : (()-> ())?
    let reloadButton = UIButton()
    let errorMessage = UILabel()
    let errorImage = UIImageView()
    var manualRemoveAfterActionHandle  : (()-> ())?
    var automaticRemoveAfterActionHandle  : (()-> ())?
    var error : DDError?
    init(superView : UIView , error : DDError) {
        super.init(frame: superView.bounds)
        for subview in superView.subviews {
            if subview.isKind(of: DDErrorView.self){
                return
            }
        }
        self.backgroundColor = UIColor.white
//        self.alpha = 0
        self.currentSuperView = superView
        superView.addSubview(self)
        superView.bringSubview(toFront: self)
        self.frame = currentSuperView?.bounds ?? CGRect.zero
        self.error = error
        self.addSubview(reloadButton)
        reloadButton.backgroundColor = UIColor.orange
        reloadButton.setTitle("点击刷新", for: UIControlState.normal)
        reloadButton.addTarget(self , action: #selector(reloadAction(sender:)), for: UIControlEvents.touchUpInside)
        reloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        errorMessage.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(errorMessage)
        errorMessage.textAlignment = .center
        self.addSubview(errorImage)
//        errorImage.image = UIImage(named:"feedback_icon")
        errorMessage.textColor = UIColor.blue
        errorMessage.text = "there is something wrong"
        errorImage.contentMode = .scaleAspectFit
        self.addObserver()
    }
    
    func addObserver()  {
        NotificationCenter.default.addObserver(self , selector: #selector(netWordChanged), name: NSNotification.Name("DDNetworkChanged"), object: nil )
    }
    @objc func netWordChanged() {
        self.reloadAction(sender: self.reloadButton)
    }
    func removeObser() {
        NotificationCenter.default.removeObserver(self )
/*
         self.performPost( NSNotification.Name("DDNetworkChanged"), ["userInfo" : networkStatus])
         */
    }
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    override func didMoveToWindow(){
        super.didMoveToWindow()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.alpha = 1
//        }) { (bool ) in
//
//        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let offSet : CGFloat = 36
        self.reloadButton.bounds = CGRect(x: 0, y: 0, width: 110, height: 34)
        self.reloadButton.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 + offSet)
        self.errorMessage.frame = CGRect(x: 0, y: reloadButton.frame.minY - 34, width: self.bounds.width, height: 34)
        let errorImageW : CGFloat = 170
        let errorImageH : CGFloat = errorImageW / 1.6
        self.errorImage.frame = CGRect(x: self.bounds.width / 2 - errorImageW / 2, y: errorMessage.frame.minY - errorImageH, width: errorImageW, height: errorImageH )
        
        if let error = self.error{
            errorMessage.text = error.localizedDescription
            switch error {
            case .networkError:
                errorImage.image = UIImage(named:"nonetwork")
            case .serverError(let msg):
                var errorMsg = ""
                if let error_msg = msg{
                    errorMsg = error_msg
                }else{
                    errorMsg = "serverError"
                }
                errorImage.image = UIImage(named:"loadfailure")
                print(errorMsg)
            case .modelUnconvertable:
                print("modelUnconvertable")
            case .urlUnconvertable:
                 print("urlUnconvertable")
            case .noToken:
                print("noToken")
            case .otherError(let errMsg):
                let msg =  errMsg == nil ? "unknown error" : errMsg!
                print(msg)
            case .noExpectData(let msg):
                errorImage.image = UIImage(named:"nocontent")
                let errorMsg =  msg == nil ? "no data" : msg!
                print(errorMsg)
            case .timeOut:
                print(DDError.timeOut.localizedDescription)
            }
        }
        reloadButton.layer.cornerRadius = 5
        reloadButton.layer.masksToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func reloadAction(sender:UIButton) {
        if  self.automaticRemoveAfterActionHandle != nil {
            self.remove()
            self.automaticRemoveAfterActionHandle?()
        }else if self.manualRemoveAfterActionHandle != nil {
            self.manualRemoveAfterActionHandle?()
        }
    }
    @objc func remove() {
        self.subviews.forEach({ (subview) in
            subview.removeFromSuperview()
        })
        self.removeFromSuperview()
        self.deinitHandle?()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("corver view part touch")
        if let firstView = self.subviews.first{
            if let point = touches.first?.location(in: self){
                if firstView.frame.contains(point){
                    return
                }
            }
        }
        if isHideWhenWhitespaceClick {self.remove()}
        
    }
    
    deinit {
        self.deinitHandle?()
        removeObser()
        print("遮盖销毁")
    }
}




enum  DDError : Error {
    case timeOut
    case networkError
    case serverError(String?)
    case modelUnconvertable
    case urlUnconvertable
    case noToken
    case otherError(String?)
    case noExpectData(String?)
    var localizedDescription: String{
        switch self  {
        case .networkError:
            return "网络不稳定,请重试"
        case .serverError(let msg):
            return "加载失败"
            //            if let errorMsg = msg{
            //                return errorMsg
            //            }else{
            //                return "serverError"
            //
            //            }
            
        case .modelUnconvertable:
            return "modelUnconvertable"
            
        case .urlUnconvertable:
            return "urlUnconvertable"
            
        case .noToken:
            return "noToken"
        case .otherError(let errMsg):
            return errMsg == nil ? "unknown error" : errMsg!
        case .noExpectData(let msg):
            return "还没有内容"
        //            return msg == nil ? "还没有内容" : msg!
        case . timeOut:
            return  "加载失败"
            //            return "请求超时"
        }
    }
}
