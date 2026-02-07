import Foundation
import CoreGraphics
import ImageIO
import CoreFoundation

@main
struct GenerateAppIcon {
    static func main() throws {
        let outDir = URL(fileURLWithPath: "/Users/leonid.mesentsev/Development/test/Menu/Menu/Assets.xcassets/AppIcon.appiconset")
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

        let size = 1024
        let width = size
        let height = size

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw NSError(domain: "GenerateAppIcon", code: 1)
        }

        // Flip coordinate system to a more intuitive top-left origin
        ctx.translateBy(x: 0, y: CGFloat(height))
        ctx.scaleBy(x: 1, y: -1)

        // Background gradient
        let top = CGColor(red: 0x1f/255.0, green: 0x3b/255.0, blue: 0x5b/255.0, alpha: 1)
        let bot = CGColor(red: 0xf6/255.0, green: 0xc1/255.0, blue: 0x77/255.0, alpha: 1)
        let colors = [top, bot] as CFArray
        let locations: [CGFloat] = [0, 1]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
            throw NSError(domain: "GenerateAppIcon", code: 2)
        }

        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 0, y: CGFloat(height)),
            options: []
        )

        // A soft vignette
        ctx.setStrokeColor(CGColor(gray: 0, alpha: 0.25))
        for i in stride(from: 2, through: 160, by: 6) {
            let inset = CGFloat(i)
            let rect = CGRect(x: inset, y: inset, width: CGFloat(width) - 2*inset, height: CGFloat(height) - 2*inset)
            let path = CGPath(roundedRect: rect, cornerWidth: 220, cornerHeight: 220, transform: nil)
            ctx.setLineWidth(2)
            ctx.addPath(path)
            ctx.strokePath()
        }

        // Centered cloche + plate + menu card
        let cx = CGFloat(width) / 2.0
        let cy = CGFloat(height) / 2.0 + 30

        func fillPath(_ path: CGPath, _ color: CGColor) {
            ctx.setFillColor(color)
            ctx.addPath(path)
            ctx.fillPath()
        }

        let whiteA = CGColor(red: 1, green: 1, blue: 1, alpha: 0.92)
        let whiteB = CGColor(red: 1, green: 1, blue: 1, alpha: 0.80)
        let ink = CGColor(red: 0x1f/255.0, green: 0x3b/255.0, blue: 0x5b/255.0, alpha: 0.72)
        let inkStrong = CGColor(red: 0x1f/255.0, green: 0x3b/255.0, blue: 0x5b/255.0, alpha: 0.82)
        let accent = CGColor(red: 0x3a/255.0, green: 0xb5/255.0, blue: 0x4a/255.0, alpha: 0.86)

        // Shadow
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.25))
        ctx.fillEllipse(in: CGRect(x: cx-280, y: cy+180, width: 560, height: 120))

        // Plate
        ctx.setFillColor(whiteA)
        ctx.fillEllipse(in: CGRect(x: cx-260, y: cy+60, width: 520, height: 240))
        ctx.setFillColor(whiteB)
        ctx.fillEllipse(in: CGRect(x: cx-220, y: cy+95, width: 440, height: 175))

        // Cloche dome (semi-ellipse)
        let baseY = cy + 80
        let domeRect = CGRect(x: cx-220, y: cy-170, width: 440, height: (baseY+220) - (cy-170))
        let domePath = CGMutablePath()
        domePath.addArc(
            center: CGPoint(x: cx, y: baseY+25),
            radius: 220,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )
        domePath.addLine(to: CGPoint(x: cx+220, y: baseY+25))
        domePath.addLine(to: CGPoint(x: cx-220, y: baseY+25))
        domePath.closeSubpath()
        // Use a simpler dome fill via clipping to a pieslice-like arc
        ctx.saveGState()
        let clip = CGPath(ellipseIn: domeRect, transform: nil)
        ctx.addPath(clip)
        ctx.clip()
        ctx.setFillColor(whiteA)
        ctx.fill(domeRect)
        ctx.restoreGState()

        // Rim
        ctx.setFillColor(whiteA)
        ctx.fillEllipse(in: CGRect(x: cx-235, y: baseY+135, width: 470, height: 65))
        // carve hole
        ctx.setBlendMode(.clear)
        ctx.fillEllipse(in: CGRect(x: cx-210, y: baseY+150, width: 420, height: 40))
        ctx.setBlendMode(.normal)

        // Knob
        ctx.setFillColor(whiteA)
        ctx.fillEllipse(in: CGRect(x: cx-35, y: cy-195, width: 70, height: 70))
        ctx.setFillColor(whiteB)
        ctx.fillEllipse(in: CGRect(x: cx-20, y: cy-180, width: 40, height: 40))

        // Menu card (right)
        let cardRect = CGRect(x: cx+110, y: cy-40, width: 190, height: 250)
        let cardPath = CGPath(roundedRect: cardRect, cornerWidth: 28, cornerHeight: 28, transform: nil)
        fillPath(cardPath, whiteA)

        // Lines on the card
        for y in [cy+10, cy+45, cy+80, cy+115, cy+150] {
            let lineRect = CGRect(x: cx+140, y: y, width: 135, height: 10)
            let p = CGPath(roundedRect: lineRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
            fillPath(p, ink)
        }

        // Cutlery hint (left of the card)
        let fork = CGPath(roundedRect: CGRect(x: cx+135, y: cy-15, width: 10, height: 185), cornerWidth: 5, cornerHeight: 5, transform: nil)
        let knife = CGPath(roundedRect: CGRect(x: cx+155, y: cy-15, width: 10, height: 185), cornerWidth: 5, cornerHeight: 5, transform: nil)
        fillPath(fork, inkStrong)
        fillPath(knife, inkStrong)

        // Garnish dot
        ctx.setFillColor(accent)
        ctx.fillEllipse(in: CGRect(x: cx-40, y: cy+175, width: 50, height: 50))

        guard let cgImage = ctx.makeImage() else {
            throw NSError(domain: "GenerateAppIcon", code: 3)
        }

        let outURL = outDir.appendingPathComponent("Icon-1024.png")

        guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw NSError(domain: "GenerateAppIcon", code: 4)
        }
        CGImageDestinationAddImage(dest, cgImage, nil)
        if !CGImageDestinationFinalize(dest) {
            throw NSError(domain: "GenerateAppIcon", code: 5)
        }

        print("Wrote: \(outURL.path)")
    }
}
