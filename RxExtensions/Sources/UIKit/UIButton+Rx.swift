//
//  UIButton+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/9.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIButton {

    func tap() -> Observable<Base> {
        return base.rx.tap.asObservable().flatMap { _ in Observable.just(base) }
    }
    
    var toggleSelected: Observable<Bool> {
        return tap().do(onNext: { $0.isSelected.toggle() }).map({ $0.isSelected })
    }
}
