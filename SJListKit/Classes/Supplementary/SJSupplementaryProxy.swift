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
import IGListKit

/// Supplementary type
/// (Wrapper for inconvenient UIKit's kind-strings)
///
/// - footer: Footer kind
/// - header: Header kind
/// - UICollectionElementKindSectionFooter:: UIKit kind string for footer
/// - UICollectionElementKindSectionHeader:: UIKit kind string for header
public enum SJSupplementaryKind {
    case footer
    case header
    
    init?(with string: String) {
        switch string {
        case UICollectionElementKindSectionFooter:
            self = .footer
        case UICollectionElementKindSectionHeader:
            self = .header
        default:
            return nil
        }
    }
}

/// Size of supplementary
///
/// - autolayout: size will be calculated automatically
/// - manual: manual size
public enum SJSupplementarySize {
    case autolayout
    case manual(CGSize)
}

/// Work with supplementary
public protocol SJSupplementaryProtocol: class {
    
    /// Type of supplementary fir kind
    ///
    /// - Parameter kind: kind
    /// - Returns: type
    func type(for kind: SJSupplementaryKind) -> UICollectionReusableView.Type?
    
    /// Configure supplementary
    ///
    /// - Parameters:
    ///   - reusableView: view
    ///   - kind: of kind
    func configure(reusableView: UICollectionReusableView, of kind: SJSupplementaryKind)
    
    /// How to calculate the size of supplementary
    ///
    /// - Parameters:
    ///   - kind: kind
    ///   - index: index
    /// - Returns: size
    func size(for kind: SJSupplementaryKind, at index: Int) -> SJSupplementarySize
    
}

// MARK: - SupplementaryProtocol Default Implementation
public extension SJSupplementaryProtocol {
    
    /// How to calculate the size of supplementary
    /// (use autolayout by default)
    ///
    /// - Parameters:
    ///   - kind: kind
    ///   - index: index
    /// - Returns: size
    func size(for kind: SJSupplementaryKind, at index: Int) -> SJSupplementarySize {
        return .autolayout
    }
    
}

/// Proxy for work with supplementary in list section controller
public class SJSupplementaryProxy: NSObject {
    
    /// Shortcut for collection context
    fileprivate var context: ListCollectionContext? {
        return delegate?.collectionContext
    }
    
    /// Cache for supplementary views
    fileprivate static let cache: NSCache<NSString, UICollectionReusableView> = NSCache<NSString, UICollectionReusableView>()
    
    public typealias SectionWithSupplementary = (SJSupplementaryProtocol & ListSectionController)
    
    /// List section + supplementary protocol
    public weak var delegate: SectionWithSupplementary?
    
}

// MARK: - ListSupplementaryViewSource
extension SJSupplementaryProxy: ListSupplementaryViewSource {
    
    public func supportedElementKinds() -> [String] {
        
        ///If context is nil method dequeueReusableSupplementaryView always crash 
        guard context != nil else {
            return []
        }
        
        var kinds: [String] = []
        
        if delegate?.type(for: .footer) != nil {
            kinds.append(UICollectionElementKindSectionFooter)
        }
        
        if delegate?.type(for: .header) != nil {
            kinds.append(UICollectionElementKindSectionHeader)
        }
        
        return kinds
    }
    
    public func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        
        guard let section = delegate,
            let kind = SJSupplementaryKind.init(with: elementKind),
            let `context` = context else {
                fatalError("Can't work with supplementary. Check that context, section, kind and UICollectionReusableView class defined correctly")
        }
        
        let reusableView: UICollectionReusableView
        if let klass: UICollectionReusableView.Type = delegate?.type(for: kind) {
            reusableView = context.dequeueReusableSupplementaryView(ofKind: elementKind,
                                                                    for: section,
                                                                    class: klass,
                                                                    at: index)
            section.configure(reusableView: reusableView, of: kind)
        } else {
            reusableView = context.dequeueReusableSupplementaryView(ofKind: elementKind,
                                                                    for: section,
                                                                    class: UICollectionReusableView.self,
                                                                    at: index)
        }
        
        return reusableView
    }
    
    public func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard let section = delegate,
            let kind = SJSupplementaryKind.init(with: elementKind) else {
                return .zero
        }
        let sizeType = section.size(for: kind, at: index)
        switch sizeType {
        case .manual(let size):
            return size
        case .autolayout:
            return calculateSize(for: kind, at: index)
        }
    }
    
    /// Get supplementary view for size calculatuions
    ///
    /// - Parameters:
    ///   - kind: kind of view
    ///   - index: index
    /// - Returns: view
    private func getCalculationReusableView(of kind: SJSupplementaryKind, at index: Int) -> UICollectionReusableView {
        guard let section = delegate, let type = section.type(for: kind) else {
            return UICollectionReusableView()
        }
        
        let key = "\(type)" as NSString
        
        if let cached = SJSupplementaryProxy.cache.object(forKey: key) {
            return cached
        }
        
        let reusableView = type.init(frame: .zero)
        SJSupplementaryProxy.cache.setObject(reusableView, forKey: key)
        
        return reusableView
    }
    
    /// Calculate the size using autolayout
    ///
    /// - Parameters:
    ///   - kind: kind
    ///   - index: idnex
    /// - Returns: size
    private func calculateSize(for kind: SJSupplementaryKind, at index: Int) -> CGSize {
        guard let `context` = context, let section = delegate else {
            return .zero
        }
        
        let reusableView = getCalculationReusableView(of: kind, at: index)
        section.configure(reusableView: reusableView, of: kind)
        
        var size = reusableView.systemLayoutSizeFitting(CGSize(width: context.containerSize.width,
                                                               height: UILayoutFittingCompressedSize.height),
                                                        withHorizontalFittingPriority: UILayoutPriority.required,
                                                        verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        size.height.round(.up)
        
        return size
    }
    
}
