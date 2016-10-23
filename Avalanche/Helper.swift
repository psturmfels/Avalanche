import Foundation
import UIKit

func RandomInt(min: Int, max: Int) -> Int {
	if max < min { return min }
	return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}

func deg2rad(_ degrees: Int) -> Double {
    return Double(degrees) * M_PI / 180.0
}

func RandomFloat() -> Float {
	return Float(arc4random()) /  Float(UInt32.max)
}

func RandomFloat(min: Float, max: Float) -> Float {
	return (Float(arc4random()) / Float(UInt32.max)) * (max - min) + min
}

func RandomDouble(min: Double, max: Double) -> Double {
	return (Double(arc4random()) / Double(UInt32.max)) * (max - min) + min
}

func RandomCGFloat() -> CGFloat {
	return CGFloat(RandomFloat())
}

func RandomCGFloat(min: Float, max: Float) -> CGFloat {
    return CGFloat(RandomFloat(min: min, max: max))
}

func RandomColor() -> UIColor {
	return UIColor(red: RandomCGFloat(), green: RandomCGFloat(), blue: RandomCGFloat(), alpha: 1)
}

func RunAfterDelay(_ delay: TimeInterval, block: @escaping ()->()) {
	let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
	DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}

func postNotification(withName name: String) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: nil)
}

func postNotification(withName name: String, andUserInfo info: [AnyHashable: Any]? ) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: info)
}
