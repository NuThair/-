//
//  Extention.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/08.
//  Copyright © 2016年 System. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func beginsWith (_ str: String) -> Bool {
        if let range = self.range(of: str) {
            return range.lowerBound == self.startIndex
        }
        return false
    }
    
    func endsWith (_ str: String) -> Bool {
        if let range = self.range(of: str) {
            return range.upperBound == self.endIndex
        }
        return false
    }
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }


    enum CharacterType {
        case Numeric, English, Katakana, Other
    }

    func transformFullwidthHalfwidth(transformTypes types :[CharacterType], reverse :Bool=false) -> String {
        var transformedChars :[String] = []

        let chars = self.map{ String($0) }
        chars.forEach{
            let halfwidthChar = NSMutableString(string: $0) as CFMutableString
            CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, false)
            let char = halfwidthChar as String

            if char.isNumber(transformHalfwidth: true) {
                if let _ = types.filter({$0 == .Numeric}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else if char.isEnglish(transformHalfwidth: true) {
                if let _ = types.filter({$0 == .English}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else if char.isKatakana() {
                if let _ = types.filter({$0 == .Katakana}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else {
                if let _ = types.filter({$0 == .Other}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
        }

        var transformedString = ""
        transformedChars.forEach{ transformedString += $0 }

        return transformedString
    }

    func isNumber(transformHalfwidth transform :Bool) -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, false)
        let str = halfwidthStr as String

        return Int(str) != nil ? true : false
    }

    func isEnglish(transformHalfwidth transform :Bool) -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        if transform {
            CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, false)
        }
        let str = halfwidthStr as String

        let pattern = "[A-z]*"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let result = regex.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.count), withTemplate: "")
            if result == "" { return true }
            else { return false }
        }
        catch { return false }
    }

    func isKatakana() -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, true)
        let str = halfwidthStr as String

        let pattern = "^[\\u30A0-\\u30FF]+$"
        do {           
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let result = regex.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.count), withTemplate: "")
            if result == "" { return true }
            else { return false }
        }
        catch { return false }
    }


    func toKatakana() -> String {
        var str = ""

        for c in unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x3096 {
                str += String(describing: UnicodeScalar(c.value + 96)!)
            } else {
                str += String(c)
            }
        }

        return str
    }

    func toHiragana() -> String {
        var str = ""

        for c in unicodeScalars {
            if c.value >= 0x30A1 && c.value <= 0x30F6 {
                str += String(describing: UnicodeScalar(c.value - 96)!)
            } else {
                str += String(c)
            }
        }
        
        return str
    }

    //絵文字など(2文字分)も含めた文字数を返します
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    //正規表現の検索をします
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.count > 0
    }
}
extension UIImage {
    func fixOrientation () -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        var transform = CGAffineTransform.identity
        typealias o = UIImage.Orientation
        let width = self.size.width
        let height = self.size.height
        
        switch (self.imageOrientation) {
        case o.down, o.downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case o.left, o.leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case o.right, o.rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        default: // o.Up, o.UpMirrored:
            break
        }
        
        switch (self.imageOrientation) {
        case o.upMirrored, o.downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case o.leftMirrored, o.rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default: // o.Up, o.Down, o.Left, o.Right
            break
        }
        let cgimage = self.cgImage
        //let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let ctx = CGContext(data: nil, width: Int(width), height: Int(height),bitsPerComponent: (cgimage?.bitsPerComponent)!, bytesPerRow: 0, space: (cgimage?.colorSpace!)!, bitmapInfo: (cgimage?.bitmapInfo.rawValue)!)
        //let ctx = CGBitmapContextCreate(nil, Int(width), Int(height),CGImageGetBitsPerComponent(cgimage), 0, CGImageGetColorSpace(cgimage), bitmapInfo.rawValue)
        
        ctx?.concatenate(transform)
        
        switch (self.imageOrientation) {
        case o.left, o.leftMirrored, o.right, o.rightMirrored:
            ctx?.draw(cgimage!, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            ctx?.draw(cgimage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        let cgimg = ctx?.makeImage()
        let img = UIImage(cgImage: cgimg!)
        return img
    }
}
extension Dictionary {
    mutating func merge<S: Sequence>(contentsOf other: S) where S.Iterator.Element == (key: Key, value: Value) {
        for (key, value) in other {
            self[key] = value
        }
    }

    func merged<S: Sequence>(with other: S) -> [Key: Value] where S.Iterator.Element == (key: Key, value: Value) {
        var dic = self
        dic.merge(contentsOf: other)
        return dic
    }
}

/** キーボード表示通知の便利拡張 */
extension NSNotification{
    /** 通知から「キーボードの開く時間」を取得 */
    func duration()->TimeInterval?{
        let duration:TimeInterval? = self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        return duration;
    }
    /** 通知から「表示されるキーボードの表示位置」を取得 */
    func rect()->CGRect?{
        let rowRect:NSValue? = self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let rect:CGRect? = rowRect?.cgRectValue
        return rect
    }

}
