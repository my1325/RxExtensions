//
//  ASAuthorizationAppleIDProvider+Rx.swift
//  RxExtensions
//
//  Created by my on 2022/2/21.
//

import Foundation
import AuthenticationServices
import RxSwift

public struct AppleLoginResposne {
    let nickName: String
    let openId: String
}

fileprivate final class ASAuthorizationAppleIDProviderObserver: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, Disposable {
    
    let presentationAnchor: ASPresentationAnchor
    let block: (Result<AppleLoginResposne, Error>) -> Void
    
    var retainSelf: ASAuthorizationAppleIDProviderObserver?
    init(_ presentationAnchor: ASPresentationAnchor, block: @escaping (Result<AppleLoginResposne, Error>) -> Void) {
        self.presentationAnchor = presentationAnchor
        self.block = block
        super.init()
        self.retainSelf = self
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        block(.failure(error))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let nickName = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
            let retResponse = AppleLoginResposne(nickName: nickName, openId: appleIDCredential.user)
            block(.success(retResponse))
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            _ = passwordCredential.user
            _ = passwordCredential.password
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationAnchor
    }
    
    func dispose() {
        retainSelf = nil
    }
}

internal final class ASAuthorizationAppleIDProviderObservable: ObservableType {
    typealias Element = AppleLoginResposne
    
    let anchor: ASPresentationAnchor
    let request: ASAuthorizationAppleIDProvider
    init(_ presentationAnchor: ASPresentationAnchor, _ request: ASAuthorizationAppleIDProvider) {
        self.request = request
        self.anchor = presentationAnchor
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Element == O.Element {
        let _observer = ASAuthorizationAppleIDProviderObserver(anchor) { result in
            switch result {
            case let .success(response):
                observer.on(.next(response))
                observer.on(.completed)
            case let .failure(error):
                observer.on(.error(error))
            }
        }
        
        let _request = request.createRequest()
        _request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [_request])
        authorizationController.delegate = _observer
        authorizationController.presentationContextProvider = _observer
        authorizationController.performRequests()

        return Disposables.create(with: _observer.dispose)
    }
}

extension Reactive where Base: ASAuthorizationAppleIDProvider {
    public func requestAppleLoginResponse(_ anchor: ASPresentationAnchor) -> Observable<AppleLoginResposne> {
        return ASAuthorizationAppleIDProviderObservable(anchor, base).asObservable()
    }
}

