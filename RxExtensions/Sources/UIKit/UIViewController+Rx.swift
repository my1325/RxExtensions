//
//  File.swift
//  
//
//  Created by my on 2022/2/7.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    var willAppear: Observable<Void> {
        return methodInvoked(#selector(base.viewWillAppear(_:))).map({ _ in () })
    }
    
    var didAppear: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:))).map({ _ in () })
    }
    
    var willDisappear: Observable<Void> {
        return methodInvoked(#selector(base.viewWillDisappear(_:))).map({ _ in () })
    }
    
    var didDisappear: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:))).map({ _ in () })
    }
    
    var viewDidLayoutSubviews: Observable<Void> {
        return methodInvoked(#selector(base.viewDidLayoutSubviews)).map({ _ in () })
    }
}
