//
//  Dect0rController.swift
//  二维码使用
//
//  Created by Yang on 2017/6/8.
//  Copyright © 2017年 Yang. All rights reserved.
//

import UIKit
import CoreImage

class Dect0rController: UIViewController {

    @IBOutlet weak var sourceImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func dector() {
        //去除识别图片
        let image = sourceImage.image
        let result = QRCodeTool.detectorQRCodeImage(image: image!, isDrawQRCodeFrame: true)
        let resultStr = result.resultString
        sourceImage.image = result.resultImage
        //显示二维码中的信息
        let alert = UIAlertController(title: "结果提示", message: resultStr?.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "关闭", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
