//
//  OfferImageTitleView.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import UIKit

struct OfferImageTitleView {
    let imageView = UIImageView(frame: OfferImageTitleView.defaultFrame)
    let imageViewData: ImageViewData?
    let titleViewData: TextViewData?
    let notifySizeChanged: (() -> Void)?
    
    static let defaultFrame = CGRect(x: 0, y: 0, width: 100, height: 20)
    let defaultImageHorizontalMargin = 32
    
    func loadOfferImageTitleView(container: UIView?) {
        guard let parentView = container else { return }
        parentView.subviews.forEach({ $0.removeFromSuperview() })
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        loadTitleImageAlignment(stackView)
        loadSpacing(stackView)
        
        var imageHorizontalMargin: CGFloat = 0
        
        if isTitleAndImage() {
            
            stackView.distribution = .fill
            loadTitleImageArrangement(stackView: stackView)
            
        } else {
            // Single image, Add existing horizontal margin to the image for backward compability
            imageHorizontalMargin = 32
            loadImage(stackView: stackView)
            
        }
        
        parentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: parentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: imageHorizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -imageHorizontalMargin)
        ])
        
    }
    
    private func loadTitleImageArrangement(stackView: UIStackView) {
        switch imageViewData?.creativeTitleImageArrangment {
        case .end:
            loadImage(stackView: stackView)
            loadTitle(stackView: stackView)
        case .start:
            loadTitle(stackView: stackView)
            loadImage(stackView: stackView)
        default:
            break
        }
    }
    
    private func loadTitleImageAlignment(_ stackView: UIStackView) {
        switch imageViewData?.creativeTitleImageAlignment {
        case .top:
            stackView.alignment = .top
        case .bottom:
            stackView.alignment = .bottom
        default:
            stackView.alignment = .center
        }
    }
    
    private func loadSpacing(_ stackView: UIStackView) {
        stackView.spacing = CGFloat(imageViewData?.creativeTitleImageSpacing ?? 0)
    }
    
    func loadImage(stackView: UIStackView) {
        
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
        
        showOfferImage(image: imageViewData, offerImageView: imageView, stackView: stackView, sessionId: "")
    }
    
    private func showOfferImage(image: ImageViewData?,
                                offerImageView: UIImageView,
                                stackView: UIStackView,
                                sessionId: String) {
        // image width = 0 not to have extra space from the begining
        let imageWidth = NSLayoutConstraint(item: offerImageView,
                                            attribute: NSLayoutConstraint.Attribute.width,
                                            relatedBy: NSLayoutConstraint.Relation.equal,
                                            toItem: nil,
                                            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                            multiplier: 1, constant: 0)
        imageWidth.isActive = true
        if let image = image,
           let imageUrl = image.imageUrl,
           !imageUrl.isEmpty,
           (!image.imageHideOnDark || !offerImageView.isInDarkMode()) {
            offerImageView.loadFromLink(link: imageUrl, sessionId: sessionId,
                                        downloadImageCallBack: { isImageDownloaded, downloadedImage in
                DispatchQueue.main.async {
                    if isImageDownloaded {
                        
                        offerImageView.image = downloadedImage
                        offerImageView.layoutIfNeeded()
                        offerImageView.sizeToFit()
                        imageWidth.isActive = false
                        updateImageSize(stackView: stackView,
                                        imageView: offerImageView,
                                        size: offerImageView.frame.size)
                    } else {
                        offerImageView.removeFromSuperview()
                    }
                }
            })
        } else {
            offerImageView.removeFromSuperview()
        }
    }
    
    //calculate the size required by image
    func updateImageSize(stackView: UIStackView, imageView: UIImageView, size: CGSize) {
        let imageHeight = Float(size.height != 0 ? size.height : 1)
        let imageWidth = Float(size.width)
        var imageRatio: Float = 1
        if size.height != 0 {
            imageRatio = Float(size.width / size.height)
        }
        
        let containerMaxHeight = imageViewData?.imageMaxHeight ?? kImageOfferHeight
        let containerMaxWidth = imageViewData?.imageMaxWidth ?? getImageDefaultWidth(stackView: stackView)
        let containerRatio = containerMaxWidth / containerMaxHeight
        
        var newWidth: Float = 0
        var newHeight: Float = 0
        
        if imageWidth < containerMaxWidth && imageHeight < containerMaxHeight {
            newWidth = imageWidth
            newHeight = imageHeight
        } else if containerRatio > imageRatio {
            let scale = containerMaxHeight / imageHeight
            newWidth = scale * imageWidth
            newHeight = containerMaxHeight
            
        } else {
            let scale = containerMaxWidth / imageWidth
            newHeight = scale * imageHeight
            newWidth = containerMaxWidth
        }
        
        // do not apply defaultMaxWidth if defaultMaxWidth is nil and it is single image
        if imageViewData?.imageMaxWidth == nil && !isTitleAndImage() {
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(containerMaxHeight))
            ])
        } else {
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: CGFloat(newWidth)),
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(newHeight))
            ])
        }
        
        // add additional bottom spacing to replicate the single image design
        if !isTitleAndImage() {
            NSLayoutConstraint.activate([
                stackView.bottomAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 16),
                stackView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 0)
            ])
        }
        
        if let notifySizeChanged = notifySizeChanged {
            notifySizeChanged()
        }
    }
    
    func loadTitle(stackView: UIStackView) {
        let title = UILabel(frame: OfferImageTitleView.defaultFrame)
        title.numberOfLines = 0
        stackView.addArrangedSubview(title)
        title.set(textViewData: titleViewData)
        title.sizeToFit()
        
        title.lineBreakMode = .byWordWrapping
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.setContentHuggingPriority(.defaultHigh, for: .vertical)
        title.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    private func isTitleAndImage() -> Bool {
        return imageViewData?.creativeTitleImageArrangment != .bottom && titleViewData != nil
    }
    
    private func getImageDefaultWidth(stackView: UIStackView) -> Float {
        
        isTitleAndImage() ? 80 : Float(stackView.frame.width) - Float((defaultImageHorizontalMargin * 2))
    }
}
