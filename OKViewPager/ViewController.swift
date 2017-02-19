//
//  ViewController.swift
//  OKViewPager
//
//  Created by Omer Karayel on 31/01/17.
//  Copyright © 2017 Omer Karayel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var viewsShown = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.yellow
        
        for i in 0..<5 {
            let aView = createView(number: i)
            viewsShown.append(aView)
        }
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        let scrollView = OKViewPager(frame: frame, viewsToRotate: viewsShown, scrollHorizontally: true)
        scrollView.center = view.center
        scrollView.delegatePager = self
        scrollView.dataSourcePager = self
        scrollView.backgroundColor = UIColor.brown
        scrollView.setMiddleView(3)
        view.addSubview(scrollView)
    }
    
    func createView(number: Int) -> UIView {
        
        let aView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
        let textView = UITextView(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 30, height: 30)))
        textView.center = aView.center
        textView.text = "\(number)"
        textView.isUserInteractionEnabled = false
        aView.addSubview(textView)
        return aView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ViewController: OKViewPagerDelegate {
    func didSelectViewInIndexPath(index: Int) {
        print(index)
    }
}
extension ViewController: OKViewPagerDataSource {
    func numberOfViews() -> Int {
        return viewsShown.count
    }
    
    func viewForItem(at index: Int) -> UIView {
        return viewsShown[index]
    }
}
