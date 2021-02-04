//
//  ItemCell.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {
    var picture: Post? {
        didSet {
            bind()
        }
    }
    var pictureImageView: DiamondView?
    var titleLabel: UITextView?
    var descriptionLabel: UITextView?
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCell()
    }
    /**Initialization of the cell's UI elements.*/
    private func setUpCell() {
        backgroundColor = .clear
        setUpPictureView()
        setUpTitle()
        setUpDescription()
    }
    
    private func setUpPictureView() {
        let pictureImage = DiamondView(frame: .zero)
        pictureImage.tag = 22
        pictureImageView = pictureImage
        pictureImage.imageView = UIImageView(frame: .zero)
        pictureImage.cRadiusMod = 3.5
        pictureImage.dLengthMod = 5
        contentView.addSubview(pictureImage)
        pictureImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(pictureImage.makeConstraintsTo(self.contentView, constraints: [
            .leading: (.leading, UIView.ConstraintSettings()),
            .top: (.top, UIView.ConstraintSettings()),
            .bottom: (.bottom, UIView.ConstraintSettings())
        ]))
        NSLayoutConstraint.activate(pictureImage.makeConstraintsTo(pictureImage, constraints: [.width: (.height, UIView.ConstraintSettings())]))
    }
    
    private func setUpTitle() {
        guard let pictureView = pictureImageView else {
            return
        }
        let label = UITextView(frame: .zero)
        titleLabel = label
        label.textContainer.maximumNumberOfLines = 1
        label.textContainer.lineBreakMode = .byTruncatingTail
        label.textAlignment = .justified
        label.isEditable = false
        label.isScrollEnabled = false
        label.isUserInteractionEnabled = false
        addSubview(label)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(label.makeConstraintsTo(self.contentView, constraints: [
            .top: (.top, UIView.ConstraintSettings()),
            .trailing: (.trailing, UIView.ConstraintSettings()),
            .height: (.height, UIView.ConstraintSettings(multiplier: 0.2))
        ]))
        NSLayoutConstraint.activate(label.makeConstraintsTo(pictureView, constraints: [.leading: (.trailing, UIView.ConstraintSettings())]))
    }
    
    private func setUpDescription() {
        guard let pictureView = pictureImageView, let title = titleLabel else {
            return
        }
        let description = UITextView(frame: .zero)
        descriptionLabel = description
        description.textContainer.maximumNumberOfLines = 5
        description.textContainer.lineBreakMode = .byTruncatingTail
        description.isEditable = false
        description.isScrollEnabled = false
        description.isUserInteractionEnabled = false
        addSubview(description)
        description.backgroundColor = .clear
        description.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(description.makeConstraintsTo(self.contentView, constraints: [
            .bottom: (.bottom, UIView.ConstraintSettings()),
            .trailing: (.trailing, UIView.ConstraintSettings())
        ]))
        NSLayoutConstraint.activate(description.makeConstraintsTo(title, constraints: [.top: (.bottom, UIView.ConstraintSettings())]))
        NSLayoutConstraint.activate(description.makeConstraintsTo(pictureView, constraints: [.leading: (.trailing, UIView.ConstraintSettings())]))
    }
    /**Binding view with ViewModel.*/
    private func bind() {
        guard let picture = picture, let url = URL(string: picture.urlSmall) else {
            return
        }
        pictureImageView?.imageView?.kf.setImage(with: ImageResource(downloadURL: url, cacheKey: url.absoluteString))
        var attributedText = try? NSMutableAttributedString(data: picture.description.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        attributedText?.addAttribute(.font, value: UIFont.systemFont(ofSize: UIScreen.main.bounds.height / 100), range: NSRange(location: 0, length: attributedText!.length))
        descriptionLabel?.attributedText = picture.description.isEmpty ? NSAttributedString(string: "No description", attributes: [.font: UIFont.systemFont(ofSize: UIScreen.main.bounds.height / 100)]) : attributedText
        attributedText = try? NSMutableAttributedString(data: picture.title.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        attributedText?.addAttribute(.font, value: UIFont.systemFont(ofSize: UIScreen.main.bounds.height / 90), range: NSRange(location: 0, length: attributedText!.length))
        titleLabel?.attributedText = picture.title.isEmpty ? NSAttributedString(string: "No title", attributes: [.font: UIFont.systemFont(ofSize: UIScreen.main.bounds.height / 90)]) : attributedText
    }
}
