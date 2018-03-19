//
//  OnboardingController.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 18/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class OnBoardingController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OnBoardingControllerDelegate {
    
    let pageCellId = "pageCellId"
    let firstPageCellId = "firstPageCellId"
    
    let pages = [
        Page(title: "Welcome to \nVoipApp. \n\nStart scrolling out this tutorial to get to know VoipApp!", image: nil),
        Page(title: "Here you can check your call history to your VoipApp friends!", image: #imageLiteral(resourceName: "HistoryScreen")),
        Page(title: "Check out how many of your friends are using the VoipApp.", image: #imageLiteral(resourceName: "VoipAppScreen")),
        Page(title: "Get all of your contacts within your app!", image: #imageLiteral(resourceName: "AllContactsScreen")),
        Page(title: "Create your own contacts without leaving the VoipApp.", image: #imageLiteral(resourceName: "NewContactScreen")),
        Page(title: "Edit your device contacts directly in VoipApp.", image: #imageLiteral(resourceName: "EditScreen"))
    ]
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    lazy var pageControl: UIPageControl = {
        let pg = UIPageControl()
        pg.numberOfPages = pages.count
        pg.currentPageIndicatorTintColor = .white
        pg.pageIndicatorTintColor = .lightGray
        pg.backgroundColor = .clear
        pg.isHidden = true
        return pg
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.voipAppGreen
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let paddingBottom = (view.frame.height * 0.6) + 10
        pageControl.anchor(top: nil, left: view.leftAnchor, bottom: collectionView.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: paddingBottom, paddingRight: 0, width: 0, height: 20)
        
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: pageCellId)
        collectionView.register(FirstPage.self, forCellWithReuseIdentifier: firstPageCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        
        print(x, view.frame.width, x/view.frame.width)
        let currentPage = Int(x/view.frame.width)
        
        //Hide pageControl on first page
        pageControl.isHidden = currentPage == 0 ? true : false
        pageControl.currentPage = currentPage
    }
    
    //MARK: - CollectionView Delegate/DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = indexPath.item == 0 ? collectionView.dequeueReusableCell(withReuseIdentifier: firstPageCellId, for: indexPath) as! FirstPage: collectionView.dequeueReusableCell(withReuseIdentifier: pageCellId, for: indexPath) as! PageCell
        cell.delegate = indexPath.item == pages.count - 1 ? self : nil
        cell.page = pages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - OnBoardingControllerDelegate
    //Dismissing ViewController
    func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
