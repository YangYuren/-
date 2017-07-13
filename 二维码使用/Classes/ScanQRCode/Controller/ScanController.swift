//
//  ScanController.swift
//  二维码使用
//
//  Created by Yang on 2017/6/8.
//  Copyright © 2017年 Yang. All rights reserved.
//

import UIKit
import AVFoundation
class ScanController: UIViewController {

    @IBOutlet weak var scroll: NSLayoutConstraint!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var chongjiboView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanView.isHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startScanAnimate()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scanView.isHidden = false
        startScan()
    }
    func startScan()->(){
        QRCodeTool.shareInstance.setRectImterest(rect: scanView.frame)
        QRCodeTool.shareInstance.scanQRCodeImage(inView: view, isDarwFrame: true) { (result :[String]) in
            print(result)
        }
    }
}
extension ScanController{
    func startScanAnimate(){
        scroll.constant = scanView.frame.size.height
        view.layoutIfNeeded()
        scroll.constant = -scanView.frame.height
        UIView.animate(withDuration: 2) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        }
    }
    func removeScanAnimate() {//移除动画
        chongjiboView.layer.removeAllAnimations()
    }
    
    
}
