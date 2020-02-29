//
//  TripViewController.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/22.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TripViewController: UIViewController {
    
    // RX
    let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // Data
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, TripCellViewModel>>?
    
    // VM
    let tripViewModel = TripViewModel(service: TripService())
}

//MARK: - Life Cycle
extension TripViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindTripViewModel()
        tripViewModel.apiGetAllTrips()
    }
}

extension TripViewController {
    private func setupTableView() {
        tableView.register(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TripCellViewModel>>(configureCell: { (_, tv, indexPath, vm) -> TripCell in
            let cell = tv.dequeueReusableCell(withIdentifier: String(describing: TripCell.self)) as! TripCell
            cell.viewModel = vm
            return cell
        })
    }
}

extension TripViewController {
    func bindTripViewModel() {
        tripViewModel
            .tripCellVMs?
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        tripViewModel
            .loading?
            .drive(loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        tripViewModel
            .loading?
            .map({ !$0 })
            .drive(loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

extension TripViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
