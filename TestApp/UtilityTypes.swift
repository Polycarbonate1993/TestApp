//
//  UtilityTypes.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import Foundation
import UIKit

/// Thread safe representation of an Array.
class ThreadSafeArray<Element>: Collection {
    typealias Index = Int
    typealias Indices = Range<Int>
    typealias Iterator = IndexingIterator<Array<Element>>
    private var storage: [Element]
    private var arrayQueue = DispatchQueue(label: "ThreadSafeArrayQueue", attributes: .concurrent)
    var startIndex: Int {
        arrayQueue.sync {
            return self.storage.startIndex
            
        }
    }
    var endIndex: Int {
        arrayQueue.sync {
            return self.storage.endIndex
        }
    }
    var indices: Indices {
        arrayQueue.sync {
            return self.storage.indices
        }
    }
    var count: Int {
        arrayQueue.sync {
            return storage.count
        }
    }
    var isEmpty: Bool {
        arrayQueue.sync {
            return storage.isEmpty
        }
    }
    init(_ items: [Element]) {
        storage = items
    }
    init() {
        storage = []
    }
    subscript(position: Index) -> Element {
        arrayQueue.sync {
            return storage[position]
        }
    }
    func index(after: Index) -> Index {
        arrayQueue.sync {
            return self.storage.index(after: after)
        }
    }
    func makeIterator() -> IndexingIterator<Array<Element>> {
        arrayQueue.sync {
            return self.storage.makeIterator()
        }
    }
    func append(_ newElement: Element) {
        arrayQueue.async(flags: .barrier) {
            self.storage.append(newElement)
        }
    }
    func append<S>(contentsOf: S) where Element == S.Element, S : Sequence {
        arrayQueue.async(flags: .barrier) {
            self.storage.append(contentsOf: contentsOf)
        }
    }
}

@IBDesignable
/// UIView deccessor that represents UIView with custom layer mask in shape of polyhedron with customizable corner radius and diagonal edges length.
class DiamondView: UIView {
    /**Corner radius modificator. The higher value the sharper corners. Can't be set below 2. The default value is 10.*/
    @IBInspectable
    var cRadiusMod: CGFloat = 10 {
        didSet {
            setUpLayer()
        }
    }
    /**Diagonal edge's length modificator. The higher value the shorter edge. Can't be set below 1. The default value is 1.*/
    @IBInspectable
    var dLengthMod: CGFloat = 1 {
        didSet {
            setUpLayer()
        }
    }
    
    /**Optional image that stretches to the view's size.*/
    var imageView: UIImageView? {
        didSet {
            setUpImageView(imageView)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            setUpLayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tag = Int.random(in: 0...100)
        clipsToBounds = true
        setUpLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tag = Int.random(in: 0...100)
        clipsToBounds = true
        setUpLayer()
    }
    
    /// Creates DiamondView with given image.
    /// - Parameter image: <#image description#>
    init(image: UIImage) {
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        let imageView = UIImageView(image: image)
        setUpImageView(imageView)
    }
    
    /// Assigns image to the view.
    /// - Parameter imageView: ImageView needed to be assigned.
    private func setUpImageView(_ imageView: UIImageView?) {
        viewWithTag(tag)?.removeFromSuperview()
        guard let imageView = imageView else {
            return
        }
        imageView.contentMode = .scaleAspectFill
        imageView.tag = tag
        imageView.backgroundColor = .clear
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(imageView.makeConstraintsTo(self, constraints: [
            .top: (.top, ConstraintSettings()),
            .bottom: (.bottom, ConstraintSettings()),
            .leading: (.leading, ConstraintSettings()),
            .trailing: (.trailing, ConstraintSettings())
        ]))
    }
    /// Creates and sets up CAShapeLayer as a mask layer to the view's layer property.
    private func setUpLayer() {
        let maskLayer = CAShapeLayer()
        layer.mask = maskLayer
        maskLayer.frame = bounds
        let angle = 45 * CGFloat.pi / 180
        let minDimension = min(bounds.width, bounds.height)
        let diagonalLength = (minDimension / 2) / cos(angle) / (dLengthMod < 1 ? 1 : dLengthMod)
        let radius = diagonalLength / (cRadiusMod < 2 ? 2 : cRadiusMod)
        let truncation = radius
        let xLength = bounds.width - ((diagonalLength * cos(angle)) * 2)
        let yLength = bounds.height - ((diagonalLength * cos(angle)) * 2)
        let startingPoint = CGPoint(x: diagonalLength * cos(angle), y: radius * (1 / cos(angle) - 1))
        let path = UIBezierPath()
        path.flatness = 0.1
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x + xLength, y: startingPoint.y))
        path.addArc(withCenter: CGPoint(x: startingPoint.x + xLength, y: radius / cos(angle)), radius: radius, startAngle: -(CGFloat.pi / 2), endAngle: -(CGFloat.pi / 4), clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - truncation * cos(angle), y: (diagonalLength - truncation) * cos(angle)))
        path.addArc(withCenter: CGPoint(x: bounds.width - radius / cos(angle), y: diagonalLength * cos(angle)), radius: radius, startAngle: -(CGFloat.pi / 4), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - radius * (1 / cos(angle) - 1), y: diagonalLength * cos(angle) + yLength))
        path.addArc(withCenter: CGPoint(x: bounds.width - radius / cos(angle), y: diagonalLength * cos(angle) + yLength), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 4, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - (diagonalLength - truncation) * cos(angle), y: bounds.height - truncation * cos(angle)))
        path.addArc(withCenter: CGPoint(x: bounds.width - diagonalLength * cos(angle), y: bounds.height - radius / cos(angle)), radius: radius, startAngle: CGFloat.pi / 4, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: diagonalLength * cos(angle), y: bounds.height - radius * (1 / cos(angle) - 1)))
        path.addArc(withCenter: CGPoint(x: diagonalLength * cos(angle), y: bounds.height - radius / cos(angle)), radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 0.75, clockwise: true)
        path.addLine(to: CGPoint(x: truncation * cos(angle), y: bounds.height - (diagonalLength - truncation) * cos(angle)))
        path.addArc(withCenter: CGPoint(x: radius / cos(angle), y: bounds.height - diagonalLength * cos(angle)), radius: radius, startAngle: CGFloat.pi * 0.75, endAngle: CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: radius * (1 / cos(angle) - 1), y: diagonalLength * cos(angle)))
        path.addArc(withCenter: CGPoint(x: radius / cos(angle), y: diagonalLength * cos(angle)), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.25, clockwise: true)
        path.addLine(to: CGPoint(x: (diagonalLength - truncation) * cos(angle), y: truncation * cos(angle)))
        path.addArc(withCenter: CGPoint(x: diagonalLength * cos(angle), y: radius / cos(angle)), radius: radius, startAngle: CGFloat.pi * 1.25, endAngle: CGFloat.pi * 1.5, clockwise: true)
        path.close()
        UIColor.black.set()
        path.fill()
        maskLayer.path = path.cgPath
    }
}
