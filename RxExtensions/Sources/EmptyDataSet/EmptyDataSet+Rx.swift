//
//  EmptyDataSet+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/8.
//

import UIKit
import RxSwift
import RxCocoa
import EmptyDataSet_Swift

fileprivate class _TableViewDelegate: NSObject, UITableViewDelegate, Disposable {
    let configSectionHeader: ((Int) -> UIView?)?
    let configSectionFooter: ((Int) -> UIView?)?
    
    var retainSelf: _TableViewDelegate?
    
    init(configSectionHeader: ((Int) -> UIView?)?, configSectionFooter: ((Int) -> UIView?)?) {
        self.configSectionHeader = configSectionHeader
        self.configSectionFooter = configSectionFooter
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return configSectionHeader?(section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return configSectionFooter?(section)
    }
    
    func dispose() {
         retainSelf = nil
    }
}

internal final class TableViewEmptyDataSource: NSObject, EmptyDataSetSource {
    
    var title: NSAttributedString?
    
    var image: UIImage?
    
    var verticalOffset: CGFloat = 0
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return title
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return image
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return verticalOffset
    }
}

internal class TableViewEmptyDelegate: NSObject, EmptyDataSetDelegate {
    
    var allowScroll: Bool = true
    
    var didTapView: ((UIView) -> Void)?
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return allowScroll
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {
        didTapView?(view)
    }
}

fileprivate final class _TableViewEmptyDelegateObserver: TableViewEmptyDelegate, Disposable {
    
    var retainSelf: _TableViewEmptyDelegateObserver?
    init(didTapView: @escaping (UIView) -> Void) {
        super.init()
        self.didTapView = didTapView
        self.retainSelf = self
    }
    
    func dispose() {
        retainSelf = nil
    }
}

internal final class TableViewEmptyDelegateObservable: ObservableType {
    typealias Element = UIView
    weak var target: UITableView?
    init(target: UITableView) {
        self.target = target
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Element == O.Element {
        let _observer = _TableViewEmptyDelegateObserver {
            observer.onNext($0)
        }
        target?.emptyDataSetDelegate = _observer
        return Disposables.create(with: _observer.dispose)
    }
}

fileprivate var emptySetDataSourceAssociatedKey = "com.xgxw.table.view.empty.set.datasource"
fileprivate var emptySetDelegateAssociatedKey = "com.xgxw.table.view.empty.set.delegate"

extension UITableView {

    private var emptySetDelgate: TableViewEmptyDelegate? {
        var _delegate = objc_getAssociatedObject(self, &emptySetDelegateAssociatedKey) as?
            TableViewEmptyDelegate
        if _delegate == nil {
            _delegate = TableViewEmptyDelegate()
            objc_setAssociatedObject(self, &emptySetDelegateAssociatedKey, _delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        emptyDataSetDelegate = _delegate
        return _delegate
    }
    
    private var emptySetDataSource: TableViewEmptyDataSource? {
        var _dataSource = objc_getAssociatedObject(self, &emptySetDataSourceAssociatedKey) as?
            TableViewEmptyDataSource
        if _dataSource == nil {
            _dataSource = TableViewEmptyDataSource()
            emptyDataSetSource = _dataSource
            objc_setAssociatedObject(self, &emptySetDataSourceAssociatedKey, _dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return _dataSource
    }
    
   public var titleForEmpty: NSAttributedString? {
        get { emptySetDataSource?.title }
        set {
            emptySetDataSource?.title = newValue
        }
    }
    
   public var imageForEmpty: UIImage? {
        get { emptySetDataSource?.image }
        set {
            emptySetDataSource?.image = newValue
        }
    }
    
   public var verticleOffsetForEmpty: CGFloat? {
        get { emptySetDataSource?.verticalOffset }
        set {
            emptySetDataSource?.verticalOffset = newValue ?? 0
        }
    }
}

extension Reactive where Base: UITableView {
   public func setSection(_ header: ((Int) -> UIView?)?, _ footer: ((Int) -> UIView?)? = nil) -> Disposable {
        let _delegate = _TableViewDelegate(configSectionHeader: header, configSectionFooter: footer)
        let dispose = base.rx.setDelegate(_delegate)
        return Disposables.create(dispose, _delegate)
    }
        
    public var emptyDataSetDidTapView: Observable<UIView> {
        return TableViewEmptyDelegateObservable(target: base).asObservable()
    }
}


