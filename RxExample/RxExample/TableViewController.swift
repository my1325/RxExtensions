//
//  TableViewController.swift
//  RxExample
//
//  Created by my on 2022/2/9.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
import MJRefresh
import JXSegmentedView

class TableViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.gray
        $0.frame = CGRect(x: 15, y: 0, width: 315, height: 44)
        self.contentView.addSubview($0)
        return $0
    }(UILabel())
}

class TableViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        $0.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        $0.rowHeight = 44
        $0.titleForEmpty = NSAttributedString(string: "nothing more", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray])
        $0.imageForEmpty = UIImage(named: "icon_empty_holder")
        self.view.addSubview($0)
        return $0
    }(UITableView(frame: .zero, style: .plain))
    
    private let sources: BehaviorRelay<[String]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()
    private var requestDisposeBag = DisposeBag()
    private var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "TableView"
        edgesForExtendedLayout = .bottom
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        sources.bind(to: tableView.rx.items(cellIdentifier: "TableViewCell", cellType: TableViewCell.self))({
            tableView, item, cell in
            cell.titleLabel.text = item
        }).disposed(by: disposeBag)
        
        Observable.merge(tableView.rx.refreshHeader.do(onNext: onRefresh), tableView.rx.refreshFooter).bind(to: onRequest({ [weak self] in
            guard let self = self else { return }
            self.requestDisposeBag = DisposeBag()
            $0.map({ $0.isEmpty ? MJRefreshState.noMoreData : .idle })
                .catchAndReturn(.idle)
                .asObservable()
                .bind(to: self.tableView.rx.refreshEndState)
                .disposed(by: self.requestDisposeBag)
        })).disposed(by: disposeBag)
        
        _ = rx.willAppear.take(1).bind(to: tableView.mj_header!.rx.beginRefresh).disposed(by: disposeBag)
    }
    
    private func onRefresh() {
        page = 1
    }
    
    private func requestData(_ page: Int, _ handler: @escaping (Single<[String]>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if page > 10 {
                self?.page = 1
                handler(.just([]))
            } else {
                let list = (1 ... 10).map({ String(format: "第%d个", $0 + ((self?.page ?? 1) - 1) * 10) })
                var origin = self?.sources.value ?? []
                if page == 1 { origin.removeAll() }
                origin.append(contentsOf: list)
                self?.page += 1
                self?.sources.accept(origin)
                handler(.just(list))
            }
        }
    }
    
    private func onRequest(_ handler: @escaping (Single<[String]>) -> Void) -> Binder<Void> {
        return Binder(self) { controller, _ in
            controller.requestData(controller.page, handler)
        }
    }
}

extension TableViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
