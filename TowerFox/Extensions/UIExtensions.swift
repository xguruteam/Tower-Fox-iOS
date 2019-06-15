//
//  UIExtensions.swift
//  PBSG
//
//  Created by cgc on 5/8/18.
//  Copyright © 2018 rockdevat. All rights reserved.
//

import UIKit
import CoreImage
import UserNotifications
import UserNotificationsUI
import Accelerate
import MapKit
import SVProgressHUD
typealias CCImage = CIImage
import CoreLocation
import Contacts

func getServiceConnectivityURL(_ serverIP: String) -> String
{
    return SERVICE_PROTOCOL + serverIP + SERVICES_PATH + "/Service1.svc/json/ServiceConnectivityTest"
}

func getDeviceInfoURL() -> String
{
    return getApplicationURL() + "SaveDeviceInfo";
}

func getProjectsByProjectIDURL() -> String
{
    return getApplicationURL() + "GetProjectsbyID";
}

func getCategorybyprjtIDURL(_ _projectID: String) -> String
{
    return getApplicationURL() + "GetProjectCategorybyprjtID/" + _projectID;
}

func GetPhotosByprjtIDURL(_ _projectID: String) -> String
{
    return getApplicationURL() + "GetProjectPhotosByprjtID/" + _projectID;
}

func getSectorsURL() -> String
{
    return getApplicationURL() + "GetSectors";
}

func getPositionsURL() -> String
{
    return getApplicationURL() + "GetSectorPosition";
}

func UpdateProjectPhotosURL() -> String
{
    return getApplicationURL() + "UpdateProjectPhotos";
}
func getProjectPhotosURL() -> String
{
    return getApplicationURL() + "GetProjectPhotosByProjectsSyncInfo";
}
func getReferencePhotosURL() -> String
{
    return getApplicationURL() + "GetReferencePhotosByProjectsSyncInfo";
}

func getCapturedPhotosURL() -> String
{
    return getApplicationURL() + "GetCapturedPhotosByProjectsSyncInfo";
}
func getValidateUserURL() -> String
{
    return getApplicationURL() + "AuthenticateNSiteUser";
}
func getLogoutDeviceInfoURL() -> String
{
    return getApplicationURL() + "DeleteDeviceInfoLogOut";
}
func getDeleteProjectURL() -> String
{
    return getApplicationURL() + "DeleteDeviceInfoByProject";
}

func getApplicationURL() -> String
{
    if storage_loadObject("SERVER_IP") != nil {
        return SERVICE_PROTOCOL + storage_loadObject("SERVER_IP")! + SERVICES_PATH + "/Service1.svc/json/"
    }else{
        return SERVICE_PROTOCOL + "" + SERVICES_PATH + "/Service1.svc/json/"
    }
}

func storage_loadObject(_ key: String) -> String?{
    if UserDefaults.standard.object(forKey: key) != nil {
        return "\(UserDefaults.standard.object(forKey: key)!)"
    }else{
        return nil
    }
}

func storage_removeItem(_ key: String){
    if UserDefaults.standard.object(forKey: key) != nil {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

func storage_saveObject(_ key: String, _  object: Any) {
    UserDefaults.standard.set(object, forKey: key)
    UserDefaults.standard.synchronize()
    //console.log(storage_ContainsKey(key) + " Contains Form");
}

func guid() -> String {
    return UUID().uuidString
}
extension UIViewController {
    @objc func disbleTabBar() {
        self.navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    func getOrderStatus(_ status: Int) -> String {
        if (status == 1) {
            return "Received by retailer"
        } else if (status == 2) {
            return "In Processing"
        } else if (status == 3) {
            return "In Reserve"
        } else if (status == 5) {
            return "Passed on for delivery"
        } else if (status == 6) {
            return "Accepted for delivery"
        } else if (status == 7) {
            return "On the Way"
        } else if (status == 8) {
            return "Deliverd"
        } else if (status == 9) {
            return "Finished"
        } else {
            return "\(status)"
        }
    }
    func getStatusBackgroundColor(_ status: Int) -> UIColor {
        if status < 5 {
            return UIColor.yellow
        }else if status == 6 || status == 7 {
            return UIColor.green
        }else if status == 8 || status == 9 {
            return UIColor.gray
        }else {
            return UIColor.gray
        }
    }
    
    func lookUpAddress(_ location: CLLocation, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        let geocoder = CLGeocoder()
        print(location)
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                print(placemarks as Any)
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        }
    }
    
}

struct Address {
    
    
    static func formattedAddressForPlacemark(placemark: CLPlacemark, includeName: Bool = true, withLineBreaks: Bool = true, showCountryIfUSA: Bool = false) -> String {
        do {
            let zipPlus4RegEx = try NSRegularExpression(pattern: "\\-\\d{4}", options: [])
            var addressArray = [String]()
            _ = 0
            
            if placemark.name != nil && includeName { addressArray.append(placemark.name!) }
            if placemark.subLocality != nil { addressArray.append(placemark.subLocality!) } // Neighborhood
            
            let streetNumber = placemark.subThoroughfare != nil ? placemark.subThoroughfare! + " " : ""
            let streetName = placemark.thoroughfare != nil ? placemark.thoroughfare: ""
            let streetAddress = "\(streetNumber)\(streetName!)"
            if streetAddress.count > 0 { addressArray.append(streetAddress) }
            
            let city = placemark.locality != nil ? placemark.locality : ""
            let state = placemark.administrativeArea != nil ? city != nil ? ", " + placemark.administrativeArea! : placemark.administrativeArea : ""
            
            var postalCode = ""
            
            if let placemarkPostalCode = placemark.postalCode {
                let trimmedPostalCode = zipPlus4RegEx.stringByReplacingMatches(in: placemarkPostalCode, options: [], range: NSMakeRange(0, placemarkPostalCode.count), withTemplate: "")
                postalCode = state != "" ? " " + trimmedPostalCode : trimmedPostalCode
            }
            
            let localityAdministrativeAreaPostalCode = "\(city!)\(state!)\(postalCode)"
            if localityAdministrativeAreaPostalCode.count > 0 { addressArray.append(localityAdministrativeAreaPostalCode) }
            
            if showCountryIfUSA && placemark.country != nil { addressArray.append(placemark.country!) }
            
            let orderedSet = NSOrderedSet(array: addressArray)
            
            let separator = withLineBreaks ? "\n" : ", "
            
            return (orderedSet.array as! [String]).joined(separator: separator)
        }
        catch let error {
            print("NSRegularExpression init failed: \(error.localizedDescription)")
            // do something imaginative here
            return ""
        }
    }
    
    static func formattedAddressForMapItem(mapItem: MKMapItem, includeName: Bool = true, withLineBreaks: Bool = true, showCountryIfUSA: Bool = false) -> String {
        let placemark = mapItem.placemark as CLPlacemark
        return formattedAddressForPlacemark(placemark: placemark, includeName: includeName, withLineBreaks: withLineBreaks, showCountryIfUSA: showCountryIfUSA)
    }
    
}

extension UIColor {
    
    public convenience init(rgba: String) {
        let colorStr = rgba.replacingOccurrences(of: "#", with: "")
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let scanner = Scanner(string: colorStr)
        var hexValue: CUnsignedLongLong = 0
        
        if scanner.scanHexInt64(&hexValue) {
            let length = colorStr.count
            
            switch (length) {
            case 3:
                r = CGFloat((hexValue & 0xF00) >> 8)    / 15.0
                g = CGFloat((hexValue & 0x0F0) >> 4)    / 15.0
                b = CGFloat(hexValue & 0x00F)           / 15.0
            case 4:
                r = CGFloat((hexValue & 0xF000) >> 12)  / 15.0
                g = CGFloat((hexValue & 0x0F00) >> 8)   / 15.0
                b  = CGFloat((hexValue & 0x00F0) >> 4)  / 15.0
                a = CGFloat(hexValue & 0x000F)          / 15.0
            case 6:
                r = CGFloat((hexValue & 0xFF0000) >> 16)    / 255.0
                g = CGFloat((hexValue & 0x00FF00) >> 8)     / 255.0
                b  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                r = CGFloat((hexValue & 0xFF000000) >> 24)  / 255.0
                g = CGFloat((hexValue & 0x00FF0000) >> 16)  / 255.0
                b = CGFloat((hexValue & 0x0000FF00) >> 8)   / 255.0
                a = CGFloat(hexValue & 0x000000FF)          / 255.0
            default:
                print("Invalid number of values (\(length)) in HEX string. Make sure to enter 3, 4, 6 or 8 values. E.g. `aabbccff`")
            }
            
        } else {
            print("Invalid HEX value: \(rgba)")
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:CGFloat((netHex >> 16) & 0xff) / 255.0,
                  green:CGFloat((netHex >> 8) & 0xff) / 255.0,
                  blue:CGFloat(netHex & 0xff) / 255.0,
                  alpha: 1)
    }
    
    convenience init(rgb: UInt, alphaVal: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal)
        )
    }
    
    static func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat(arc4random_uniform(256))/255,
            green: CGFloat(arc4random_uniform(256))/255,
            blue: CGFloat(arc4random_uniform(256))/255,
            alpha: 1)
    }
    static let appMainColor = UIColor(rgba: "#465A50")//177FC3
    static let appBlueColor = UIColor(rgba: "#1f69b3")
    static let appRedColor = UIColor(rgba: "#E23E3E")
    static let appMainDarkColor = UIColor(rgba: "#283d14")
    
    static let appGrayColor = UIColor(rgba: "#898989")
    static let appLightGrayColor = UIColor(rgba: "#F0F0F0")
    static let appDarkGrayColor = UIColor(rgba: "#6F7179")
    static let appOrangeColor = UIColor(rgba: "#FC9D00")
    static let appButtonGrayColor = UIColor(rgba: "#B0B0B0")
    static let appGreenColor = UIColor(rgba: "#3D973E")
    
}

extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        if UIDevice().iPhoneX {
            sizeThatFits.height = 78
        }else{
            sizeThatFits.height = 44
        }
        return sizeThatFits
    }
}

public extension CIColor {
    
    /// Creates a CIColor from an rgba string
    ///
    /// E.g.
    ///     `aaa`
    ///     `ff00`
    ///     `bb00ff`
    ///     `aabbccff`
    ///
    /// - parameter rgba:    The hex string to parse in rgba format
    public convenience init(rgba: String) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let scanner = Scanner(string: rgba)
        var hexValue: CUnsignedLongLong = 0
        
        if scanner.scanHexInt64(&hexValue) {
            let length = rgba.count
            
            switch (length) {
            case 3:
                r = CGFloat((hexValue & 0xF00) >> 8)    / 15.0
                g = CGFloat((hexValue & 0x0F0) >> 4)    / 15.0
                b = CGFloat(hexValue & 0x00F)           / 15.0
            case 4:
                r = CGFloat((hexValue & 0xF000) >> 12)  / 15.0
                g = CGFloat((hexValue & 0x0F00) >> 8)   / 15.0
                b  = CGFloat((hexValue & 0x00F0) >> 4)  / 15.0
                a = CGFloat(hexValue & 0x000F)          / 15.0
            case 6:
                r = CGFloat((hexValue & 0xFF0000) >> 16)    / 255.0
                g = CGFloat((hexValue & 0x00FF00) >> 8)     / 255.0
                b  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                r = CGFloat((hexValue & 0xFF000000) >> 24)  / 255.0
                g = CGFloat((hexValue & 0x00FF0000) >> 16)  / 255.0
                b = CGFloat((hexValue & 0x0000FF00) >> 8)   / 255.0
                a = CGFloat(hexValue & 0x000000FF)          / 255.0
            default:
                print("Invalid number of values (\(length)) in HEX string. Make sure to enter 3, 4, 6 or 8 values. E.g. `aabbccff`")
            }
            
        } else {
            print("Invalid HEX value: \(rgba)")
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
}

internal typealias Scale = (dx: CGFloat, dy: CGFloat)

internal extension CIImage {
    /// Creates an `UIImage` with interpolation disabled and scaled given a scale property
    ///
    /// - parameter withScale:  a given scale using to resize the result image
    ///
    /// - returns: an non-interpolated UIImage
    internal func nonInterpolatedImage(withScale scale: Scale = Scale(dx: 1, dy: 1)) -> UIImage? {
        guard let cgImage = CIContext(options: nil).createCGImage(self, from: self.extent) else { return nil }
        let size = CGSize(width: self.extent.size.width * scale.dx, height: self.extent.size.height * scale.dy)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // reduce size to 50KB
    class func reduceSizeOf(image: UIImage) -> Data {
        var newImage = image
        var compression: CGFloat = 1
        var imgData = UIImageJPEGRepresentation(newImage, compression)//newImage.jpegData(compressionQuality: compression)
        while (imgData?.count)! > 51200 {
            if newImage.size.width > CGFloat(500) && newImage.size.height > CGFloat(800) {
                if newImage.size.width/newImage.size.height > 0 {
                    // If width > height
                    let multiplier = 800 / newImage.size.height
                    newImage = newImage.scaledToWidth(multiplier*newImage.size.width)
                } else {
                    newImage = newImage.scaledToWidth(500)
                }
            } else {
                guard compression > 0.0 else {break}
                imgData = UIImageJPEGRepresentation(newImage, compression)//newImage.jpegData(compressionQuality: compression)
                compression -= 0.1
            }
        }
        return imgData!
    }
    
    func resizeImage(newHeight: CGFloat) -> UIImage {
        let image = self;
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    convenience init(view: UIView) {
        _ = view.frame
        if view.isKind(of: UITableView.self) {
        }
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    
    func scaledToWidth(_ scaledToWidth: CGFloat) -> UIImage! {
        let oldWidth = self.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func scaledToHeight(_ scaledToHeight: CGFloat) -> UIImage! {
        let oldHeight = self.size.height
        let scaleFactor = scaledToHeight / oldHeight
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldHeight * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func scaledAspect(_ size: CGSize) -> UIImage! { //10x15
        
        var ratio = CGFloat(0)
        
        if (self.size.width > self.size.height) {
            ratio = CGFloat(1000) / self.size.width;
        } else {
            ratio = CGFloat(1000) / self.size.height;
        }
        let newWidth = self.size.width * ratio;
        let  newHeight = self.size.height * ratio;
        
        
        
        var drawBox = self.size //150x100
        if drawBox.width >= size.width && drawBox.height >= size.height { //true
            
            while drawBox.width > newWidth || drawBox.height > newHeight {
                drawBox.width *= 0.9
                drawBox.height *= 0.9
            }
            
        }
        
        
        
        
        UIGraphicsBeginImageContext(drawBox)
        self.draw(in: CGRect(x: 0, y: 0, width: drawBox.width, height: drawBox.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func roundedImage(_ size: CGSize) -> UIImage! {
        // Get your image somehow
        let image = self
        
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: size.width/2) //bezierPathWithRoundedRect:imageView.bounds
        //cornerRadius:10.0] addClip];
        path.addClip()
        // Draw your image
        image.draw(in: path.bounds)
        //        [image drawInRect:imageView.bounds];
        path.lineWidth *= 2
        //        UIColor(red: 63/255.0, green: 255/255.0, blue: 161/255.0, alpha: 1).setStroke()
        UIColor.black.setStroke()
        path.stroke()
        // Get the image, here setting the UIImageView image
        let result = UIGraphicsGetImageFromCurrentImageContext();
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext();
        
        return result
    }
    
    func tintedBackgroundImageWithColor(_ tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: .sourceAtop, alpha: 1)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return tintedImage!;
    }
    
    func scale(image originalImage: UIImage, toLessThan maxResolution: CGFloat) -> UIImage? {
        guard let imageReference = originalImage.cgImage else { return nil }
        
        let rotate90 = CGFloat.pi/2.0 // Radians
        let rotate180 = CGFloat.pi // Radians
        let rotate270 = 3.0*CGFloat.pi/2.0 // Radians
        
        let originalWidth = CGFloat(imageReference.width)
        let originalHeight = CGFloat(imageReference.height)
        let originalOrientation = originalImage.imageOrientation
        
        var newWidth = originalWidth
        var newHeight = originalHeight
        
        if originalWidth > maxResolution || originalHeight > maxResolution {
            let aspectRatio: CGFloat = originalWidth / originalHeight
            newWidth = aspectRatio > 1 ? maxResolution : maxResolution * aspectRatio
            newHeight = aspectRatio > 1 ? maxResolution / aspectRatio : maxResolution
        }
        
        let scaleRatio: CGFloat = newWidth / originalWidth
        var scale: CGAffineTransform = .init(scaleX: scaleRatio, y: -scaleRatio)
        scale = scale.translatedBy(x: 0.0, y: -originalHeight)
        
        var rotateAndMirror: CGAffineTransform
        
        switch originalOrientation {
        case .up:
            rotateAndMirror = .identity
            
        case .upMirrored:
            rotateAndMirror = .init(translationX: originalWidth, y: 0.0)
            rotateAndMirror = rotateAndMirror.scaledBy(x: -1.0, y: 1.0)
            
        case .down:
            rotateAndMirror = .init(translationX: originalWidth, y: originalHeight)
            rotateAndMirror = rotateAndMirror.rotated(by: rotate180 )
            
        case .downMirrored:
            rotateAndMirror = .init(translationX: 0.0, y: originalHeight)
            rotateAndMirror = rotateAndMirror.scaledBy(x: 1.0, y: -1.0)
            
        case .left:
            (newWidth, newHeight) = (newHeight, newWidth)
            rotateAndMirror = .init(translationX: 0.0, y: originalWidth)
            rotateAndMirror = rotateAndMirror.rotated(by: rotate270)
            scale = .init(scaleX: -scaleRatio, y: scaleRatio)
            scale = scale.translatedBy(x: -originalHeight, y: 0.0)
            
        case .leftMirrored:
            (newWidth, newHeight) = (newHeight, newWidth)
            rotateAndMirror = .init(translationX: originalHeight, y: originalWidth)
            rotateAndMirror = rotateAndMirror.scaledBy(x: -1.0, y: 1.0)
            rotateAndMirror = rotateAndMirror.rotated(by: rotate270)
            
        case .right:
            (newWidth, newHeight) = (newHeight, newWidth)
            rotateAndMirror = .init(translationX: originalHeight, y: 0.0)
            rotateAndMirror = rotateAndMirror.rotated(by: rotate90)
            scale = .init(scaleX: -scaleRatio, y: scaleRatio)
            scale = scale.translatedBy(x: -originalHeight, y: 0.0)
            
        case .rightMirrored:
            (newWidth, newHeight) = (newHeight, newWidth)
            rotateAndMirror = .init(scaleX: -1.0, y: 1.0)
            rotateAndMirror = rotateAndMirror.rotated(by: CGFloat.pi/2.0)
        }
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.concatenate(scale)
        context.concatenate(rotateAndMirror)
        context.draw(imageReference, in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copy
    }
    
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage(draw: { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: CGRect(x: 0.0,y: 0.0,width: self.size.width,height: self.size.height))
            
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: CGRect(x: 0.0,y: 0.0,width: self.size.width,height: self.size.height))
        })
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    //    func fillAlpha(fillColor: UIColor) -> UIImage {
    //
    //        return modifiedImage { context, rect in
    //            // draw tint color
    //            CGContextSetBlendMode(context, .Normal)
    //            fillColor.setFill()
    //            CGContextFillRect(context, rect)
    //
    //            // mask by alpha values of original image
    //            CGContextSetBlendMode(context, .DestinationIn)
    //            CGContextDrawImage(context, rect, self.CGImage)
    //        }
    //    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        
        let rect = CGRect(x:0.0, y:0.0, width:size.width, height:size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     Tint, Colorize image with given tint color<br><br>
     This is similar to Photoshop's "Color" layer blend mode<br><br>
     This is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved<br><br>
     white will stay white and black will stay black as the lightness of the image is preserved<br><br>
     
     <img src="http://yannickstephan.com/easyhelper/tint1.png" height="70" width="120"/>
     
     **To**
     
     <img src="http://yannickstephan.com/easyhelper/tint2.png" height="70" width="120"/>
     
     - parameter tintColor: UIColor
     
     - returns: UIImage
     */
    func tintPhoto(_ tintColor: UIColor) -> UIImage {
        
        return modifiedImage(draw: { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(context.makeImage()!, in: rect)
        })
    }
    
    /**
     Tint Picto to color
     
     - parameter fillColor: UIColor
     
     - returns: UIImage
     */
    func tintPicto(_ fillColor: UIColor) -> UIImage {
        
        return modifiedImage(draw: { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(cgImage!, in: rect)
        })
    }
    
    /**
     Modified Image Context, apply modification on image
     
     - parameter draw: (CGContext, CGRect) -> ())
     
     - returns: UIImage
     */
    fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func inverseImage(cgResult: Bool) -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
            //            return UIImage(CGImage: CIContext(options: nil).createCGImage(result, fromRect: result.extent)!)
        }
        return UIImage(ciImage: result)
    }
    
}

extension UIImageView {
    var imageA: UIImage? {
        get {
            return image
        }
        set {
            UIView.transition(with: self,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.image = newValue;  },
                              completion: nil)
            
        }
    }
}

extension UIButton {
    func adjustImageAndTitleOffsets() {
        guard self.imageView != nil else {return}
        let spacing: CGFloat = 6.0
        
        let imageSize = self.imageView!.frame.size
        
        titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        
        let titleSize = titleLabel!.frame.size
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
    }
    /// Enum to determine the title position with respect to the button image
    ///
    /// - top: title above button image
    /// - bottom: title below button image
    /// - left: title to the left of button image
    /// - right: title to the right of button image
    @objc enum Position: Int {
        case top, bottom, left, right
    }
    
    /// This method sets an image and title for a UIButton and
    ///   repositions the titlePosition with respect to the button image.
    ///
    /// - Parameters:
    ///   - image: Button image
    ///   - title: Button title
    ///   - titlePosition: UIViewContentModeTop, UIViewContentModeBottom, UIViewContentModeLeft or UIViewContentModeRight
    ///   - additionalSpacing: Spacing between image and title
    ///   - state: State to apply this behaviour
    @objc func set(image: UIImage?, title: String, titlePosition: Position, additionalSpacing: CGFloat, state: UIControlState){
        imageView?.contentMode = .center
        setImage(image, for: state)
        setTitle(title, for: state)
        titleLabel?.contentMode = .center
        
        adjust(title: title as NSString, at: titlePosition, with: additionalSpacing)
        
    }
    
    /// This method sets an image and an attributed title for a UIButton and
    ///   repositions the titlePosition with respect to the button image.
    ///
    /// - Parameters:
    ///   - image: Button image
    ///   - title: Button attributed title
    ///   - titlePosition: UIViewContentModeTop, UIViewContentModeBottom, UIViewContentModeLeft or UIViewContentModeRight
    ///   - additionalSpacing: Spacing between image and title
    ///   - state: State to apply this behaviour
    @objc func set(image: UIImage?, attributedTitle title: NSAttributedString, at position: Position, width spacing: CGFloat, state: UIControlState){
        imageView?.contentMode = .center
        setImage(image, for: state)
        
        adjust(attributedTitle: title, at: position, with: spacing)
        
        titleLabel?.contentMode = .center
        setAttributedTitle(title, for: state)
    }
    
    
    // MARK: Private Methods
    
    @objc private func adjust(title: NSString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        
        // Use predefined font, otherwise use the default
        let titleFont: UIFont = titleLabel?.font ?? UIFont()
        let titleSize: CGSize = title.size(withAttributes: [NSAttributedStringKey.font: titleFont])
        
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    
    @objc private func adjust(attributedTitle: NSAttributedString, at position: Position, with spacing: CGFloat) {
        let imageRect: CGRect = self.imageRect(forContentRect: frame)
        let titleSize = attributedTitle.size()
        
        arrange(titleSize: titleSize, imageRect: imageRect, atPosition: position, withSpacing: spacing)
    }
    
    @objc private func arrange(titleSize: CGSize, imageRect:CGRect, atPosition position: Position, withSpacing spacing: CGFloat) {
        switch (position) {
        case .top:
            titleEdgeInsets = UIEdgeInsets(top: -(imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: spacing / 2 + titleSize.height, left: -imageRect.width/2, bottom: 0, right: -imageRect.width/2)
        case .bottom:
            titleEdgeInsets = UIEdgeInsets(top: (imageRect.height + titleSize.height + spacing), left: -(imageRect.width), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -imageRect.width/2, bottom: spacing / 2 + titleSize.height, right: -imageRect.width/2)
        case .left:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageRect.width * 2), bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleSize.width * 2 + spacing))
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        }
    }
    
    
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func regular() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
}

extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    func becomeFront() {
        kMainQueue.async {
            //            self.superview?.bringSubviewToFront(self)
            self.superview?.bringSubview(toFront: self)
        }
    }
    
    func moveBack() {
        kMainQueue.async {
            //            self.superview?.sendSubviewToBack(self)
            self.superview?.sendSubview(toBack: self)
        }
    }
    
    func copyView() -> UIView
    {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as! UIView
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    
    func addGradientBackgound(firstColor: UIColor, SecondColor: UIColor, topToBottom: Bool) {
        self.layoutIfNeeded()
        self.removeGradients()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [firstColor.cgColor, SecondColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: topToBottom ? 0.0 : 1.0)
        gradient.endPoint = CGPoint(x: topToBottom ? 1.0 : 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width + 2, height: self.bounds.size.height)
        gradient.name = "grad"
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradients() {
        self.layer.sublayers?.forEach({ (layer) in
            if layer.name == "grad" {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    func round(corners: UIRectCorner, radii: Int, withBorder: UIColor? = nil) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radii, height:  radii))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        if withBorder != nil {
            let borderLayer = CAShapeLayer()
            borderLayer.path = path.cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = withBorder!.cgColor
            borderLayer.lineWidth = 2
            borderLayer.frame = self.bounds
            self.layer.sublayers?.forEach{ if $0.isKind(of: CAShapeLayer.self) { $0.removeFromSuperlayer() } }
            self.layer.addSublayer(borderLayer)
        }
    }
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func dropShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = self.backgroundColor?.cgColor
        self.backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}

extension UITableViewCell {
    static func registerSelf(to tableView: UITableView?) {
        let nib = UINib(nibName: self.className, bundle: Bundle.main)
        tableView?.register(nib, forCellReuseIdentifier: self.className)
    }
}


extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

//extension UIUserNotificationType {
//
//    @available(iOS 10.0, *)
//    func authorizationOptions() -> UNAuthorizationOptions {
//        var options: UNAuthorizationOptions = []
//        if contains(.alert) {
//            options.formUnion(.alert)
//        }
//        if contains(.sound) {
//            options.formUnion(.sound)
//        }
//        if contains(.badge) {
//            options.formUnion(.badge)
//        }
//        return options
//    }
//}
struct Constants {
    static let clientId = "2e8edd0c6e284caebda9ed455dfbb1e3"
    static let redirectUri = "Randevu.date"
}

extension UILabel{
    func addTextSpacing(spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSRange(location: 0, length: self.text!.count))
        self.attributedText = attributedString
    }
    func fit(_ string: String?) -> Int {
        let font: UIFont? = self.font
        let mode: NSLineBreakMode? = self.lineBreakMode
        let labelWidth: CGFloat? = self.frame.size.width
        let labelHeight: CGFloat? = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth ?? 0.0, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: string ?? "", attributes: (attributes as Any as! [NSAttributedStringKey : Any]))
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        do {
            if boundingRect.size.height > (labelHeight ?? 0.0) {
                var index: Int = 0
                var prev: Int
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == .byCharWrapping {
                        index += 1
                    } else {
                        index = Int((string as NSString?)?.rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: (string?.count ?? 0) - index - 1)).location ?? 0)
                    }
                } while index != NSNotFound && index < (string?.count ?? 0) && (((string as NSString?)?.substring(to: index))?.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: (attributes as Any as! [NSAttributedStringKey : Any]), context: nil).size.height ?? 0.0) <= (labelHeight ?? 0.0)
                return prev
            }
        }
        return string?.count ?? 0
    }
}
extension UIViewController {
    /*    If staticStatisticCode = W or L or HOLD or SV
     Then display staticStatistic as integer (e.g., 10)
     Else If staticStatisticCode = FPPG or ERA or WHIP
     Then display staticStatistic as decimal to the hundredths (e.g., 10.44)
     Else If staticStatisticCode = AVG or OBP
     Then display staticStatistic as decimal to the thousandths (with no zero beforehand) (e.g., .444)
     Else display staticStatistic as decimal to the tenths (e.g., 10.3)
     
     If statisticCode = Comp% or Net Yds or IP or K/9
     Then display activeGameplayStatistic as decimal to the tenths (e.g., 10.3)
     Else If statisticCode = FPTS or ERA or WHIP
     Then display activeGameplayStatistic as decimal to the hundredths (e.g., 10.44)
     Else If statisticCode = AVG or OBP
     Then display activeGameplayStatistic as decimal to the thousandths (with no zero beforehand) (e.g.,
     .444)
     Else display activeGameplayStatistic as integer (e.g., 10)
     */
    func showHUD() {
            appDel.hud = MBProgressHUD.showAdded(to: appDel.navigationController.view, animated: true)
            appDel.hud.label.text = ""
    }
    
    func hideHUD() {
        if appDel.hud != nil {
                appDel.hud.hide(animated: true)
        }
    }
    func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    func isValidPhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func showErrorMessage(_ message: String?, title: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlertWith(_ title: String?, message: String, confirmButtonTitle: String?, confirmActionBlock: (() -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let confirmButtonTitle = confirmButtonTitle {
            let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { (_) in
                if let confirmActionBlock = confirmActionBlock {
                    confirmActionBlock()
                }
            }
            
            alertController.addAction(confirmAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWith(_ title: String?, message: String, confirmButtonTitle: String?, confirmActionBlock: (() -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        if let confirmButtonTitle = confirmButtonTitle {
            let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { (_) in
                if let confirmActionBlock = confirmActionBlock {
                    confirmActionBlock()
                }
            }
            
            alertController.addAction(confirmAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func lockView() {
        let darkView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        darkView.tag = 321
        darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.tag = 321
        spinner.startAnimating()
        spinner.center = darkView.center
        
        if let superView = view.superview {
            superView.addSubview(darkView)
            superView.addSubview(spinner)
        } else {
            view.addSubview(darkView)
            view.addSubview(spinner)
        }
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func unlockView() {
        UIApplication.shared.endIgnoringInteractionEvents()
        if let superView = view.superview {
            superView.subviews.forEach{ if $0.tag == 321 {$0.removeFromSuperview()} }
        } else {
            view.subviews.forEach{ if $0.tag == 321 {$0.removeFromSuperview()} }
        }
    }
    
    func shake(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    func hideKeyboard()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func keyboardDidShow(_ noti: Notification){
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidHide(_ noti: Notification){
        self.view.gestureRecognizers?.forEach({self.view.removeGestureRecognizer($0)})
    }
    
    func backTwo() {
        let viewcontrollers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewcontrollers[viewcontrollers.count - 3], animated: true)
        
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = (frame?.offsetBy(dx: 0, dy: offsetY!))!
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! < self.view.frame.maxY
    }
    
}
extension AppDelegate {
    func staticStatisticFormat(_ staticStatistic: Double, _ staticStatisticCode: String) -> String{
        var str = ""
        if staticStatisticCode == "W" || staticStatisticCode == "L" || staticStatisticCode == "HOLD" || staticStatisticCode == "SV"{
            str = String(format: "%d %@", Int(staticStatistic), staticStatisticCode)
        }else if staticStatisticCode == "FPPG" || staticStatisticCode == "ERA" || staticStatisticCode == "WHIP" {
            str = String(format: "%.2lf %@", staticStatistic, staticStatisticCode)
        }else if staticStatisticCode == "AVG" || staticStatisticCode == "OBP" {
            str = String(format: "%.3lf %@", staticStatistic, staticStatisticCode)
            str = str.replacingOccurrences(of: "0.", with: ".")
        }else{
            str = String(format: "%.1lf %@", staticStatistic, staticStatisticCode)
        }
        return str
    }
    
    func activeGameplayStatisticFormat(_ activeGameplayStatistic: Double, _ statisticCode: String) -> String{
        var str = ""
        if statisticCode == "Comp%" || statisticCode == "Net Yds" || statisticCode == "IP" || statisticCode == "K/9"{
            str = String(format: "%.1lf %@", activeGameplayStatistic, statisticCode)
        }else if statisticCode == "FPTS" || statisticCode == "ERA" || statisticCode == "WHIP" {
            str = String(format: "%.2lf %@", activeGameplayStatistic, statisticCode)
        }else if statisticCode == "AVG" || statisticCode == "OBP" {
            str = String(format: "%.3lf %@", activeGameplayStatistic, statisticCode)
            str = str.replacingOccurrences(of: "0.", with: ".")
        }else{
            str = String(format: "%d %@", Int(activeGameplayStatistic), statisticCode)
        }
        return str
    }
    
    
}

extension UIButton {
    var titleLabelFont: UIFont! {
        get { return self.titleLabel?.font }
        set { self.titleLabel?.font = newValue }
    }
}

class Theme {
    static func apply() {
        applyToUIButton()
        // ...
    }
    
    // It can either theme a specific UIButton instance, or defaults to the appearance proxy (prototype object) by default
    static func applyToUIButton(a: UIButton = UIButton.appearance()) {
        a.titleLabelFont = UIFont(name: "ProximaNovaSoft-Regular", size:12.0)
        // other UIButton customizations
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension UINavigationController {
    var previousViewController: UIViewController? {
        if viewControllers.count > 1 {
            return viewControllers[viewControllers.count - 2]
        }
        return nil
    }
    
    func pushDissolve(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        //        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.layer.add(transition, forKey: nil)
        self.pushViewController(viewController, animated: false)
    }
    
    func popDissolve() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.layer.add(transition, forKey: nil)
        self.popViewController(animated: false)
    }
    
    func popToRootDissolve() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.layer.add(transition, forKey: nil)
        self.popToRootViewController(animated: false)
    }
    
}

extension CLLocationCoordinate2D {
    // In meteres
    static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
let appDel = UIApplication.shared.delegate as! AppDelegate
extension UIApplication {
    
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
    
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4 = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
let textfiledpadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

extension UITextView {
    func visibleTextRange() -> NSRange {
        let bounds: CGRect = self.bounds
        let startCharacterRange = self.characterRange(at: bounds.origin)
        var startposition:UITextPosition!
        if startCharacterRange == nil {
            startposition = self.beginningOfDocument
        }else{
            startposition = startCharacterRange?.start
        }
        
        let endCharacterRange = self.characterRange(at: CGPoint(x: bounds.maxX, y: bounds.maxY))
        if endCharacterRange == nil {
            return NSRange(location: 0, length: 0)
        }
        let endposition = endCharacterRange?.end
        let startIndex = self.offset(from: self.beginningOfDocument, to: startposition!)
        let endIndex = self.offset(from: startposition!, to: endposition!)
        return NSRange(location: startIndex, length: endIndex)
        
        //        (self.text as! NSString).size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Semibold", size: 16.0)])
        //        let bounds: CGRect = self.bounds
        //        let textSize: CGSize = text.size(withFont: font, constrainedTo: bounds.size)
        //        let start: UITextPosition? = characterRange(at: bounds.origin)?.start
        //        let end: UITextPosition? = characterRange(at: CGPoint(x: textSize.width, y: textSize.height))?.end
        //        var startPoint: Int? = nil
        //        if let aStart = start {
        //            startPoint = offset(from: beginningOfDocument, to: aStart)
        //        }
        //        var endPoint: Int? = nil
        //        if let aStart = start, let anEnd = end {
        //            endPoint = offset(from: aStart, to: anEnd)
        //        }
        //        return NSRange(location: startPoint ?? 0, length: endPoint ?? 0)
    }
    
}

