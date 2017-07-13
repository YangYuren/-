//
//  QRCodeTool.swift
//  二维码使用
//
//  Created by Yang on 2017/6/8.
//  Copyright © 2017年 Yang. All rights reserved.
//

import UIKit
import AVFoundation

typealias ScanResultblock = ([String])->()
class QRCodeTool: NSObject {
    //单例对象
    static let shareInstance = QRCodeTool()
    //设置输入
    lazy var input : AVCaptureDeviceInput = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //设置输出
        var input : AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        }catch{
            return input!
        }
        return input!
    }()
    //设置输出
    lazy var output : AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        //创建会话  连接输入输出
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    //设置会话
    lazy var session : AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    //添加视频预览图层  让用户看到界面
    lazy var layer : AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    fileprivate var scanRresultBlock : ScanResultblock?
    fileprivate var isDrawFrame : Bool = false
    //扫描二维码图片
    func scanQRCodeImage(inView : UIView , isDarwFrame : Bool , resultBlock : @escaping ([String])->()){
        scanRresultBlock = resultBlock
        self.isDrawFrame = isDarwFrame
        if session.canAddInput(input)&&session.canAddOutput(output){
            session.addInput(input)
            session.addOutput(output)
        }else{
            return
        }
        //设置二维码可是识别  设置识别类型  必须要在输出添加会话之后设置
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        if inView.layer.sublayers == nil {
            layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(layer, at: 0)
        }else{
            let sublayers = (inView.layer.sublayers)!
            if !(sublayers.contains(layer)){
                layer.frame = inView.layer.bounds
                inView.layer.insertSublayer(layer, at: 0)
            }
        }
        //启动会话
        session.startRunning()
    }
    //设置兴趣扫描区域  承载视图
    func setRectImterest(rect : CGRect)->(){
            let bounds = UIScreen.main.bounds
            let x : CGFloat = rect.origin.x / bounds.size.width
            let y : CGFloat = rect.origin.y / bounds.size.height
            let width : CGFloat = rect.size.width / bounds.size.width
            let height : CGFloat = rect.size.height / bounds.size.height
            output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
    }
    // 识别二维码图片
    class func detectorQRCodeImage(image : UIImage ,isDrawQRCodeFrame : Bool) -> (resultString :[String]? , resultImage : UIImage){
        let imageCI = CIImage(image: image)
        //开始识别
        //创建一个二维码探测器
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        //直接探测二维码特征
        let features = dector?.features(in: imageCI!)
        //存储处理好的图片
        var resulImage = image
        //遍历图片特征
        var result = [String]()
        for feature in features! {
            let qrFeature = feature as! CIQRCodeFeature
            if isDrawQRCodeFrame{
                resulImage = drawFrame(sourceImage: resulImage, feature: qrFeature)
            }
            result.append(qrFeature.messageString!)
        }
        return (result,resulImage);
    }
    //生成二维码图片
    class func generatorQRCode(inputStr : String , centerImage : UIImage?) -> UIImage {
        //创建二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //恢复滤镜默认设置
        filter?.setDefaults()
        //设置滤镜数据
        let data = inputStr.data(using: .utf8)
        //KVC
        filter?.setValue(data, forKey: "inputMessage")
        //设置二维码的纠错率
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        //从二维码滤镜图片获取结果图片
        var image = filter?.outputImage
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)
        // 显示图片
        var resultImage = UIImage(ciImage: image!)
        if centerImage != nil{
            resultImage = getNewImage(sourceImage: resultImage, Center: centerImage!)
        }
        return resultImage
    }
}

extension QRCodeTool : AVCaptureMetadataOutputObjectsDelegate{
    //扫描结果之后调用
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if isDrawFrame{
            //移除上次的方框
            removeFrameLayer()
        }
        var resultStrs = [String]()
        for obj in metadataObjects {
            if (obj as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self) {
                //转化坐标  在预览图层上真正坐标
                let resultObj = layer.transformedMetadataObject(for: (obj as! AVMetadataObject))
                let qrObjc = resultObj as! AVMetadataMachineReadableCodeObject
                
                resultStrs.append(qrObjc.stringValue)
                print(qrObjc.corners)
                if isDrawFrame{
                    drawFrame(qrObj: qrObjc)
                }
            }
        }
        if scanRresultBlock != nil{
            scanRresultBlock!(resultStrs)
        }
    }
    func drawFrame(qrObj : AVMetadataMachineReadableCodeObject) -> () {
        let corn = qrObj.corners
        //借助一个图形层 来绘制
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.red.cgColor
        shapLayer.lineWidth = 10
        let path = UIBezierPath()
        var index = 0
        for co in corn! {
            let dict = co as! CFDictionary
            let point = CGPoint(dictionaryRepresentation: dict)
            //第一个点
            if index == 0{
                path.move(to: point!)
            }else{
                path.addLine(to: point!)
            }
            index += 1
        }
        path.close()
        
        shapLayer.path = path.cgPath
        layer.addSublayer(shapLayer)
    }
    func removeFrameLayer(){
        guard let suLayers = layer.sublayers else {
            return
        }
        for subLayer in suLayers {
            if subLayer.isKind(of: CAShapeLayer.self){
                subLayer.removeFromSuperlayer()
            }
        }
        
    }
}

extension QRCodeTool{
    fileprivate class func getNewImage(sourceImage : UIImage , Center : UIImage) -> UIImage {
        let size = sourceImage.size
        //开启图形上下文
        UIGraphicsBeginImageContext(size)
        //绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 绘制小图片
        let width : CGFloat = 90
        let height : CGFloat = 90
        let x : CGFloat = (size.width - width) * 0.5
        let y : CGFloat = (size.height - height) * 0.5
        Center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出来图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        return image!
    }
    fileprivate class func drawFrame(sourceImage : UIImage , feature : CIQRCodeFeature) -> UIImage {
        let size = sourceImage.size
        //开启绘制图像上下文
        UIGraphicsBeginImageContext(size)
        //绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        //转换坐标系位置（上下颠倒）
        let context = UIGraphicsGetCurrentContext()
        //swift3.0中取代了原来的CGContextScaleCTM
        context?.scaleBy(x: 1, y: -1)
        //swift3.0中取代了原来的CGContextTranlateCTM
        context?.translateBy(x: 0, y: -size.height)
        //绘制方框
        let bouns = feature.bounds
        let path = UIBezierPath(rect: bouns)
        UIColor.yellow.setStroke()
        path.lineWidth = 10
        path.stroke()
        //获取图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        //结束绘制图片上下文
        UIGraphicsEndImageContext()
        //返回图片
        return resultImage!
    }
}
