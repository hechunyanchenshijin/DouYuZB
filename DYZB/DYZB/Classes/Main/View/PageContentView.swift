//
//  PageContentView.swift
//  DYZB
//
//  Created by 时锦 陈 on 2017/2/24.
//  Copyright © 2017年 Yun. All rights reserved.
//

import UIKit

protocol PageContentViewDelegate : class {
    func pageContentView(contentView : PageContentView, progress : CGFloat, sourceIndex : Int, targetIndex : Int)
}

private let ContentCellID = "ContentCellID"

class PageContentView: UIView {

    // MARK:- 定义属性
    fileprivate var childVCs : [UIViewController]
    fileprivate weak var parentViewController : UIViewController?
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate var isForbidScrollDelegate : Bool = false
    weak var delegate : PageContentViewDelegate?

    // MARK:- 懒加载属性
    fileprivate lazy var collectionView : UICollectionView = {[weak self] in
        // 1. 创建layout
        let layout = UICollectionViewFlowLayout()  // 流水布局
        layout.itemSize = (self?.bounds.size)!
        layout.minimumLineSpacing = 0  // 行间距
        layout.minimumInteritemSpacing = 0 // item间距
        layout.scrollDirection = .horizontal
        
        // 2.创建UICollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ContentCellID)
        
        return collectionView
        
    }()

    
    // MARK:- 自定义构造函数
    init(frame: CGRect, childVCs : [UIViewController], parentViewController : UIViewController?) {
        self.childVCs = childVCs
        self.parentViewController = parentViewController
        
        super.init(frame: frame)
        
        // 设置UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


// MARK:- 设置UI界面
extension PageContentView {
    fileprivate func setupUI() {
        // 1. 将我们所有的子控制器添加到父控制器中
        for childVC in childVCs {
            parentViewController?.addChildViewController(childVC)
        }
        
        // 2. 添加UICollectionView， 用于在cell中存放控制器的View
        addSubview(collectionView)
        collectionView.frame = bounds
    }
}

// MARK:- 遵守UICollectionViewDataSource
extension PageContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1. 创建cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCellID, for: indexPath)
        
        //2. 给cell设置内容
        // 2.1 由于循环利用, 避免循环添加, 先删除所有的子视图
        for view in cell.contentView.subviews {  // 防止添加多次
            view.removeFromSuperview()
        }
        
        
        let childVC = childVCs[indexPath.item]
        childVC.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVC.view)
        
        return cell
    }
}


// MARK:- 对外暴露的方法

extension PageContentView {
    func setCurrentIndex(currentIndex : Int) {
        
        // 0. 记录需要禁止执行代理方法，当是点击label进行页面切换的时候，不需要执行代理方法
        isForbidScrollDelegate = true
        
        // 1.计算偏移量
        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        
        // 2.设置collectionView的偏移位置
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}

// MARK:- 遵守UICollectionViewDelegate
extension PageContentView : UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isForbidScrollDelegate = false
        
         startOffsetX = scrollView.contentOffset.x
    }
    
    // 当点击label进行页面切换的时候，只是设置了偏移量，也会走这个方法，不会走上面那个方法，所以要写个判断，当这种情况时不走
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //0. 判断是否是点击事件
        if isForbidScrollDelegate { return }

        // 1.定义获取需要的数据
        var progress : CGFloat = 0
        var sourceIndex : Int = 0
        var targetIndex : Int = 0
        
        // 2. 判断左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startOffsetX { // 大于开始的偏移量，就是左滑
            // 1. 计算progress
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            
            // 2. 计算sourceIndex
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            // 3. 计算targetIndex
            targetIndex = sourceIndex + 1
            if targetIndex >= childVCs.count {
                targetIndex = childVCs.count - 1
            }
            
            // 4. 如果完全滑过去了
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
            }
            
        } else {  // 小于开始的偏移量就是右滑
            // 1. 计算progress
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            // 2. 计算targetIndex
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            // 3. 计算sourceIndex
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVCs.count {
                sourceIndex = childVCs.count - 1
            }

        }
        
        
        // 3. 将progress，sourceIndex，targetIndex传递给titleView
        delegate?.pageContentView(contentView: self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}

