//
//  OKViewPager.swift
//  OKViewPager
//
//  Created by Omer Karayel on 31/01/17.
//  Copyright © 2017 Omer Karayel. All rights reserved.
//

import UIKit

protocol OKViewPagerDelegate: class {
    func didSelectViewInIndexPath(index: Int)
}
protocol OKViewPagerDataSource:class {
    func viewForItem(at index: Int) -> UIView
    func numberOfViews() -> Int
}
class OKViewPager: UIScrollView {
    
    /// All the views in the loop.
    var viewsToRotate: [UIView]!
    /// Scolls vertically if false.
    var scrollHorizontally: Bool = true
    /// Three views to be actually shown on the scollView.
    var viewsShown: [UIView]! {
        didSet {
            contentOffset = secondOrigin
            zip(viewsShown, origins).forEach {
                $0.0.frame = CGRect(origin: $0.1, size: $0.0.frame.size)
                addSubview($0.0)
            }
        }
    }
    /// Delegate
    weak var delegatePager: OKViewPagerDelegate?
    /// Data Source
    weak var dataSourcePager: OKViewPagerDataSource? {
        didSet {
            setViews()
        }
    }
    /// Variables
    var pageWidth: CGFloat {
        return viewsToRotate.first == nil ? CGFloat(0) : viewsToRotate.first!.frame.width
    }
    var pageHeight: CGFloat {
        return viewsToRotate.first == nil ? CGFloat(0) : viewsToRotate.first!.frame.height
    }
    var contentWidth: CGFloat {
        return pageWidth * CGFloat(scrollHorizontally ? viewsToRotate.count : 1)
    }
    var contentHeight: CGFloat {
        return pageHeight * CGFloat(scrollHorizontally ? 1 : viewsToRotate.count)
    }
    /// Origin of first shown view.
    var firstOrigin: CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    /// Origin of second shown view.
    var secondOrigin: CGPoint {
        return CGPoint(x: (scrollHorizontally ? firstOrigin.x + pageWidth : firstOrigin.x), y: (scrollHorizontally ? firstOrigin.y : firstOrigin.y + pageHeight))
    }
    /// Origin of third shown view.
    var thirdOrigin: CGPoint {
        return CGPoint(x: (scrollHorizontally ? secondOrigin.x + pageWidth : secondOrigin.x), y: (scrollHorizontally ? secondOrigin.y : secondOrigin.y + pageHeight))
    }
    /// Origins of the three shown view
    var origins: [CGPoint] {
        return [firstOrigin, secondOrigin, thirdOrigin]
    }
    
    //MARK: - Setup
    func setMiddleView(_ index: Int) {
        if index < viewsToRotate.count {
            let middleView = viewsToRotate[index]
            resetMiddleViewShown(middle: middleView)
        } else { fatalError("No view to show") }        
    }
    
    private func resetMiddleViewShown(middle: UIView) {
        viewsToRotate.forEach { $0.removeFromSuperview() }
        guard let updatedViewsShown = viewsToRotate.formThreeCircularlyConsecutiveElements(middle: middle) else {
            fatalError("No view to show.")
        }
        viewsShown = updatedViewsShown
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var viewInMiddle: UIView? = nil
        if scrollHorizontally {
            if contentOffset.x == 0 || contentOffset.x >= pageWidth * 2 {
                if contentOffset.x == 0 {
                    viewInMiddle = viewsShown[0]
                }
                if contentOffset.x >= pageWidth * 2 {
                    viewInMiddle = viewsShown[2]
                }
            }
        } else {
            if contentOffset.y == 0 || contentOffset.y == pageHeight * 2 {
                if contentOffset.y == 0 {
                    viewInMiddle = viewsShown[0]
                }
                if contentOffset.y == pageHeight * 2 {
                    viewInMiddle = viewsShown[2]
                }
            }
        }
        if let view = viewInMiddle {
            resetMiddleViewShown(middle: view)
        }
    }
}

extension OKViewPager: UIScrollViewDelegate {
    
    convenience init(frame: CGRect, viewsToRotate: [UIView], scrollHorizontally: Bool = true) {
        self.init(frame: frame)
        self.scrollHorizontally = scrollHorizontally
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
       
        viewsToRotate.forEach {
            let tapped = UITapGestureRecognizer(target: self, action: #selector(tappedView))
            $0.addGestureRecognizer(tapped)
        }
    }

    //MARK: - Delegate Handler
    @objc private func tappedView() {
        guard let _ = self.viewsShown else {return}
        
        if viewsShown.count > 1 {
              delegatePager?.didSelectViewInIndexPath(index: viewsToRotate.getIndex(tappedView: viewsShown[1]))
        } else {
              delegatePager?.didSelectViewInIndexPath(index: viewsToRotate.getIndex(tappedView: viewsShown[0]))
        }
    }
    
    //MARK: - Data Source Handler
    fileprivate func setViews() {
        guard let numberOfViews = dataSourcePager?.numberOfViews() else {fatalError("Wrong number of items")}
        
        if numberOfViews > 0 {
            viewsToRotate = [UIView]()
            for i in 0..<numberOfViews {
                guard let view = dataSourcePager?.viewForItem(at: i) else { fatalError("Returning view error")}
                viewsToRotate.append(view)
            }
            self.contentSize = CGSize(width: self.contentWidth, height: self.contentHeight)
            self.contentOffset = self.secondOrigin
        } else {
            return
        }
    }
}



extension Array where Element: NSObject {
    /// Given elements of an array, the elements on both ends are connected with
    /// each other (circularl), pick any three consecutive elements with a given
    /// middle element.
    /// If there are less than three elements in the array, copy existing one(s)
    /// to generate what we want.
    /// If empty, return nil.
    func formThreeCircularlyConsecutiveElements(middle: Element) -> [Element]? {
        
        func consLastElement() -> Array? {
            return last == nil ? nil : [last!.isEqual(middle) ? middle.copy() as! Element : last!] + self
        }
        
        func appendFirstElement() -> Array? {
            return first == nil ? nil : self + [first!.isEqual(middle) ? middle.copy() as! Element : first!]
        }
        
        guard let i = index(where: { middle.isEqual($0) }) else {
            return nil
        }
        var arrayToOperate = self
        if i == startIndex {
            arrayToOperate = consLastElement()!
        }
        if i == endIndex - 1 {
            arrayToOperate = appendFirstElement()!
        }
        guard let j = arrayToOperate.index(where: { middle.isEqual($0) }) else {
            return nil
        }
        return [arrayToOperate[j.advanced(by: -1)], middle, arrayToOperate[j.advanced(by: 1)]]
    }
    
    func getIndex(tappedView: UIView) -> Int {
        guard let i = index(where: { tappedView.isEqual($0) }) else {
            return 0
        }
        return i
    }
}
