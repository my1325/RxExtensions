//
//  UIView+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/8.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate final class _UIViewTapGestureObject<E: UIView>: Disposable {
    
    var retainSelf: _UIViewTapGestureObject?
    weak var target: E?
    let block: (E) -> Void
    init(target: E, block: @escaping (E) -> Void) {
        self.target = target
        self.block = block
        
        target.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_handleTapGesture))
        target.addGestureRecognizer(gesture)
    }
    
    @objc func _handleTapGesture() {
        guard let _target = target else { return }
        block(_target)
    }
    
    func dispose() {
        retainSelf = nil
    }
}

internal final class UIViewTapGestureObservable<Element>: ObservableType where Element: UIView {
    unowned let _view: Element
    init(_ target: Element) {
        self._view = target
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Element == O.Element {
        let _observer = _UIViewTapGestureObject(target: _view) { target in
            observer.onNext(target)
        }
        return Disposables.create(with: _observer.dispose)
    }
}

extension Reactive where Base: UIView {
    public var tapGesture: Observable<Base>{
        return UIViewTapGestureObservable(base).asObservable()
    }
}
