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
    lazy var rightButton = UIButton(type: .infoLight)
    
    // Data
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, TripCellViewModel>>?
    
    // VM
    let tripViewModel = TripViewModel(service: TripService())
}

//MARK: - Life Cycle
extension TripViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRightButton()
        setupTableView()
        bindTripViewModel()
        tripViewModel.apiGetAllTrips()
    }
}

extension TripViewController {
    private func setupTableView() {
        tableView.register(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "TripCell")
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TripCellViewModel>>(configureCell: { (_, tableView, indexPath, vm) -> TripCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TripCell.self)) as! TripCell
            cell.viewModel = vm
            return cell
        }, canMoveRowAtIndexPath: { (_, _) -> Bool in
            return true
        })
    }
    
    private func setupRightButton() {
        rightButton.addTarget(self, action: #selector(infoButtonClick), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }
}

extension TripViewController {
    func bindTripViewModel() {
        
        let input = TripViewModel.TripInput(infoTab: rightButton.rx.tap.asSignal())
        let output = tripViewModel.transform(input: input)
        
        output
            .tripCellVMs?
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        output
            .loading?
            .drive(loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        output
            .loading?
            .map({ !$0 })
            .drive(loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

//MARK: - UITableViewDelegate
extension TripViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

//MARK: - UITableViewDropDelegate
extension TripViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print("performDropWith")
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

//MARK: - UITableViewDragDelegate
extension TripViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}

extension TripViewController {
    @objc func infoButtonClick() {
        dataSource?.sectionModels.first?.items.forEach({ (vm) in
            print("title : \(vm.model?.title ?? "")")
        })
    }
}
