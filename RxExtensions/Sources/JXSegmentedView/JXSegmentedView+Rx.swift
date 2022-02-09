//
//  JXSegmentedView+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/8.
//

import UIKit
import JXPagingView
import JXSegmentedView
import RxSwift
import RxCocoa

open class SegmentedListContainerViewDataSource: JXSegmentedListContainerViewDataSource {
    
    public init() {}
    
    var list: [JXSegmentedListContainerViewListDelegate] = []
    
    public func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return list.count
    }
    
    public func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return list[index]
    }
}

extension SegmentedListContainerViewDataSource: ReactiveCompatible {}

extension Reactive where Base: SegmentedListContainerViewDataSource {
    public var list: Binder<[JXSegmentedListContainerViewListDelegate]> {
        return Binder(base) { dataSource, list in
            dataSource.list = list
        }
    }
}

extension Reactive where Base: JXSegmentedListContainerView {
    public var dataSource: Binder<[JXSegmentedListContainerViewListDelegate]> {
        return Binder(base) { listView, list in
            if let _listDataSource = listView.dataSource as? SegmentedListContainerViewDataSource {
                _listDataSource.list = list
                listView.reloadData()
            }
        }
    }
}

extension JXSegmentedTitleDataSource: ReactiveCompatible {}

extension Reactive where Base: JXSegmentedTitleDataSource {
    public var titles: Binder<[String]> {
        return Binder(base) { dataSource, titles in
            dataSource.titles = titles
        }
    }
}
