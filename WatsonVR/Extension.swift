//
//  Extension.swift
//  WatsonVR
//
//  Created by Yasuyuki Someya on 2018/01/04.
//  Copyright © 2018年 Yasuyuki Someya. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 上下逆になった画像を反転する
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// イメージ縮小
    func resizeImage(maxSize: Int) -> UIImage? {
        
        guard let jpg = UIImageJPEGRepresentation(self, 1) as NSData? else {
            return nil
        }
        if isLessThanMaxByte(data: jpg, maxDataByte: maxSize) {
            return self
        }
        // 80%に圧縮
        let size: CGSize = CGSize(width: (self.size.width * 0.8), height: (self.size.height * 0.8))
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        // 再帰処理
        return newImage.resizeImage(maxSize: maxSize)
    }
    
    /// 最大容量チェック
    func isLessThanMaxByte(data: NSData?, maxDataByte: Int) -> Bool {
        
        if maxDataByte <= 0 {
            // 最大容量の指定が無い場合はOK扱い
            return true
        }
        guard let data = data else {
            fatalError("Data unwrap error")
        }
        if data.length < maxDataByte {
            // 最大容量未満：OK　※以下でも良いがバッファを取ることにした
            return true
        }
        // 最大容量以上：NG
        return false
    }
}
