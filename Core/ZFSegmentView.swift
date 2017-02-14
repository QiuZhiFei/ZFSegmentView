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
  case same
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
  
  public var contentLabelFramesChangedHandler: (([CGRect])->())?
  public private(set) var segmentLabelFrames: [CGRect] {
    set {
      if newValue != _segmentLabelFrames {
        _segmentLabelFrames = newValue
        if let handler = contentLabelFramesChangedHandler {
          handler(_segmentLabelFrames)
        }
      }
    }
    get {
      return _segmentLabelFrames
    }
  }
  
  public private(set) var configs: [ZFSegmentConfig] = []
  public func configure(configs: [ZFSegmentConfig], needsLayout: Bool = true) {
    self.configs = configs
    itemCount = configs.count
    
    for label in segmentlabels {
      label.removeFromSuperview()
    }
    normalSizes = []
    selectedSizes = []
    segmentlabels = []
    
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
    }
    
    if needsLayout {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  public private(set) var segmentlabels: [ZFSegmentLabel] = []
  
  public init(frame: CGRect, contentEdge: UIEdgeInsets, configs: [ZFSegmentConfig], type: ZFSegmentViewLayoutType) {
    super.init(frame: frame)
    
    self.contentEdge = contentEdge
    self.type = type
    
    addSubview(contentView)
    addSubview(indicatorView)
    
    self.configure(configs: configs, needsLayout: false)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(ZFSegmentView.tapSelected(ges:)))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1
    addGestureRecognizer(tap)
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
      case .same:
        itemSpace = (contentView.bounds.width - itemWidth)/CGFloat(itemCount)
        
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
      case .same:
        origin_x = itemSpace/2.0
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
    
    func resetSegmentLabels() {
      for (index, label) in self.segmentlabels.enumerated() {
        label.selected = index == self.selectedIndex
        label.frame = segmentLabelFrames[index]
      }
    }
    
    self.segmentLabelFrames = segmentLabelFrames
    
    var tap_origin_x_s: [CGFloat] = []
    var tap_origin_x: CGFloat = 0
    var previous_tap_frame: CGRect?
    for frame in segmentLabelFrames {
      if let previous_tap_frame = previous_tap_frame {
        tap_origin_x = frame.origin.x - (frame.origin.x - previous_tap_frame.origin.x - previous_tap_frame.width)/2.0 + contentView.frame.origin.x
      }
      previous_tap_frame = frame
      tap_origin_x_s.append(tap_origin_x)
    }
    
    var tap_width_s: [CGFloat] = []
    var tap_width: CGFloat = 0
    var previous_tap_origin_x: CGFloat?
    for origin_x in tap_origin_x_s {
      if let previous_tap_origin_x = previous_tap_origin_x {
        tap_width = origin_x - previous_tap_origin_x
        tap_width_s.append(tap_width)
      }
      previous_tap_origin_x = origin_x
    }
    tap_width_s.append(self.bounds.width - (tap_origin_x_s.last ?? 0))
    
    var tapFrames: [CGRect] = []
    for (index, tap_origin_x) in tap_origin_x_s.enumerated() {
      tapFrames.append(CGRect(x: tap_origin_x, y: 0, width: tap_width_s[index], height: self.bounds.size.height))
    }
    self.tapFrames = tapFrames
    
    if selectedIndex >= 0, selectedIndex < segmentLabelFrames.count {
      let selectedLabelFrame = segmentLabelFrames[selectedIndex]
      let selectedConfig = configs[selectedIndex]
      
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
    } else {
      self.indicatorView.frame = .zero
      resetSegmentLabels()
    }
    
  }
  
  //MARK: Private Methods
  
  fileprivate var contentEdge: UIEdgeInsets = UIEdgeInsets.zero
  fileprivate var itemCount = 0
  fileprivate var normalSizes: [CGSize] = []
  fileprivate var selectedSizes: [CGSize] = []
  fileprivate var _segmentLabelFrames: [CGRect] = []
  fileprivate var tapFrames: [CGRect] = []
  
  @objc private func tapSelected(ges: UITapGestureRecognizer) {
    let point = ges.location(in: ges.view!)
    for (index, frame) in tapFrames.enumerated() {
      if frame.contains(point) {
        setSelectedIndex(index: index)
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

public class ZFSegmentLabel: UILabel {
  
  var selected: Bool = false {
    didSet {
      resetAttri()
    }
  }
  internal(set) var config: ZFSegmentConfig?
  
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
