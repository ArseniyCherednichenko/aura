import CoreGraphics
import ImageIO
import Foundation

// Renders the Aura app icon (gradient orb in a ring on a deep background) to a
// 1024x1024 PNG with no alpha. Pure CoreGraphics + ImageIO, no AppKit, so it runs
// headless. Usage: swift tools/MakeIcon.swift <out.png>

let size = 1024
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
let space = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: space,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else { fatalError("ctx") }

let s = CGFloat(size)
let center = CGPoint(x: s / 2, y: s / 2)
let radius = s * 0.30

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

// Deep background gradient.
let bg = CGGradient(colorsSpace: space,
                    colors: [color(0.06, 0.07, 0.13), color(0.02, 0.03, 0.06)] as CFArray,
                    locations: [0, 1])!
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

// Outer ring.
ctx.setStrokeColor(color(1, 1, 1, 0.16))
ctx.setLineWidth(s * 0.014)
ctx.strokeEllipse(in: CGRect(x: center.x - radius * 1.28, y: center.y - radius * 1.28,
                             width: radius * 2.56, height: radius * 2.56))

// Orb with a teal-to-violet gradient.
let orb = CGGradient(colorsSpace: space,
                     colors: [color(0.40, 0.86, 0.86), color(0.56, 0.51, 0.96)] as CFArray,
                     locations: [0, 1])!
ctx.saveGState()
ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
ctx.clip()
ctx.drawLinearGradient(orb,
                       start: CGPoint(x: center.x - radius, y: center.y + radius),
                       end: CGPoint(x: center.x + radius, y: center.y - radius),
                       options: [])
ctx.restoreGState()

guard let image = ctx.makeImage() else { fatalError("image") }
let url = URL(fileURLWithPath: outPath) as CFURL
guard let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil) else { fatalError("dest") }
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("finalize") }
print("wrote \(outPath)")
