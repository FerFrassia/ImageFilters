//
//  ImageProcessor.swift
//  ImageFilters
//
//  Created by Fernando N. Frassia on 12/21/23.
//

import UIKit
import CoreGraphics
import Accelerate

class ImageProcessor {
    
    static func rotateAndFlip(_ originalImage: UIImage) -> UIImage? {
        let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))!
        
        guard let cgImage = originalImage.cgImage else {return nil}
        
        guard let sourceBuffer = try? vImage_Buffer(cgImage: cgImage,
                                              format: format) else {return nil}
        
        guard var destinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                         height: Int(sourceBuffer.height),
                                                         bitsPerPixel: format.bitsPerPixel) else {
                                                            return nil
        }
        
        verticalReflectBuffer(source: sourceBuffer, destination: &destinationBuffer)
        if let cgResult = try? destinationBuffer.createCGImage(format: format) {
            return UIImage(cgImage: cgResult)
        } else {
            return nil
        }
    }
    
    static func shear(_ originalImage: UIImage) -> UIImage? {
        let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))!
        
        guard let cgImage = originalImage.cgImage else {return nil}
        
        guard let sourceBuffer = try? vImage_Buffer(cgImage: cgImage,
                                              format: format) else {return nil}
        
        guard var destinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                         height: Int(sourceBuffer.height),
                                                         bitsPerPixel: format.bitsPerPixel) else {
                                                            return nil
        }
        
        let shearAngle = atan(Double(sourceBuffer.height) /
                              Double(sourceBuffer.width * 2)) *
                              180 / .pi
        verticalShearBuffer(source: sourceBuffer, destination: &destinationBuffer, byAngleInDegrees: shearAngle, verticalScale: 0.8)
        if let cgResult = try? destinationBuffer.createCGImage(format: format) {
            return UIImage(cgImage: cgResult)
        } else {
            return nil
        }
    }
    
    static func rotate90(_ originalImage: UIImage) -> UIImage? {
        let format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: .init(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))!
        
        guard let cgImage = originalImage.cgImage else {return nil}
        
        guard let sourceBuffer = try? vImage_Buffer(cgImage: cgImage,
                                              format: format) else {return nil}
        
        guard var destinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                         height: Int(sourceBuffer.height),
                                                         bitsPerPixel: format.bitsPerPixel) else {
                                                            return nil
        }
        

        rotateNinety(source: sourceBuffer, destination: &destinationBuffer, rotation: kRotate90DegreesClockwise)
        if let cgResult = try? destinationBuffer.createCGImage(format: format) {
            return UIImage(cgImage: cgResult)
        } else {
            return nil
        }
    }
    
    static func combine(_ img1: UIImage, _ img2: UIImage) -> UIImage? {
        guard let cgImg1 = img1.cgImage else {return nil}
        guard let cgImg2 = img2.cgImage else {return nil}
        if let combinedCGImage = alphaComposite(topImage: cgImg1, bottomImage: cgImg2) {
            return UIImage(cgImage: combinedCGImage)
        } else {
            return nil
        }
    }
    
    private static func verticalReflectBuffer(source: vImage_Buffer,
                                      destination: inout vImage_Buffer) {
        
        precondition(source.size == destination.size,
                     "Source and destination buffers need to have the same size.")
        
        _ = withUnsafePointer(to: source) { srcPointer in
            vImageVerticalReflect_ARGB8888(srcPointer,
                                           &destination,
                                           vImage_Flags(kvImageNoFlags))
        }
    }
    
    private static func verticalShearBuffer(source: vImage_Buffer,
                                    destination: inout vImage_Buffer,
                                    byAngleInDegrees angleInDegrees: Double,
                                    verticalScale: Float = 1,
                                    backgroundColor: [Pixel_8] = [0, 55, 127, 127]) {
        
        // 1. Ensure the shear angle is valid.
        precondition(angleInDegrees > -90 && angleInDegrees < 90,
                     "The shear angle needs to be greater than -90º and less than 90º.")
        
        // 2. Calculate `shearSlope` as the tangent of the specified angle.
        let angle = Measurement(value: angleInDegrees,
                                unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let shearSlope = tan(radians)


        // 3. Create a default resampling filter using the specified scale.
        let resamplingFilter = vImageNewResamplingFilter(verticalScale,
                                                         vImage_Flags(kvImageNoFlags))
        defer {
            vImageDestroyResamplingFilter(resamplingFilter)
        }
        
        // 4. Apply the transform to `source` and write the result to `destination`.
        _ = withUnsafePointer(to: source) { srcPointer in
            vImageVerticalShear_ARGB8888(srcPointer,
                                         &destination,
                                         0, 0,
                                         0,
                                         shearSlope,
                                         resamplingFilter,
                                         backgroundColor,
                                         vImage_Flags(kvImageBackgroundColorFill))
        }
    }
    
    private static func rotateNinety(source: vImage_Buffer, destination: inout vImage_Buffer, rotation: Int) {
        _ = withUnsafePointer(to: source) { sourcePtr in
            vImageRotate90_ARGB8888(sourcePtr,
                                    &destination,
                                    UInt8(rotation),
                                    [0],
                                    vImage_Flags(kvImageNoFlags))
        }
    }
    
    private static func alphaComposite(topImage: CGImage, bottomImage: CGImage) -> CGImage? {
        // Create source and destination vImage buffers.
        guard
            let topImageBuffer = try? vImage_Buffer(cgImage: topImage),
            let bottomImageBuffer = try? vImage_Buffer(cgImage: bottomImage),
            var destinationImageBuffer = try? vImage_Buffer(size: topImageBuffer.size,
                                                            bitsPerPixel: 8 * 4)
        else {
            return nil
        }
        
        defer {
            topImageBuffer.free()
            bottomImageBuffer.free()
            destinationImageBuffer.free()
        }


        withUnsafePointer(to: topImageBuffer) { topPtr in
            withUnsafePointer(to: bottomImageBuffer) { bottomPtr in
                
                // Ensure the bottom image and top image are ARGB.
                convertToARGB(bottomPtr, alphaInfo: bottomImage.alphaInfo)
                convertToARGB(topPtr, alphaInfo: topImage.alphaInfo)
                
                // Ensure the top layer is premultiplied.
                premultiply(topPtr, alphaInfo: topImage.alphaInfo)


                // Perform the composite operation.
                vImagePremultipliedAlphaBlend_ARGB8888(topPtr,
                                                       bottomPtr,
                                                       &destinationImageBuffer,
                                                       vImage_Flags(kvImageNoFlags))
            }
        }
        
        if let destinationFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)) {
            return try? destinationImageBuffer.createCGImage(format: destinationFormat)
        }
        return nil
    }
    
    private static func convertToARGB(_ buffer: UnsafePointer<vImage_Buffer>,
                       alphaInfo: CGImageAlphaInfo) {
        
        let alphaLasts = [ CGImageAlphaInfo.last,
                           CGImageAlphaInfo.premultipliedLast,
                           CGImageAlphaInfo.noneSkipLast ]
        
        if alphaLasts.contains(alphaInfo) {
            vImagePermuteChannels_ARGB8888(buffer,
                                           buffer,
                                           [3, 0, 1, 2],
                                           vImage_Flags(kvImageNoFlags))
        }
    }
    
    private static func premultiply(_ buffer: UnsafePointer<vImage_Buffer>,
                     alphaInfo: CGImageAlphaInfo) {
        
        let premultiplieds = [ CGImageAlphaInfo.premultipliedFirst,
                               CGImageAlphaInfo.premultipliedLast ]
        
        if !premultiplieds.contains(alphaInfo) {
            vImagePremultiplyData_ARGB8888(buffer,
                                           buffer,
                                           vImage_Flags(kvImageNoFlags))
        }
    }
    
}


extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
     }
    
    func getPixelValues() -> (pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = self.cgImage {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow

            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)

            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

            pixelValues = intensities
        }

        return (pixelValues, width, height)
    }
    
    static func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
    {
        var imageRef: CGImage?
        if var pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 1
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow

            imageRef = withUnsafePointer(to: &pixelValues, {
                ptr -> CGImage? in
                var imageRef: CGImage?
                let colorSpaceRef = CGColorSpaceCreateDeviceGray()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
                let releaseData: CGDataProviderReleaseDataCallback = {
                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
                }

                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                    imageRef = CGImage(width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo,
                                       provider: providerRef,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: CGColorRenderingIntent.defaultIntent)
                }

                return imageRef
            })
        }

        return imageRef
    }
 }
