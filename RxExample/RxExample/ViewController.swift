//
//  ViewController.swift
//  RxExample
//
//  Created by my on 2022/2/7.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
import JXSegmentedView

enum Pages {
    case `default`
}

extension Pages {
    var title: String {
        switch self {
        case .default:
            return "默认的"
        }
    }
    
    var listController: JXSegmentedListContainerViewListDelegate {
        switch self {
        case .default:
            return TableViewController()
        }
    }
}

class ViewController: UIViewController {
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        $0.titleNormalColor = UIColor.black
        $0.titleNormalFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleSelectedColor = UIColor.red
        $0.titleSelectedFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        return $0
    }(JXSegmentedTitleDataSource())

    private lazy var segmentedView: JXSegmentedView = {
        $0.dataSource = segmentedDataSource
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorHeight = 2
        indicator.indicatorColor = UIColor.red
        $0.indicators = [indicator]
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        self.view.addSubview($0)
        return $0
    }(JXSegmentedView())

    private lazy var listContainerView: JXSegmentedListContainerView! = {
        self.segmentedView.listContainer = $0
        $0.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 675)
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview($0)
        return $0
    }(JXSegmentedListContainerView(dataSource: self.dataSource))

    private let dataSource = SegmentedListContainerViewDataSource()
        
    private var pages: [Pages] = [.default, .default, .default, .default]
    
    private let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "JXSegmentedView"
        edgesForExtendedLayout = .bottom
        
        Observable.just(pages.map({ $0.title })).bind(to: segmentedDataSource.rx.titles).disposed(by: disposeBag)
        Observable.just(pages.map({ $0.listController })).bind(to: listContainerView.rx.dataSource).disposed(by: disposeBag)     
    }
}


