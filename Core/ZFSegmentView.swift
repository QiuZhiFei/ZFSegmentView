//
//  ZFSlideSegmentView.swift
//  SlideVC
//
//  Created by zhifei on 16/8/22.
//  Copyright © 2016年 Atelas. All rights reserved.
//

import Foundation
import UIKit

public class ZFSegmentConfig: NSObject {
  var normalAttributedText: NSMutableAttributedString?
  var selectedAttributedText: NSMutableAttributedString?
  var indicatorColor: UIColor = UIColor.green
  var indicatorBottom: CGFloat = 2
  var indicatorHeight: CGFloat = 0.5
  
  public init(normalAttributedText: NSMutableAttributedString?,
              selectedAttributedText:NSMutableAttributedString?,
              indicatorColor: UIColor = UIColor.green,
              indicatorBottom: CGFloat = 2,
              indicatorHeight: CGFloat = 0.5) {
    super.init()
    self.normalAttributedText = normalAttributedText
    self.selectedAttributedText = selectedAttributedText
    self.indicatorColor = indicatorColor
    self.indicatorBottom = indicatorBottom
    self.indicatorHeight = indicatorHeight
  }
}

@objc public enum ZFSegmentViewLayoutType: Int {
  case manual = 0
  case center
}

open class ZFSegmentView: UIView {
  
  public var didSelectHandler: ((_ oldIndex: Int, _ newIndex: Int)->())?
  public var startIndex: Int = 0 {
    didSet {
      selectedIndex = startIndex
    }
  }
  public internal(set) var selectedIndex: Int = 0 {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  public func setSelectedIndex(index: Int) {
    let oldIndex = selectedIndex
    self.selectedIndex = index
    if let handler = didSelectHandler {
      handler(oldIndex, selectedIndex)
    }
  }
  public var animationDuration: TimeInterval = 0.3
  public internal(set) var type: ZFSegmentViewLayoutType = .manual
  
  public init(frame: CGRect, contentEdge: UIEdgeInsets, configs: [ZFSegmentConfig], type: ZFSegmentViewLayoutType) {
    super.init(frame: frame)
    
    self.contentEdge = contentEdge
    self.configs = configs
    self.type = type
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
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: Override
  
  override open func layoutSubviews() {
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
      switch type {
      case .center:
        itemSpace = (contentView.bounds.width - itemWidth)/CGFloat(itemCount + 1)
      case .manual:
        itemSpace = (contentView.bounds.width - itemWidth)/CGFloat(itemCount - 1)
      }
    }
    
    var segmentLabelFrames: [CGRect] = []
    var previousFrame: CGRect?
    for index in 0...(itemCount - 1) {
      var origin_x: CGFloat = 0
      switch type {
      case .center:
        origin_x = itemSpace
      case .manual:
        origin_x = 0
      }
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
      let index = segmentlabels.index(of: label)!
      setSelectedIndex(index: index)
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

private class ZFSegmentLabel: UILabel {
  
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
