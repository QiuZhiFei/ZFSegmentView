//
//  ZFSlideSegmentView.swift
//  SlideVC
//
//  Created by zhifei on 16/8/22.
//  Copyright © 2016年 Atelas. All rights reserved.
//

import Foundation
import UIKit

private let animationDuration: TimeInterval = 0.3

struct ZFSegmentConfig {
  var normalAttributedText: NSMutableAttributedString?
  var selectedAttributedText: NSMutableAttributedString?
  var indicatorColor: UIColor = UIColor.green
  var indicatorBottom: CGFloat = 2
  var indicatorHeight: CGFloat = 0.5
}

class ZFSegmentView: UIView {
  
  var didSelectHandler: ((_ oldIndex: Int, _ newIndex: Int)->())?
  var startIndex: Int = 0 {
    didSet {
      selectedIndex = startIndex
    }
  }
  var selectedIndex: Int = 0 {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  init(frame: CGRect, contentEdge: UIEdgeInsets, configs: [ZFSegmentConfig]) {
    super.init(frame: frame)
    
    self.contentEdge = contentEdge
    self.configs = configs
    itemCount = configs.count
    
    addSubview(contentView)
    addSubview(indicatorView)
    
    let label = UILabel(frame: .zero)
    for config in configs {
      label.attributedText = config.normalAttributedText
      normalSizes.append(CGSize(width: label.intrinsicContentSize.width, height: CGFloat(FLT_MAX)))
      label.attributedText = config.selectedAttributedText
      selectedSizes.append(CGSize(width: label.intrinsicContentSize.width, height: CGFloat(FLT_MAX)))
      
      let segmentLabel = ZFSegmentLabel(frame: .zero)
      segmentLabel.configure(config: config)
      contentView.addSubview(segmentLabel)
      segmentlabels.append(segmentLabel)
      
      segmentLabel.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(ZFSegmentView.tapSelected(ges:)))
      segmentLabel.addGestureRecognizer(tap)
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: Override
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = CGRect(x: contentEdge.left, y: contentEdge.top, width: bounds.size.width - contentEdge.left - contentEdge.right, height: bounds.size.height - contentEdge.top - contentEdge.bottom)
    
    var itemWidth: CGFloat = 0 // 总宽度
    var displayLabelSizes: [CGSize] = []
    for index in 0...itemCount-1 {
      var size: CGSize = .zero
      if index == selectedIndex {
        size = selectedSizes[index]
      } else {
        size = normalSizes[index]
      }
      displayLabelSizes.append(size)
      itemWidth = itemWidth + size.width
    }
    var itemSpace: CGFloat = 0 // 间距
    if itemCount > 1 {
      itemSpace = (contentView.bounds.width - itemWidth)/CGFloat(itemCount - 1)
    }
    
    var segmentLabelFrames: [CGRect] = []
    var previousFrame: CGRect?
    for index in 0...(itemCount - 1) {
      var origin_x: CGFloat = 0
      if let previousFrame = previousFrame  {
        origin_x = previousFrame.origin.x + previousFrame.size.width + itemSpace
      }
      let origin_y: CGFloat = 0
      let origin_bottom: CGFloat = origin_y
      let width = displayLabelSizes[index].width
      let height = contentView.bounds.size.height - origin_y - origin_bottom
      let frame = CGRect(x: origin_x, y: origin_y, width: width, height: height)
      segmentLabelFrames.append(frame)
      previousFrame = frame
    }
    
    let selectedLabelFrame = segmentLabelFrames[selectedIndex]
    let selectedConfig = configs[selectedIndex]
    
    func resetSegmentLabels() {
      for (index, label) in self.segmentlabels.enumerated() {
        label.selected = index == self.selectedIndex
        label.frame = segmentLabelFrames[index]
      }
    }
    
    let indicatorViewFrame = CGRect(x: selectedLabelFrame.origin.x + self.contentView.frame.origin.x, y: self.bounds.size.height - selectedConfig.indicatorBottom - selectedConfig.indicatorHeight, width: selectedLabelFrame.size.width, height: selectedConfig.indicatorHeight)
    if self.indicatorView.frame.size.height == 0 {
      self.indicatorView.frame = indicatorViewFrame
      self.indicatorView.backgroundColor = selectedConfig.indicatorColor
      resetSegmentLabels()
    } else {
      UIView.animate(withDuration: animationDuration,
                     animations: {
                      self.indicatorView.frame = indicatorViewFrame
                      self.indicatorView.backgroundColor = selectedConfig.indicatorColor
        }, completion: { (finished) in
          resetSegmentLabels()
      })
    }
  }
  
  //MARK: Private Methods
  
  fileprivate var contentEdge: UIEdgeInsets = UIEdgeInsets.zero
  fileprivate var itemCount = 0
  fileprivate var normalSizes: [CGSize] = []
  fileprivate var selectedSizes: [CGSize] = []
  fileprivate var segmentlabels: [ZFSegmentLabel] = []
  fileprivate var configs: [ZFSegmentConfig] = []
  
  @objc private func tapSelected(ges: UITapGestureRecognizer) {
    if let gesView = ges.view {
      let label = gesView as! ZFSegmentLabel
      let oldIndex = selectedIndex
      selectedIndex = segmentlabels.index(of: label)!
      if let handler = didSelectHandler {
        handler(oldIndex, selectedIndex)
      }
    }
  }
  
  fileprivate lazy var contentView: UIView = {
    let view = UIView(frame: CGRect.zero)
    view.backgroundColor = UIColor.clear
    return view
  }()
  
  fileprivate lazy var indicatorView: UIView = {
    let view = UIView(frame: CGRect.zero)
    return view
  }()
  
}

class ZFSegmentLabel: UILabel {
  
  var selected: Bool = false {
    didSet {
      resetAttri()
    }
  }
  var config: ZFSegmentConfig?
  
  func configure(config: ZFSegmentConfig) {
    self.config = config
    resetAttri()
  }
  
  //MARK: Private Methods
  
  private func resetAttri() {
    if let config = config {
      attributedText = selected ? config.selectedAttributedText : config.normalAttributedText
    }
  }
  
}
