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

/// Universal supplementary config provides an ability
/// to change a header and footer behavior dynamically
public struct SJUniversalSupplementaryConfig {
    
    /// Header supplementary view
    public var header: SJSupplementaryItemConfigProtocol?
    
    /// Footer supplementary view
    public var footer: SJSupplementaryItemConfigProtocol?
    
    public init(header: SJSupplementaryItemConfigProtocol? = nil,
         footer: SJSupplementaryItemConfigProtocol? = nil) {
        self.header = header
        self.footer = footer
    }
    
}

/// Protocol for supplementary item (header, footer, etc.)
/// Used to hide a generic
public protocol SJSupplementaryItemConfigProtocol {
    
    typealias ConfigBlock = ((UICollectionReusableView) -> Void)
    typealias SizeBlock = ((CGSize) -> SJSupplementarySize)
    
    /// Supplementary type
    var type: UICollectionReusableView.Type { get }
    
    /// Config block
    /// Use it for setting proper ui parameters (fonts, colors, etc.) and data
    var configBlock: ConfigBlock { get }
    
    /// Size block
    var sizeBlock: SizeBlock { get }
    
}

/// Supplementary of a proper type
public struct SJSupplementaryItemConfigGeneric<T: UICollectionReusableView>: SJSupplementaryItemConfigProtocol {
    
    public typealias ConfigBlock = ((T) -> Void)
    public typealias SizeBlock = ((CGSize) -> SJSupplementarySize)
    
    /// Config block
    public let config: ConfigBlock
    
    /// Size block
    public let size: SizeBlock
    
    public init(config: @escaping ConfigBlock,
                size: @escaping SizeBlock = { _ in return .autolayout} ) {
        self.config = config
        self.size = size
    }
    
    // MARK: - SJUniversalSupplementaryConfigProtocol
    
    public var type: UICollectionReusableView.Type {
        return T.self
    }
    
    public var configBlock: SJSupplementaryItemConfigProtocol.ConfigBlock {
        return { view in
            guard let typedView = view as? T else {
                return
            }
            
            self.config(typedView)
        }
    }
    
    public var sizeBlock: SJSupplementaryItemConfigProtocol.SizeBlock {
        return size
    }
    
}
