//
//  BannerView.swift
//  RxTest
//
//  Created by 李晓东 on 2017/11/21.
//  Copyright © 2017年 晓东. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import Kingfisher


protocol BannerDelegate {
    func selectedItem(model: storyModel)
    func scrollTo(index: Int)
}

class BannerView: UICollectionView {
    //Mark: Variable 、PublishSubject 是Subject的一种，可当观察者被bindTo，可当序列数据源Observable
    let imageURLArr = Variable([storyModel]()) //RxSwift
    let dispose = DisposeBag()
    var offY = Variable(0.0)
    var bannerDelegate: BannerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentOffset.x = ScreenWidth
        
        /*
         首先让放图片的数组变成可被观察的
         然后绑定cell的数据源
         */
        imageURLArr
            .asObservable()
            .bind(to: rx.items(cellIdentifier: "BannerCell", cellType: BannerCell.self)) {
                row, model, cell in
                cell.img.kf.setImage(with: URL.init(string: model.image!))
                cell.imgTitle.text = model.title!
            }
            .addDisposableTo(dispose)
        
        
        offY
            .asObservable()
            .subscribe(onNext: { (offY) in
                self.visibleCells.forEach({ (cell) in
                    let cell = cell as! BannerCell
                    cell.img.frame.origin.y = CGFloat.init(offY)
                    cell.img.frame.size.height = 200 - CGFloat.init(offY)
                })
            })
            .addDisposableTo(dispose)
        
        
        rx
            .modelSelected(storyModel.self)
            .subscribe(onNext: { (model) in
                self.bannerDelegate?.selectedItem(model: model)
            })
            .addDisposableTo(dispose)
    }
    
}


extension BannerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == CGFloat.init(imageURLArr.value.count - 1) * ScreenWidth {
            scrollView.contentOffset.x = ScreenWidth
        } else if scrollView.contentOffset.x == 0 {
            scrollView.contentOffset.x = CGFloat.init(imageURLArr.value.count - 2) * ScreenWidth
        }
        
        bannerDelegate?.scrollTo(index: Int(scrollView.contentOffset.x / ScreenWidth) - 1)
    }
}
