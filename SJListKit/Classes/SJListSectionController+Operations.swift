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

import Foundation
import IGListKit

/// Describes the movement of collection view cell
/// from one index to another
public struct SJCollectionViewCellMovement {
    /// Start index
    let from: Int
    
    /// End index
    let to: Int
}

/// Protocol with operations' interfaces for section controller
public protocol SJListSectionControllerOperationsProtocol: class {
    
    /// Reloads all data
    ///
    /// - Parameters:
    ///   - animated: animated
    ///   - completion: completion block
    func reload(animated: Bool,
                completion: ((Bool) -> Void)?)
    
    /// Performs updated such as insertions, deletions, etc.
    ///
    /// - Parameters:
    ///   - inserted: indexies of insertions
    ///   - deleted: indexies of deletions
    ///   - updated: indexies of updates
    ///   - moved: movements
    ///   - animated: animated
    ///   - completion: completion block
    func update(inserted: IndexSet?,
                deleted: IndexSet?,
                updated: IndexSet?,
                moved: [SJCollectionViewCellMovement]?,
                animated: Bool,
                completion: ((Bool) -> Void)?)
    
    /// Scroll to index
    /// - Parameters:
    ///   - index: index
    ///   - position: Position
    ///   - animated: is need animation
    func scroll(to index: Int,
                position: UICollectionViewScrollPosition,
                animated: Bool)
    
}

// MARK: - Default Implementations and Extra Methods
public extension SJListSectionControllerOperationsProtocol {
    
    /// Reloads all data
    ///
    /// - Parameter animated: animated
    public func reload(animated: Bool = true) {
        reload(animated: animated,
               completion: nil)
    }
    
    /// Reloads data at specific indexies
    ///
    /// - Parameters:
    ///   - indexes: indexies of updates
    ///   - animated: animated
    ///   - completion: completion block
    public func reload(at indexes: IndexSet,
                       animated: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        update(inserted: nil,
               deleted: nil,
               updated: indexes,
               moved: nil,
               animated: animated,
               completion: completion)
    }
    
    /// Performs updated such as insertions, deletions, etc.
    ///
    /// - Parameters:
    ///   - inserted: indexies of insertions
    ///   - deleted: indexies of deletions
    ///   - updated: indexies of updates
    ///   - moved: movements
    ///   - animated: animated
    ///   - completion: completion block
    public func update(inserted: IndexSet? = nil,
                       deleted: IndexSet? = nil,
                       updated: IndexSet? = nil,
                       moved: [SJCollectionViewCellMovement]? = nil,
                       animated: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        update(inserted: inserted,
               deleted: deleted,
               updated: updated,
               moved: moved,
               animated: animated,
               completion: completion)
    }
    
    /// Deletes at specific indexies
    ///
    /// - Parameters:
    ///   - indexes: indexies of deletions
    ///   - animated: animated
    ///   - completion: completion block
    public func delete(at indexes: IndexSet,
                       animated: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        update(inserted: nil,
               deleted: indexes,
               updated: nil,
               moved: nil,
               animated: animated,
               completion: completion)
    }
    
    /// Inserts at specific indexies
    ///
    /// - Parameters:
    ///   - indexes: indexies of deletions
    ///   - animated: animated
    ///   - completion: completion block
    public func insert(at indexes: IndexSet,
                       animated: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        update(inserted: indexes,
               deleted: nil,
               updated: nil,
               moved: nil,
               animated: animated,
               completion: completion)
    }
    
}

// MARK: - SJListSectionController + SJListSectionControllerOperationsProtocol
extension SJListSectionController: SJListSectionControllerOperationsProtocol {
    
    public func scroll(to index: Int, position: UICollectionViewScrollPosition, animated: Bool) {
        sjcollectionContext.scroll(to: self, at: index, scrollPosition: position, animated: animated)
    }
    
    
    public func reload(animated: Bool,
                       completion: ((Bool) -> Void)?) {
        sjcollectionContext.performBatch(
            animated: animated,
            updates: { [weak self] context in
                guard let `self` = self else {
                    return
                }
                context.reload(self)
            },
            completion: completion)
    }
    
    public func update(inserted: IndexSet?,
                       deleted: IndexSet?,
                       updated: IndexSet?,
                       moved: [SJCollectionViewCellMovement]?,
                       animated: Bool,
                       completion: ((Bool) -> Void)?) {
        sjcollectionContext.performBatch(
            animated: animated,
            updates: { (batch) in
                if let deleted = deleted {
                    batch.delete(in: self, at: deleted)
                }
                if let insered = inserted {
                    batch.insert(in: self, at: insered)
                }
                if let updated = updated {
                    batch.reload(in: self, at: updated)
                }
                for move in moved ?? [] {
                    batch.move(in: self, from: move.from, to: move.to)
                }
        },
            completion: completion)
    }
    
}
