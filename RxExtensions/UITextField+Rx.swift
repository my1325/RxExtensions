//
//  UITextField+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/9.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UITextField {
    
    func setLimitCount(_ count: Int) -> Disposable {
        return base.rx.controlEvent(.editingChanged).subscribe { [weak textFiled = base] _ in
            if let text = textFiled?.text,  text.count > count {
                textFiled?.text = String(text.prefix(count))
            }
        }
    }

    func whenCountEqual(_ count: Int) -> Observable<Void> {
        return base.rx.controlEvent(.editingChanged).filter({ [weak textFeild = base] _ in (textFeild?.text?.count ?? 0) == count })
    }
    
    func setLimitCount(_ count: Int) -> (_ block: @escaping () -> Void) -> Disposable {
        return { handler in
            return base.rx.controlEvent(.editingChanged).subscribe { [weak textFiled = base] _ in
                guard let text = textFiled?.text else { return }
                if text.count == count {
                    handler()
                } else if text.count > count {
                    textFiled?.text = String(text.prefix(count))
                }
            }
        }
    }
    
    var isSecureTextEntry: Binder<Bool> {
        return Binder(base) { textFeild, isSecureTextEntry in
            textFeild.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var textToBind: Binder<String?> {
        return Binder(base) { textFiled, new in
            textFiled.text = new
        }
    }
}
