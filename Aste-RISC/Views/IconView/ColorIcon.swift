//
//  ColorIcon.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import AppKit

func computeAverageColor(of nsImage: NSImage) async -> NSColor? {
    
    await withCheckedContinuation { continuation in
        guard
            let tiff   = nsImage.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let cg 	   = bitmap.cgImage
                
        else {
            continuation.resume(returning: nil)
            return
        }

        let ciImage = CIImage(cgImage: cg)
        guard let filter = CIFilter(name: "CIAreaAverage") else {
            continuation.resume(returning: nil)
            return
        }
		
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let output = filter.outputImage else {
            continuation.resume(returning: nil)
            return
        }

        // render 1x1 pixel
        var bitmapRGBA = [UInt8](repeating: 0, count: 4)
        context.render(
			output,
			toBitmap  : &bitmapRGBA,
			rowBytes  : 4,
			bounds	  : CGRect(x: 0, y: 0, width: 1, height: 1),
			format	  : .RGBA8,
			colorSpace: CGColorSpaceCreateDeviceRGB()
		)

        let r = CGFloat(bitmapRGBA[0]) / 255.0
        let g = CGFloat(bitmapRGBA[1]) / 255.0
        let b = CGFloat(bitmapRGBA[2]) / 255.0
        let a = CGFloat(bitmapRGBA[3]) / 255.0

        let nsColor = NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
        continuation.resume(returning: nsColor)
    }
}
