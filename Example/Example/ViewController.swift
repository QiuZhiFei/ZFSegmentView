//
//  ViewController.swift
//  Example
//
//  Created by zhifei on 16/11/25.
//  Copyright © 2016年 Atelas. All rights reserved.
//

import UIKit
import ZFSegmentView

private let zf_geenColor = UIColor(colorLiteralRed: 82/255.0, green: 179/255.0, blue: 114/255.0, alpha: 1)
private let zf_redColor = UIColor.red

private let indicatorHeight: CGFloat = 1
private let indicatorBottom: CGFloat = 2
private let indicatorColor = zf_geenColor
private let segmentFont = UIFont.systemFont(ofSize: 14)
private let normalAttri = [
  NSFontAttributeName: segmentFont,
  NSForegroundColorAttributeName: UIColor.black]
private let greenAttri = [
  NSFontAttributeName: segmentFont,
  NSForegroundColorAttributeName: zf_geenColor]
private let redAttri = [
  NSFontAttributeName: segmentFont,
  NSForegroundColorAttributeName: zf_redColor]

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBG() //ignore
    
    setupConstantSegmentView()
    setupVariableSegmentView()
    
    let button = UIButton(type: .system)
    button.setTitle("reset startIndex", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.frame = CGRect(x: 30, y: 300, width: 200, height: 40)
    button.addTarget(self, action: #selector(self.updateSelectedIndex), for: .touchUpInside)
    view.addSubview(button)
    
    let updateButton = UIButton(type: .system)
    updateButton.setTitle("update configs", for: .normal)
    updateButton.setTitleColor(UIColor.black, for: .normal)
    updateButton.frame = CGRect(x: 30, y: 360, width: 200, height: 40)
    updateButton.addTarget(self, action: #selector(self.updateConfigs), for: .touchUpInside)
    view.addSubview(updateButton)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  //MARK: Private Methods
  
  private var constantSegmentView: ZFSegmentView!
  private var variableSegmentView: ZFSegmentView!
  
  @objc private func updateSelectedIndex() {
    constantSegmentView.setSelectedIndex(index: constantSegmentView.startIndex)
    variableSegmentView.setSelectedIndex(index: variableSegmentView.startIndex)
  }
  
  @objc private func updateConfigs() {
    var configs = constantSegmentView.configs
    configs.remove(at: 0)
    constantSegmentView.configure(configs: configs)
  }
  
  private func setupConstantSegmentView() {
    let configs = [ZFSegmentConfig(
      normalAttributedText: NSMutableAttributedString(string: "Song", attributes: normalAttri),
      selectedAttributedText: NSMutableAttributedString(string: "Song", attributes: greenAttri),
      indicatorColor: indicatorColor,
      indicatorBottom: indicatorBottom,
      indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Songlist", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "Songlist", attributes: greenAttri),
                    indicatorColor: indicatorColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Album", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "Album", attributes: redAttri),
                    indicatorColor: zf_redColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Artist", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "Artist", attributes: greenAttri),
                    indicatorColor: indicatorColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight)]
    
    let segmentView = ZFSegmentView(frame: .zero,
                                    contentEdge: .zero,
                                    configs: configs,
                                    type: .center)
    segmentView.backgroundColor = UIColor.white
    segmentView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: 40)
    segmentView.contentLabelFramesChangedHandler = {
      (frames) in
      print("label frames == \(frames)")
    }
    segmentView.startIndex = 1
    segmentView.didSelectHandler = {
      (oldIndex, newIndex) in
      print("old == \(oldIndex)")
      if oldIndex != newIndex {
        print("new == \(newIndex)")
      }
    }
    self.view.addSubview(segmentView)
    constantSegmentView = segmentView
  }
  
  private func setupVariableSegmentView() {
    let configs = [ZFSegmentConfig(
      normalAttributedText: NSMutableAttributedString(string: "Song", attributes: normalAttri),
      selectedAttributedText: NSMutableAttributedString(string: "- Song -", attributes: greenAttri),
      indicatorColor: indicatorColor,
      indicatorBottom: indicatorBottom,
      indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Songlist", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "- Songlist -", attributes: greenAttri),
                    indicatorColor: indicatorColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Album", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "- Album -", attributes: redAttri),
                    indicatorColor: zf_redColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight),
                   ZFSegmentConfig(
                    normalAttributedText: NSMutableAttributedString(string: "Artist", attributes: normalAttri),
                    selectedAttributedText: NSMutableAttributedString(string: "- Artist -", attributes: greenAttri),
                    indicatorColor: indicatorColor,
                    indicatorBottom: indicatorBottom,
                    indicatorHeight: indicatorHeight)]
    
    let segmentView = ZFSegmentView(frame: .zero,
                                        contentEdge: UIEdgeInsetsMake(0, 10, 0, 0), configs: configs,
                                        type: .manual)
    segmentView.backgroundColor = UIColor.white
    segmentView.frame = CGRect(x: 20, y: 164, width: self.view.bounds.size.width - 40, height: 40)
    segmentView.animationDuration = 0.2
    segmentView.startIndex = 3
    segmentView.didSelectHandler = {
      (oldIndex, newIndex) in
      print("old == \(oldIndex)")
      if oldIndex != newIndex {
        print("new == \(newIndex)")
      }
    }
    self.view.addSubview(segmentView)
    variableSegmentView = segmentView
  }
  
  private func setupBG() {
    let imageView = UIImageView(frame: view.bounds)
    imageView.image = UIImage(named: "1.jpg")
    imageView.contentMode = .scaleAspectFill
    view.addSubview(imageView)
    
    let bar = UIToolbar(frame: view.bounds)
    view.addSubview(bar)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

