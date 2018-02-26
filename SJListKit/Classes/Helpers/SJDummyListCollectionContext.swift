//  MIT License
//
//  Copyright (c) 2018 SuperJob, LLC
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

/// Dummy class that implements ListCollectionContext
@objc class SJDummyListCollectionContex: NSObject, ListCollectionContext {
    
    var containerSize: CGSize {
        return .zero
    }
    
    var containerInset: UIEdgeInsets {
        return .zero
    }
    
    var adjustedContainerInset: UIEdgeInsets {
        return .zero
    }
    
    var insetContainerSize: CGSize {
        return .zero
    }
    
    func containerSize(for sectionController: ListSectionController) -> CGSize {
        return .zero
    }
    
    func index(for cell: UICollectionViewCell, sectionController: ListSectionController) -> Int {
        return 0
    }
    
    func cellForItem(at index: Int, sectionController: ListSectionController) -> UICollectionViewCell? {
        return nil
    }
    
    func visibleCells(for sectionController: ListSectionController) -> [UICollectionViewCell] {
        return []
    }
    
    func visibleIndexPaths(for sectionController: ListSectionController) -> [IndexPath] {
        return []
    }
    
    func deselectItem(at index: Int, sectionController: ListSectionController, animated: Bool) {
        return
    }
    
    func selectItem(at index: Int, sectionController: ListSectionController, animated: Bool, scrollPosition: UICollectionViewScrollPosition) {
        return
    }
    
    func dequeueReusableCell(of cellClass: AnyClass, for sectionController: ListSectionController, at index: Int) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func dequeueReusableCell(withNibName nibName: String, bundle: Bundle?, for sectionController: ListSectionController, at index: Int) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func dequeueReusableCellFromStoryboard(withIdentifier identifier: String, for sectionController: ListSectionController, at index: Int) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func dequeueReusableSupplementaryView(ofKind elementKind: String, for sectionController: ListSectionController, class viewClass: AnyClass, at index: Int) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func dequeueReusableSupplementaryView(fromStoryboardOfKind elementKind: String, withIdentifier identifier: String, for sectionController: ListSectionController, at index: Int) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func dequeueReusableSupplementaryView(ofKind elementKind: String, for sectionController: ListSectionController, nibName: String, bundle: Bundle?, at index: Int) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func invalidateLayout(for sectionController: ListSectionController, completion: ((Bool) -> Void)? = nil) {
        return
    }
    
    func performBatch(animated: Bool, updates: @escaping (ListBatchContext) -> Void, completion: ((Bool) -> Void)? = nil) {
        return
    }
    
    func scroll(to sectionController: ListSectionController, at index: Int, scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        return
    }
    
}
