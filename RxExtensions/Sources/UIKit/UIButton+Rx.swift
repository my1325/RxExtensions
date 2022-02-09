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
    
    var oppositiveSelectedWhenTap: Observable<Bool> {
        return tap().do(onNext: { $0.isSelected = !$0.isSelected }).map({ $0.isSelected })
    }
}
