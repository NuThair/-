//
//  JSON.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/14.
//  Copyright © 2016年 System. All rights reserved.
//

import Foundation
/// init
open class JSON {
    fileprivate let _value:AnyObject
    /// pass the object that was returned from
    /// NSJSONSerialization
    public init(_ obj:AnyObject) { self._value = obj }
    /// pass the JSON object for another instance
    public init(_ json:JSON){ self._value = json._value }
}
/// class properties
extension JSON {
    public typealias NSNull = Foundation.NSNull
    public typealias NSError = Foundation.NSError
    public class var null:NSNull { return NSNull() }
    
    /// constructs JSON object from data
    public convenience init(data:Data) {
        let obj = try! JSONSerialization.jsonObject(
                with: data, options:[]) as AnyObject?
        self.init(obj!)
    }
    /// constructs JSON object from string
    public convenience init(string:String) {
        let enc:String.Encoding = String.Encoding.utf8
        self.init(data: string.data(using: enc)!)
    }
    /// parses string to the JSON object
    /// same as JSON(string:String)
    public class func parse(_ string:String)->JSON {
        return JSON(string:string)
    }
    /// constructs JSON object from the content of NSURL
    public convenience init(nsurl:URL) {
        var enc:String.Encoding = String.Encoding.utf8
        let err:NSError?
        do {
            let str:String = try NSString(contentsOf:nsurl, usedEncoding:&enc.rawValue) as String
            self.init(string:str)
        } catch let error1 as NSError {
            err = error1
            self.init(err!)
        }
    }
    /// fetch the JSON string from NSURL and parse it
    /// same as JSON(nsurl:NSURL)
    public class func fromNSURL(_ nsurl:URL) -> JSON {
        return JSON(nsurl:nsurl)
    }
    /// constructs JSON object from the content of URL
    public convenience init(url:String) {
        if let nsurl = URL(string:url) as URL? {
            self.init(nsurl:nsurl)
        } else {
            self.init(NSError(
                domain:"JSONErrorDomain",
                code:400,
                userInfo:[NSLocalizedDescriptionKey: "malformed URL"]
                )
            )
        }
    }
    /// fetch the JSON string from URL in the string
    public class func fromURL(_ url:String) -> JSON {
        return JSON(url:url)
    }
    /// does what JSON.stringify in ES5 does.
    /// when the 2nd argument is set to true it pretty prints
    /*
     public class func stringify(obj:AnyObject, pretty:Bool=false) -> String! {
     if !NSJSONSerialization.isValidJSONObject(obj) {
     JSON(NSError(
     domain:"JSONErrorDomain",
     code:422,
     userInfo:[NSLocalizedDescriptionKey: "not an JSON object"]
     ))
     return nil
     }
     return JSON(obj).toString(pretty)
     }
     */
}
/// instance properties
extension JSON {
    /// access the element like array
    public subscript(idx:Int) -> JSON {
        switch _value {
        case _ as NSError:
            return self
        case let ary as NSArray:
            if 0 <= idx && idx < ary.count {
                return JSON(ary[idx] as AnyObject)
            }
            return JSON(NSError(
                domain:"JSONErrorDomain", code:404, userInfo:[
                    NSLocalizedDescriptionKey:
                    "[\(idx)] is out of range"
                ]))
        default:
            return JSON(NSError(
                domain:"JSONErrorDomain", code:500, userInfo:[
                    NSLocalizedDescriptionKey: "not an array"
                ]))
        }
    }
    /// access the element like dictionary
    public subscript(key:String)->JSON {
        switch _value {
        case _ as NSError:
            return self
        case let dic as NSDictionary:
            //if let val:AnyObject = dic[key] { return JSON(val) }
            if let val:AnyObject = dic[key] as AnyObject? { return JSON(val) }
            return JSON(NSError(
                domain:"JSONErrorDomain", code:404, userInfo:[
                    NSLocalizedDescriptionKey:
                    "[\"\(key)\"] not found"
                ]))
        default:
            return JSON(NSError(
                domain:"JSONErrorDomain", code:500, userInfo:[
                    NSLocalizedDescriptionKey: "not an object"
                ]))
        }
    }
    /// access json data object
    public var data:AnyObject? {
        return self.isError ? nil : self._value
    }
    /// Gives the type name as string.
    /// e.g.  if it returns "Double"
    ///       .asDouble returns Double
    public var type:String {
        switch _value {
        case is NSError:        return "NSError"
        case is NSNull:         return "NSNull"
        case let o as NSNumber:
            switch String(cString: o.objCType) {
            case "c", "C":              return "Bool"
            case "q", "l", "i", "s":    return "Int"
            case "Q", "L", "I", "S":    return "UInt"
            default:                    return "Double"
            }
        case is NSString:               return "String"
        case is NSArray:                return "Array"
        case is NSDictionary:           return "Dictionary"
        default:                        return "NSError"
        }
    }
    /// check if self is NSError
    public var isError:      Bool { return _value is NSError }
    /// check if self is NSNull
    public var isNull:       Bool { return _value is NSNull }
    /// check if self is Bool
    public var isBool:       Bool { return type == "Bool" }
    /// check if self is Int
    public var isInt:        Bool { return type == "Int" }
    /// check if self is UInt
    public var isUInt:       Bool { return type == "UInt" }
    /// check if self is Double
    public var isDouble:     Bool { return type == "Double" }
    /// check if self is any type of number
    public var isNumber:     Bool {
        if let o = _value as? NSNumber {
            let t = String(cString: o.objCType)
            return  t != "c" && t != "C"
        }
        return false
    }
    /// check if self is String
    public var isString:     Bool { return _value is NSString }
    /// check if self is Array
    public var isArray:      Bool { return _value is NSArray }
    /// check if self is Dictionary
    public var isDictionary: Bool { return _value is NSDictionary }
    /// check if self is a valid leaf node.
    public var isLeaf:       Bool {
        return !(isArray || isDictionary || isError)
    }
    /// gives NSError if it holds the error. nil otherwise
    public var asError:NSError? {
        return _value as? NSError
    }
    /// gives NSNull if self holds it. nil otherwise
    public var asNull:NSNull? {
        return _value is NSNull ? JSON.null : nil
    }
    /// gives Bool if self holds it. nil otherwise
    public var asBool:Bool? {
        switch _value {
        case let o as NSNumber:
            switch String(cString: o.objCType) {
            case "c", "C":  return Bool(o.boolValue)
            default:
                return nil
            }
        default: return nil
        }
    }
    /// gives Int if self holds it. nil otherwise
    public var asInt:Int? {
        switch _value {
        case let o as NSNumber:
            switch String(cString: o.objCType) {
            case "c", "C":
                return nil
            default:
                return Int(o.int64Value)
            }
        default: return nil
        }
    }
    /// gives Double if self holds it. nil otherwise
    public var asDouble:Double? {
        switch _value {
        case let o as NSNumber:
            switch String(cString: o.objCType) {
            case "c", "C":
                return nil
            default:
                return Double(o.doubleValue)
            }
        default: return nil
        }
    }
    // an alias to asDouble
    public var asNumber:Double? { return asDouble }
    /// gives String if self holds it. nil otherwise
    public var asString:String? {
        switch _value {
        case let o as NSString:
            return o as String
        default: return nil
        }
    }
    public var asNSString:NSString? {
        switch _value {
        case let o as NSString:
            return o
        default: return nil
        }
    }
    /// if self holds NSArray, gives a [JSON]
    /// with elements therein. nil otherwise
    public var asArray:[JSON]? {
        switch _value {
        case let o as NSArray:
            var result = [JSON]()
            //for v:AnyObject in o { result.append(JSON(v)) }
            for v:Any in o { result.append(JSON(v as AnyObject)) }
            
            return result
        default:
            return nil
        }
    }
    /// if self holds NSDictionary, gives a [String:JSON]
    /// with elements therein. nil otherwise
    public var asDictionary:[String:JSON]? {
        switch _value {
        case let o as NSDictionary:
            var result = [String:JSON]()
            //for (k, v): (AnyObject, AnyObject) in o {
            for (k, v) in o {
                result[k as! String] = JSON(v as AnyObject)
            }
            return result
        default: return nil
        }
    }
    /// Yields date from string
    public var asDate:Date? {
        if let dateString = _value as? NSString {
            let dateFormatter = DateFormatter()
//            dateFormatter.timeZone = TimeZone(identifier:"GMT")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            var date = dateFormatter.date(from: dateString as String)
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                date = dateFormatter.date(from: dateString as String)
            }
            return date
        }
        return nil
    }
    /// gives the number of elements if an array or a dictionary.
    /// you can use this to check if you can iterate.
    public var length:Int {
        switch _value {
        case let o as NSArray:      return o.count
        case let o as NSDictionary: return o.count
        default: return 0
        }
    }
}
extension JSON : Sequence {
    public func makeIterator()->AnyIterator<(AnyObject,JSON)> {
        switch _value {
        case let o as NSArray:
            var i = -1
            return AnyIterator {
                i += 1
                if i == o.count { return nil }
                return (i as AnyObject, JSON(o[i] as AnyObject))
            }
        case let o as NSDictionary:
            var ks = Array(o.allKeys.reversed())
            return AnyIterator {
                if ks.isEmpty { return nil }
                let k = ks.removeLast() as! String
                return (k as AnyObject, JSON(o.value(forKey: k)! as AnyObject))
            }
        default:
            return AnyIterator{ nil }
        }
    }
    public func mutableCopyOfTheObject() -> AnyObject {
        return _value.mutableCopy as AnyObject
    }
}
/*
 extension JSON : CustomStringConvertible {
 /// stringifies self.
 /// if pretty:true it pretty prints
 public func toString(pretty:Bool=false)->String {
 switch _value {
 case is NSError: return "\(_value)"
 case is NSNull: return "null"
 case let o as NSNumber:
 switch String.fromCString(o.objCType)! {
 case "c", "C":
 return o.boolValue.description
 case "q", "l", "i", "s":
 return o.longLongValue.description
 case "Q", "L", "I", "S":
 return o.unsignedLongLongValue.description
 default:
 switch o.doubleValue {
 case 0.0/0.0:   return "0.0/0.0"    // NaN
 case -1.0/0.0:  return "-1.0/0.0"   // -infinity
 case +1.0/0.0:  return "+1.0/0.0"   //  infinity
 default:
 return o.doubleValue.description
 }
 }
 case let o as NSString:
 return o.debugDescription
 default:
 let opts = pretty ? (try? NSJSONWritingOptions.PrettyPrinted) : nil
 if let data = (try? NSJSONSerialization.dataWithJSONObject(
 _value, options:opts!)) as NSData? {
 if let nsstring = NSString(
 data:data, encoding:NSUTF8StringEncoding
 ) as NSString? {
 return nsstring as String
 }
 }
 return "YOU ARE NOT SUPPOSED TO SEE THIS!"
 }
 }
 public var description:String { return toString() }
 }
 */
