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

/// Protocol for updating cell layout without reloading it
public protocol SJUpdateCellsLayoutProtocol: class {
    
    /// Perform an (animated) recalculation of size without reloading
    ///
    /// - Parameter animated: animated
    func updateCellsLayout(animated: Bool)
    
    
    /// Perform an (animated) recalculation of size without reloading for several cells
    ///
    /// - Parameters:
    ///   - indexies: indexies of cells
    ///   - animated: animated
    func updateCellsLayout(at indexies: IndexSet?, animated: Bool)
    
}

// MARK: - Implementation of SJUpdateCellsLayoutProtocol for SJListSectionController
public extension SJUpdateCellsLayoutProtocol where Self: SJListSectionController {
    
	func updateCellsLayout(animated: Bool) {
		let indexes =
			collectionContext?.visibleIndexPaths(for: self).reduce(IndexSet(), { (result, indexPath) -> IndexSet in
			var set = result
			set.insert(indexPath.row)
			return set
		})

		updateCellsLayout(at: indexes, animated: animated)
	}


    func updateCellsLayout(at indexies: IndexSet? = nil, animated: Bool) {
        for cell in self.collectionContext?.visibleCells(for: self) ?? [] {
            guard let index = self.collectionContext?.index(for: cell, sectionController: self),
                indexies?.contains(index) == true else {
                continue
            }
            self.configureCell(cell, at: index)
        }

        if animated {
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.collectionContext?.invalidateLayout(for: self, completion: nil)
            }
        } else {
            collectionContext?.invalidateLayout(for: self, completion: nil)
        }
    }
    
}
