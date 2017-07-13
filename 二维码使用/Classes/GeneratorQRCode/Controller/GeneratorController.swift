//
//  GeneratorController.swift
//  二维码使用
//
//  Created by Yang on 2017/6/8.
//  Copyright © 2017年 Yang. All rights reserved.
//

import UIKit
import CoreImage
import Foundation
class GeneratorController: UIViewController {
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var qrImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        let str = inputTextView.text ?? ""
        let center = UIImage(named: "123.jpg")
        qrImageView.image = QRCodeTool.generatorQRCode(inputStr: str, centerImage: center)
    }

}
