//
//  DetailViewController.swift
//  OMI
//
//  Created by simyo on 2021/10/29.
//

import UIKit
import SwiftUI

class DetailViewController: UIViewController {
//    let list = ["comforter", "t-shirt", "blue-jean", "comforter", "t-shirt"]
    
    let list = ClothesList()
    var clothesList:[String]?
    var tempText:String!
    var descriptionText:String!
    var locationText:String!
    var index:Int = 0
    
    
//    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var DetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = "오늘의 옷추천!"
        tempLabel.text = tempText
        calculateTempRange(tempText)
        
        
        scrollView.delegate = self
        if let list = clothesList {
            let subList = list[0...3]
            print(subList)
            addContentScrollView(subList, 0)
            setPageControl(subList, subList.count)
        }
        
        
        
//        addContentScrollView()
        
        
//        collectionView.delegate = self
//        collectionView.dataSource = self
        
//
//        let nibName = UINib(nibName: "ClothesInDetailViewCell", bundle: nil)
//        self.collectionView.register(nibName, forCellWithReuseIdentifier: "clothesCell")
//
//        let flowlayout = UICollectionViewFlowLayout()
//        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.size.height)
//        flowlayout.minimumInteritemSpacing = 0
//        flowlayout.minimumLineSpacing = 0
//        flowlayout.scrollDirection = .horizontal
//        collectionView.collectionViewLayout = flowlayout
//
        
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
//    }

    func calculateTempRange(_ temp:String){
        if let temp = Int(tempText){
            switch temp{
            case 28...:
                clothesList = list.list28
                DetailLabel.text = list.clothes_28
            case 23...27:
                clothesList = list.list23to27
                DetailLabel.text = list.clothes_23_to_27
            case 20...22:
                clothesList = list.list20to22
                DetailLabel.text = list.clothes_20_to_22
            case 17...19:
                clothesList = list.list17to19
                DetailLabel.text = list.clothes_17_to_19
            case 12...16:
                clothesList = list.list12to16
                DetailLabel.text = list.clothes_12_to_16
            case 9...11:
                clothesList = list.list9to11
                DetailLabel.text = list.clothes_9_to_11
            case 5...8:
                clothesList = list.list5to8
                DetailLabel.text = list.clothes_5_to_8
            default:
                clothesList = list.list4
                DetailLabel.text = list.clothes_4
            }
        }
   
    }
    
    @IBAction func actChangeKindOfClothes(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if let list = clothesList {
            switch index {
            case 1:
                let subList = list[4...5]
                print(subList)
                addContentScrollView(subList, 4)
                setPageControl(subList, subList.count)
            case 2:
                let subList = list[6...]
                print(subList)
                addContentScrollView(subList, 6)
                setPageControl(subList, subList.count)
            default:
                let subList = list[0...3]
                print(subList)
                addContentScrollView(subList, 0)
                setPageControl(subList, subList.count)
            }
        }
        
    }
    
    
    private func addContentScrollView(_ list:ArraySlice<String>, _ start:Int){
//        if let list = list {
//            print(list)
//            for i in 0..<list.count{
//                let imageView = UIImageView()
//                let xPos = self.view.frame.width * CGFloat(i)
//                imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
//                imageView.image = UIImage(named: list[i])
//                imageView.contentMode = .scaleAspectFit
//                scrollView.addSubview(imageView)
//                scrollView.contentSize.width = imageView.frame.width * CGFloat(i+1)
//            }
//        }
 
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        for i in start...(start+list.count-1){
            
            
            let imageView = UIImageView()
            let xPos = self.scrollView.frame.width * CGFloat(index)
            imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            print("scrollView bounds width",scrollView.bounds.width)
            imageView.image = UIImage(named: list[i])
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            scrollView.contentSize.width = imageView.frame.width * CGFloat(index+1)
            print("contentsize width",scrollView.contentSize.width)
            index += 1
        }
        
        index = 0
    }
    
    private func setPageControl(_ list:ArraySlice<String>, _ count:Int){
        pageControl.numberOfPages = list.count
    }
    private func setPageControlSelectedPage(currentPage:Int){
        pageControl.currentPage = currentPage
    }
}

extension DetailViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}

//extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let list = clothesList {
//            return list.count
//        }
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clothesCell", for: indexPath) as! ClothesInDetailViewCell
//        if let list = clothesList {
//            cell.imageView.image = UIImage(named: list[indexPath.row])
//        }
//        return cell
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
//        let pageInt = Int(round(pageFloat))
//
//
//        if let list = clothesList {
//            switch pageInt {
//            case 0:
//                collectionView.scrollToItem(at: [0, 3], at: .left, animated: false)
//            case list.count - 1:
//                collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
//            default:
//                break
//            }
//        }
//    }
//}
