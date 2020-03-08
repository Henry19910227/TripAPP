//
//  TripCell.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TripCell: UITableViewCell {
    
    // RX
    private var disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var tripTitleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var moreButton: UIButton!
    
    // Data
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>?
    
    // Data
    public var viewModel: TripCellViewModel? {
        didSet {
             guard let viewModel = viewModel else { return }
             collectionView.delegate = self
             bindViewModel(viewModel: viewModel)
        }
    }
}
 
extension TripCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCollectionView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        collectionView.dataSource = nil
        collectionView.delegate = nil
        disposeBag = DisposeBag()
    }
}

extension TripCell {
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "TripImageCell", bundle: nil), forCellWithReuseIdentifier: "TripImageCell")
        dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>> (configureCell: { (_, collectionView, indexPath, imageURL) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripImageCell", for: indexPath) as! TripImageCell
            cell.imageURL = imageURL
            return cell
        })
    }
}

//MARK: - Bind
extension TripCell {
    private func bindViewModel(viewModel: TripCellViewModel) {
        let input = TripCellViewModel.Input(moreTab: moreButton.rx.tap.asSignal())
        let output = viewModel.transform(input: input)
            output
                .title? 
                .bind(to: tripTitleLabel.rx.text)
                .disposed(by: disposeBag)
            output
                .content?
                .bind(to: contentLabel.rx.text)
                .disposed(by: disposeBag)
            output
                .images?
                .bind(to: collectionView.rx.items(dataSource: dataSource!))
                .disposed(by: disposeBag)
        
            output
                .moreTab?
                .emit(onNext: {
                    print("\(self.tripTitleLabel.text ?? "") 按鈕點擊!!")
                }).disposed(by: disposeBag)
    }
}

extension TripCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
