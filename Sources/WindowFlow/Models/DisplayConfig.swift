import Foundation
import CoreGraphics

struct DisplayInfo: Identifiable, Codable, Hashable {
    let id: UInt32
    let frame: CGRect
    let isMain: Bool
    let displayIndex: Int

    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }

    enum CodingKeys: String, CodingKey {
        case id, isMain, displayIndex
        case frameX, frameY, frameWidth, frameHeight
    }

    init(id: UInt32, frame: CGRect, isMain: Bool, displayIndex: Int) {
        self.id = id
        self.frame = frame
        self.isMain = isMain
        self.displayIndex = displayIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UInt32.self, forKey: .id)
        isMain = try container.decode(Bool.self, forKey: .isMain)
        displayIndex = try container.decode(Int.self, forKey: .displayIndex)
        let x = try container.decode(CGFloat.self, forKey: .frameX)
        let y = try container.decode(CGFloat.self, forKey: .frameY)
        let w = try container.decode(CGFloat.self, forKey: .frameWidth)
        let h = try container.decode(CGFloat.self, forKey: .frameHeight)
        frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isMain, forKey: .isMain)
        try container.encode(displayIndex, forKey: .displayIndex)
        try container.encode(frame.origin.x, forKey: .frameX)
        try container.encode(frame.origin.y, forKey: .frameY)
        try container.encode(frame.width, forKey: .frameWidth)
        try container.encode(frame.height, forKey: .frameHeight)
    }
}

struct DisplayConfiguration: Equatable {
    let displays: [DisplayInfo]
    var count: Int { displays.count }

    var mainDisplay: DisplayInfo? {
        displays.first(where: { $0.isMain })
    }

    func display(at index: Int) -> DisplayInfo? {
        displays.first(where: { $0.displayIndex == index })
    }
}
