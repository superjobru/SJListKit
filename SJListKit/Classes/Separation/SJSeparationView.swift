//  MIT License
//
//  Copyright (c) 2017 SuperJob, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import SnapKit

/// Style of collection view cell separator
///
/// - none: without separator
/// - filled: from edge to edge
/// - margins: with marginds from left and right
public enum SJCollectionViewCellSeparatorStyle: Equatable {
    case none
    case filled
    case margins(left: CGFloat, right: CGFloat)

    public static func == (lhs: SJCollectionViewCellSeparatorStyle, rhs: SJCollectionViewCellSeparatorStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.filled, .filled):
            return true
        case let (.margins(l), .margins(r)):
            return l == r
        default:
            return false
        }
    }
}

/// Ability to draw a separation view
public protocol SJSeparationView: class where Self: UIView {
    
    /// Set style of separation view
    ///
    /// - Parameter separationStyle: style
    func set(separationStyle: SJCollectionViewCellSeparatorStyle)
    
    /// Set color of separation view
    ///
    /// - Parameter separatorColor: color
    func set(separatorColor: UIColor)
    
}

private var separatorAssociationKey: UInt8 = 0
private var styleAssociatedKey: UInt8 = 0
private var colorAssociatedKey: UInt8 = 0

// MARK: - Default Implementation
extension SJSeparationView {
    typealias Separator = UIView

    // Separator
    private var bottomSeparator: Separator {
        if let separator = objc_getAssociatedObject(self, &separatorAssociationKey) as? Separator {
            return separator
        } else {
            let separator = Separator()
            objc_setAssociatedObject(self, &separatorAssociationKey, separator, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            return separator
        }
    }

    /// Current style
    private var style: SJCollectionViewCellSeparatorStyle {
        get {
            if let associated = objc_getAssociatedObject(self, &styleAssociatedKey) as? SJCollectionViewCellSeparatorStyle {
                return associated
            }
            return .none
        }
        set {
            objc_setAssociatedObject(self, &styleAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Current color
    private var color: UIColor {
        get {
            if let associated = objc_getAssociatedObject(self, &colorAssociatedKey) as? UIColor {
                return associated
            }
            return UIColor.clear
        }
        set {
            objc_setAssociatedObject(self, &colorAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Add separator with margins
    ///
    /// - Parameters:
    ///   - leftMargin: left
    ///   - rightMargin: right
    private func addSeparator(leftMargin: CGFloat, rightMargin: CGFloat) {
        addSubview(bottomSeparator)
        bottomSeparator.snp.remakeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(leftMargin)
            maker.right.equalToSuperview().offset(-rightMargin)
            maker.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
    /// Set separator style
    ///
    /// - Parameter separationStyle: style
    public func set(separationStyle: SJCollectionViewCellSeparatorStyle) {
        guard style != separationStyle else {
            return
        }
        
        style = separationStyle
        
        switch style {
        case .none:
            bottomSeparator.removeFromSuperview()
        case .filled:
            addSeparator(leftMargin: 0, rightMargin: 0)
        case .margins(let left, let right):
            addSeparator(leftMargin: left, rightMargin: right)
        }
    }
    
    /// Set separator color
    ///
    /// - Parameter separationColor: color
    public func set(separatorColor: UIColor) {
        guard color != separatorColor else {
            return
        }
        
        color = separatorColor
        
        bottomSeparator.backgroundColor = separatorColor
    }
    
}

// MARK: - SJSeparationView + UICollectionReusableView
extension UICollectionReusableView: SJSeparationView {}
