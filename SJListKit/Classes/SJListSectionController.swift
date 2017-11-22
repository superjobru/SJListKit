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

// Not the best parctice
// But it allows to avoid multiple import lines in your code:
//      import SJListKit
//      import IGListKit
// If you need any of original IGListKit API
@_exported import IGListKit
import RxSwift
import RxCocoa

/// Cell Initialization Type
///
/// - code: using init(with frame: CGRect)
/// - nibFromString: using name of *.xib
/// - nibFromClass: using class of your UICollectionViewCell subclass
public enum SJListSectionCellInitializationType {
    case code
    case nibFromString(String)
    case nibFromClass(SJNibNameConvertible.Type)
}

/// Base List Section Controller
open class SJListSectionController: ListSectionController {
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()

    public override init() {
        super.init()
        addObserversForLifecycle()
    }

    /// Cache for storing cells which used for size calculations
    private let cache = NSCache<NSString, UICollectionViewCell>()
    
    /// Calculates size based on type of cell and content
    @objc(sizeForItemAtIndex:) final override public func sizeForItem(at index: Int) -> CGSize {
        let calculatableCell = calculationCell(at: index)
        if let customSize = customSize(for: calculatableCell, at: index) {
            return customSize
        }
        configureCell(calculatableCell, at: index)

        var size = calculatableCell.contentView.systemLayoutSizeFitting(
            CGSize(width: sjcollectionContext.containerSize.width,
                   height: UILayoutFittingCompressedSize.height),
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: UILayoutPriority.fittingSizeLevel
        )
        size.height.round(.up)

        return size
    }

    /// Returns cell with data
    @objc(cellForItemAtIndex:) final override public func cellForItem(at index: Int) -> UICollectionViewCell {
        var cell = dequeueCell(at: index)
        configureCell(cell, at: index)
        cell.set(separationStyle: separationStyle(at: index))
        cell.set(separatorColor: separationColor(at: index))
        return cell
    }
    
    /// Dequeues cell
    ///
    /// - Parameter index: cell index
    /// - Returns: cell
    final public func dequeueCell(at index: Int) -> UICollectionViewCell {
        let cellType = self.cellType(at: index)
        let initializationType = cellInitializationType(at: index)
        switch initializationType {
        case .code:
            return sjcollectionContext.dequeueReusableCell(of: cellType, for: self, at: index)
        case .nibFromString(let nibName):
            return sjcollectionContext.dequeueReusableCell(withNibName: nibName,
                                                           bundle: nil,
                                                           for: self,
                                                           at: index)
        case .nibFromClass(let type):
            return sjcollectionContext.dequeueReusableCell(withNibName: type.classNibName,
                                                           bundle: nil,
                                                           for: self,
                                                           at: index)
        }
    }

    /// Returns cell for calculations from cache or creates it
    ///
    /// - Parameter index: index
    /// - Returns: calculation cell
    final private func calculationCell(at index: Int) -> UICollectionViewCell {
        let cellType = self.cellType(at: index)
        let key = "\(cellType)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let initializationType = cellInitializationType(at: index)

        let result: UICollectionViewCell
        switch initializationType {
        case .code:
            result = cellType.init(frame: .zero)
        case .nibFromString(let nibName):
            result = Bundle.main.loadNibNamed(nibName,
                                              owner: self,
                                              options: nil)?.first as! UICollectionViewCell
        case .nibFromClass(let type):
            result = Bundle.main.loadNibNamed(type.classNibName,
                                              owner: self,
                                              options: nil)?.first as! UICollectionViewCell
        }

        cache.setObject(result, forKey: key)

        return result
    }

    // MARK: - For Override

    /// Класс ячейки
    ///
    /// - Parameter index: Индекс данных
    /// - Returns: Модель класса ячейки
    
    
    /// Type of cell
    ///
    /// - Parameter index: index of cell
    /// - Returns: type
    open func cellType(at index: Int) -> UICollectionViewCell.Type {
        fatalError("Method must be overridden")
    }
    
    /// Cell filling
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - index: index of cell
    open func configureCell(_ cell: UICollectionViewCell, at index: Int) {
        fatalError("Method must be overridden")
    }
    
    /// Size of cell
    /// Tip: return nil if you want to use autolayout for size calculations
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - index: index of cell
    /// - Returns: size
    open func customSize(for cell: UICollectionViewCell, at index: Int) -> CGSize? {
        return nil
    }
    
    /// Cell initialization type
    /// code or nib
    ///
    /// - Parameter index: index of cell
    /// - Returns: initialization type
    open func cellInitializationType(at index: Int) -> SJListSectionCellInitializationType {
        fatalError("Method must be overridden")
    }

    /// Separation style for cell
    ///
    /// - Parameter index: index of cell
    /// - Returns: separation style
    open func separationStyle(at index: Int) -> SJCollectionViewCellSeparatorStyle {
        return SJListSectionControllerSeparatorStylist.defaultSeparatorStyle
    }
    
    /// Color of separator for cell
    ///
    /// - Parameter index: index of cell
    /// - Returns: separation color
    open func separationColor(at index: Int) -> UIColor {
        return SJListSectionControllerSeparatorStylist.defaultSeparatorColor
    }

}

// MARK: - View Controller Life-Cycle Callbacks
extension SJListSectionController {

    /// Subscribe for life-cycle events from view controller
    fileprivate func addObserversForLifecycle() {
        viewController?.rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .subscribe { [unowned self]  _ in
                self.onViewDidLoad()
            }
            .disposed(by: disposeBag)

        viewController?.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .subscribe { [unowned self]  _ in
                self.onViewWillAppear()
            }
            .disposed(by: disposeBag)

        viewController?.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .subscribe { [unowned self]  _ in
                self.onViewDidAppear()
            }
            .disposed(by: disposeBag)

        viewController?.rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .subscribe { [unowned self]  _ in
                self.onViewWillDisappear()
            }
            .disposed(by: disposeBag)

        viewController?.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .subscribe { [unowned self]  _ in
                self.onViewDidDisappear()
            }
            .disposed(by: disposeBag)
    }

    /// ViewDidLoad Callback
    @objc open func onViewDidLoad() {}

    /// ViewWillAppear Callback
    @objc open func onViewWillAppear() {}

    /// ViewDidAppear Callback
    @objc open func onViewDidAppear() {}

    /// ViewWillDisappear Callback
    @objc open func onViewWillDisappear() {}

    /// ViewDidDisappear Callback
    @objc open func onViewDidDisappear() {}

}

// MARK: - Helpers
extension SJListSectionController {

    /// Shortcut for collectionContext
    public var sjcollectionContext: ListCollectionContext {
        guard let context = collectionContext else {
            fatalError("collectionContext must exist")
        }
        return context
    }
    
}
