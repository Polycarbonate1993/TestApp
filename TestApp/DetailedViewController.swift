//
//  DetailedViewController.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 04.02.2021.
//

import UIKit
import Kingfisher

class DetailedViewController: UIViewController {
    weak var scrollView: UIScrollView?
    weak var contentView: UIStackView?
    weak var pictureImageView: DiamondView?
    weak var titleTextView: UITextView?
    weak var descriptionTextView: UITextView?
    var picture: Post? {
        didSet {
            /**In case there is changes in active ViewController.*/
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        bind()
    }
    /**Binding ViewModel with view(ViewController).*/
    private func bind() {
        guard let contentView = contentView, let picture = picture else {
            return
        }
        contentView.backgroundColor = .white
        contentView.subviews.forEach({$0.removeFromSuperview()})
        let stringURL = picture.urlBig != nil ? picture.urlBig! : (picture.urlMedium != nil ? picture.urlMedium! : picture.urlSmall)
        guard let url = URL(string: stringURL) else {
            return
        }
        let downloader = ImageDownloader.default
        downloader.downloadImage(with: url, completionHandler: {result in
            switch result {
            case .success(let value):
                let diamondView = DiamondView(image: value.image)
                diamondView.cRadiusMod = 3.5
                diamondView.dLengthMod = 5
                let aspectRatio = value.image.size.width / value.image.size.height
                diamondView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(diamondView.makeConstraintsTo(diamondView, constraints: [.width: (.height, UIView.ConstraintSettings(multiplier: aspectRatio))]))
                contentView.addArrangedSubview(diamondView)
                let title = UITextView(frame: .zero)
                title.isEditable = false
                title.isScrollEnabled = false
                title.attributedText = try? NSMutableAttributedString(data: picture.title.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                contentView.addArrangedSubview(title)
                let description = UITextView(frame: .zero)
                description.isEditable = false
                description.isScrollEnabled = false
                description.attributedText = try? NSMutableAttributedString(data: picture.description.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                contentView.addArrangedSubview(description)
            case .failure(let error):
                self.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again")
            }
        })
    }
    /**Initialization of the UI elements.*/
    private func setUpScrollView() {
        view.backgroundColor = .white
        let scrollView = UIScrollView(frame: view.frame)
        self.scrollView = scrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(scrollView.makeConstraintsTo(view, constraints: [
            .top: (.top, UIView.ConstraintSettings()),
            .bottom: (.bottom, UIView.ConstraintSettings()),
            .leading: (.leading, UIView.ConstraintSettings()),
            .trailing: (.trailing, UIView.ConstraintSettings())
        ]))
        let contentView = UIStackView(frame: view.frame)
        contentView.alignment = .center
        contentView.axis = .vertical
        contentView.spacing = 10
        self.contentView = contentView
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(contentView.makeConstraintsTo(scrollView, constraints: [
            .top: (.top, UIView.ConstraintSettings()),
            .bottom: (.bottom, UIView.ConstraintSettings()),
            .leading: (.leading, UIView.ConstraintSettings()),
            .trailing: (.trailing, UIView.ConstraintSettings())
        ]))
        NSLayoutConstraint.activate(contentView.makeConstraintsTo(view, constraints: [.width: (.width, UIView.ConstraintSettings())]))
    }
}
