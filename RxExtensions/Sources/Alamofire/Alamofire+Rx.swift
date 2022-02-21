//
//  Alamofire+Extensions.swift
//  RxExtensions
//
//  Created by my on 2022/2/21.
//

import Foundation
import Alamofire
import RxSwift

public typealias NetworkStatus = NetworkReachabilityManager.NetworkReachabilityStatus
public typealias ConnectionType = NetworkStatus.ConnectionType

public protocol NetworkReachabilityListener: AnyObject {
    func networkStatusDidChanged(_ status: NetworkStatus)
}

fileprivate final class NetworkReachabilityManagerListenerCenter {
    let listeners: NSPointerArray = NSPointerArray.weakObjects()
    
    func addListener<L: NetworkReachabilityListener>(_ listener: L) {
        listeners.addPointer(nil)
        listeners.compact()
        
        let pointer = Unmanaged.passUnretained(listener).toOpaque()
        listeners.addPointer(pointer)
    }
    
    func listenReachability(_ reachabilityManager: NetworkReachabilityManager) {
        reachabilityManager.startListening { [weak self] status in
            self?.invokeListeners(status)
        }
    }
    
    private func invokeListeners(_ status: NetworkStatus) {
        listeners.addPointer(nil)
        listeners.compact()
        
        for index in 0 ..< listeners.count {
            guard let pointer = listeners.pointer(at: index),
                  let listener = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as? NetworkReachabilityListener
            else {
                continue
            }
            
            listener.networkStatusDidChanged(status)
        }
    }
}

fileprivate var networkReachabilityManagerCenter = "com.xgxw.network.center.associate.key"
extension NetworkReachabilityManager {
    
    public func addListener<L: NetworkReachabilityListener>(_ listener: L) {
        var center = objc_getAssociatedObject(self, &networkReachabilityManagerCenter) as? NetworkReachabilityManagerListenerCenter
        if center == nil {
            center = NetworkReachabilityManagerListenerCenter()
            center?.listenReachability(self)
            objc_setAssociatedObject(self, &networkReachabilityManagerCenter, center, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        center?.addListener(listener)
    }
}

fileprivate final class _RxNetworkReachabilityManagerListener: NetworkReachabilityListener, Disposable {
    
    let callback: (NetworkStatus) -> Void
    var retainSelf: _RxNetworkReachabilityManagerListener?
    init(callback: @escaping (NetworkStatus) -> Void) {
        self.callback = callback
        self.retainSelf = self
    }
    
    func dispose() {
        retainSelf = nil
    }
    
    func networkStatusDidChanged(_ status: NetworkStatus) {
        callback(status)
    }
}

internal final class NetworkReachabilityManagerObservable: ObservableType {
    typealias Element = NetworkStatus
    
    unowned let reachability: NetworkReachabilityManager
    init(_ reachability: NetworkReachabilityManager) {
        self.reachability = reachability
    }

    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Element == O.Element {
        let _listener = _RxNetworkReachabilityManagerListener { status in
            observer.onNext(status)
        }
        self.reachability.addListener(_listener)
        return Disposables.create(with: _listener.dispose)
    }
}


extension NetworkReachabilityManager: ReactiveCompatible {}

extension Reactive where Base: NetworkReachabilityManager {
    public var networkStatus: Observable<NetworkStatus> {
        return NetworkReachabilityManagerObservable(base).asObservable()
    }
}
