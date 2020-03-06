//
//  NewsDetailViewController.swift
//  News
//
//  Created by kimjunseong on 2020/03/03.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

protocol NewsDetailViewControllerDelegate : class {
    func getNewsItems() -> [Article]?
}

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var detailScroll: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var pageNavigationView: UIView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var previousArrowButton: UIButton!
    @IBOutlet weak var nextArrowButton: UIButton!
    @IBOutlet weak var buttonGroupView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    enum RollPageView: Int {
        case first = 0
        case second
        case third
    }
    
    //rolling View
    @IBOutlet weak var pageView1: NewsDetailView!
    @IBOutlet weak var pageView2: NewsDetailView!
    @IBOutlet weak var pageView3: NewsDetailView!
    
    weak var delegate: NewsDetailViewControllerDelegate?

    private var textViewScrolling = false
    private var currentNewsIndex = 0
    private var currentPageIndex = 0
    private var originOffset: CGPoint!
    private var pageViewArray: [NewsDetailView] = []
    private var rollingCount = 3    //default
    
    private var newsItems = [Article](){
        didSet {
            rollingCount = (newsItems.count > 3) ? 3 : newsItems.count
        }
    }
    
    //REMARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupControls()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let items = delegate?.getNewsItems() else {
            return
        }
        newsItems = items
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        detailScroll.contentOffset = CGPoint(x: detailScroll.frame.size.width * CGFloat(currentRollPage().rawValue), y: 0)
        originOffset = detailScroll.contentOffset
        
        setPageView()
    }
        
    override func viewDidLayoutSubviews() {
        
        let contentWidth = detailScroll.bounds.width * CGFloat(rollingCount)
        
        contentView.frame = CGRect(x: 0, y: 0,
                                   width: contentWidth,
                                   height: detailScroll.bounds.height)
        
        detailScroll.contentSize = CGSize(width: contentWidth,
                                          height: detailScroll.bounds.height)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK: - Private
extension NewsDetailViewController {
    
    private func currentRollPage() -> RollPageView {
        
        if rollingCount == 2 {
            return (currentNewsIndex == 0) ? RollPageView.first :
            (currentNewsIndex == (newsItems.count - 1)) ? RollPageView.second : RollPageView.first
        }else if rollingCount == 1 {
            return RollPageView.first
        }
        
        return (currentNewsIndex == 0) ? RollPageView.first :
            (currentNewsIndex == (newsItems.count - 1)) ? RollPageView.third : RollPageView.second
    }
    
    // 각각의 뷰 컨텐츠를 재설정
    private func setPageView() {
        
        for v in pageViewArray {
            v.clearView()
        }
        
        let page = currentRollPage()
        let newsView = pageViewArray[page.rawValue]
         
        let model = newsItems[currentNewsIndex]
        newsView.configureView(model)
        
        pageLabel.text = "\(currentNewsIndex + 1)/\(newsItems.count)"
        
        //앞뒤 데이타를 설정
        switch page {
            case RollPageView.first:
            let nextNewsView = pageViewArray[RollPageView.second.rawValue]
            if (currentNewsIndex + 1) < newsItems.count {
                nextNewsView.configureView(newsItems[currentNewsIndex + 1])
            }
        case RollPageView.second:
            let nextNewsView = pageViewArray[RollPageView.third.rawValue]
            if (currentNewsIndex + 1) < newsItems.count {
                nextNewsView.configureView(newsItems[currentNewsIndex + 1])
            }
            let previousNewsView = pageViewArray[RollPageView.first.rawValue]
            if (currentNewsIndex - 1) > 0 {
                previousNewsView.configureView(newsItems[currentNewsIndex - 1])
            }
        case RollPageView.third:
            let previousNewsView = pageViewArray[RollPageView.first.rawValue]
            if (currentNewsIndex - 1) > 0 {
                previousNewsView.configureView(newsItems[currentNewsIndex - 1])
            }
        }
        
        previousArrowButton.isHidden = (currentNewsIndex == 0)
        nextArrowButton.isHidden = (currentNewsIndex == (newsItems.count - 1))
        
        self.newsItems[self.currentNewsIndex] = model
    }
    
    private func setupControls() {
        
        pageViewArray.append(pageView1)
        pageViewArray.append(pageView2)
        pageViewArray.append(pageView3)

        pageLabel.text = ""
    }
}

//MARK: - Actions
extension NewsDetailViewController {
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previousButtonTouched(_ sender: Any) {
        
        if currentNewsIndex > 0 {
            currentNewsIndex = currentNewsIndex - 1

            let point = CGPoint(x: detailScroll.bounds.width * CGFloat(currentRollPage().rawValue), y: 0)
            detailScroll.setContentOffset(point, animated: false)
            
            //page가 바뀔때 뷰를 다시 설정
            setPageView()
        }
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        
        if currentNewsIndex < (newsItems.count - 1) {
            currentNewsIndex = currentNewsIndex + 1

            let point = CGPoint(x: detailScroll.bounds.width * CGFloat(currentRollPage().rawValue), y: 0)
            detailScroll.setContentOffset(point, animated: false)
            
            //page가 바뀔때 뷰를 다시 설정
            setPageView()
        }
    }
}

//MARK: - UIScrollViewDelegate
extension NewsDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // 좌우로 스와이프할때의 처리를위해 초기값 임시저장
        self.originOffset = scrollView.contentOffset;
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        var rolling = false
        if originOffset.x > scrollView.contentOffset.x {
            //왼쪽 스와이프
            if currentNewsIndex > 0 {
                currentNewsIndex = currentNewsIndex - 1
                rolling = true
            }
            
        } else if originOffset.x < scrollView.contentOffset.x {
            //오른쪽 스와이프
            if currentNewsIndex < (newsItems.count - 1) {
                currentNewsIndex = currentNewsIndex + 1
                rolling = true
            }
        }
        
        if rolling {
            // scrollView의 스크롤을 중앙으로 돌림
            let point = CGPoint(x: scrollView.bounds.width * CGFloat(currentRollPage().rawValue), y: 0)
            scrollView.setContentOffset(point, animated: false)
            // page가 바뀌면 다시 설정
            setPageView()
        }
    }
}
