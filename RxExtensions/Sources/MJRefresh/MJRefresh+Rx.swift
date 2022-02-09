//
//  MJRefresh+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/8.
//

import MJRefresh
import RxSwift
import RxCocoa
import UIKit

internal class MJRefreshTarget {
    let headerRefresh: (() -> Void)?
    let footerRefresh: (() -> Void)?
    init(target: UIScrollView, headerRefresh: (() -> Void)?, footerRefresh: (() -> Void)?) {
        self.headerRefresh = headerRefresh
        self.footerRefresh = footerRefresh

        if let header = headerRefresh {
            target.mj_header = MJRefreshNormalHeader(refreshingBlock: header)
        }

        if let footer = footerRefresh {
            target.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: footer)
        }
    }
}

private final class _MJRefreshObserver: MJRefreshTarget, Disposable {
    var returnSelf: _MJRefreshObserver?
    override init(target: UIScrollView, headerRefresh: (() -> Void)?, footerRefresh: (() -> Void)?) {
        super.init(target: target, headerRefresh: headerRefresh, footerRefresh: footerRefresh)
        returnSelf = self
    }

    func dispose() {
        returnSelf = nil
    }
}

internal final class MJRefreshHeaderObservable: ObservableType {
    typealias Element = Void
    unowned let target: UIScrollView
    init(target: UIScrollView) {
        self.target = target
    }

    func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, Element == O.Element {
        let _observer = _MJRefreshObserver(target: target, headerRefresh: {
            observer.onNext(())
        }, footerRefresh: nil)
        return Disposables.create(with: _observer.dispose)
    }
}

internal final class MJRefreshFooterObservable: ObservableType {
    typealias Element = Void
    unowned let target: UIScrollView
    init(target: UIScrollView) {
        self.target = target
    }

    func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, Element == O.Element {
        let _observer = _MJRefreshObserver(target: target, headerRefresh: nil, footerRefresh: {
            observer.onNext(())
        })
        return Disposables.create(with: _observer.dispose)
    }
}

extension Reactive where Base: UIScrollView {
    public var refreshHeader: Observable<Void> {
        return MJRefreshHeaderObservable(target: base).asObservable()
    }

    public var refreshFooter: Observable<Void> {
        return MJRefreshFooterObservable(target: base).asObservable()
    }
    
    public var refreshEndState: Binder<MJRefreshState> {
        return Binder(base) { scrollView, state in
            switch state {
            case .idle:
                scrollView.mj_header?.endRefreshing()
                scrollView.mj_footer?.endRefreshing()
            case .noMoreData:
                scrollView.mj_header?.endRefreshing()
                scrollView.mj_footer?.endRefreshingWithNoMoreData()
            case .pulling, .refreshing, .willRefresh:
                return
            @unknown default:
                return
            }
        }
    }
}

extension Reactive where Base: MJRefreshComponent {
    
    public var state: Binder<MJRefreshState> {
        return Binder(base) { refresh, state in
            refresh.state = state
        }
    }

    public var beginRefresh: Binder<Void> {
        return Binder(base) { refresh, _ in
            refresh.beginRefreshing()
        }
    }

    public var endRefresh: Binder<Void> {
        return Binder(base) { refresh, _ in
            refresh.endRefreshing()
        }
    }
    
    public var isRefreshing: Observable<Bool> {
        return observeWeakly(Bool.self, "refreshing").map { $0 ?? false }
    }
}


