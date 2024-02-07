//
//  RoktWebView.swift
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

import UIKit
import WebKit

protocol RoktWebViewCallback {
    func onWebViewClosed()
}

class RoktWebView: UIViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webviewPlaceholder: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var secureURLImage: UIImageView!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    private var webView: WKWebView!
    private var callback: RoktWebViewCallback?
    
    private let backgroundColor = [0: "#ffffff", 1: "#575757"]
    private let contentColor = [0: "#121212", 1: "#ffffff"]
    private let grayColor = [0: "#8C8C8C", 1: "#BFBFBF"]
    private var progressObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    private var isExternalBrowserOpened = false
    private var viewModel: WebViewViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        webView.load(URLRequest(url: viewModel.url))
        titleLabel.text = kLoadingText
    }
    
    private func setupWebView() {
        setupColors()
        webView = WKWebView(frame: webviewPlaceholder.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webviewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webviewPlaceholder.addSubview(webView)
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.webviewPlaceholder.topAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.webviewPlaceholder.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.webviewPlaceholder.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.webviewPlaceholder.bottomAnchor)
        ])
        webView.layoutIfNeeded()
        addProgressbar()
        addTitleBar()
    }
    
    private func setupColors() {
        view.backgroundColor = UIColor(colorMap: backgroundColor, self.traitCollection)
        titleLabel.textColor = UIColor(colorMap: contentColor, self.traitCollection)
        hostLabel.textColor = UIColor(colorMap: grayColor, self.traitCollection)
        closeButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        menuButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        backButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        forwardButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        shareButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        backButton.imageView?.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
    }
    
    class func openWebView(_ viewController: UIViewController, url: URL,
                           sessionId: String, campaignId: String? = nil,
                           callback: RoktWebViewCallback? = nil) {
        let podBundle = Bundle(for: Rokt.self)
        
        let bundleURL = podBundle.url(forResource: kBundleName, withExtension: kBundleExtension)
        let bundle = Bundle(url: bundleURL!)
        let board = UIStoryboard.init(name: kStoryboardName, bundle: bundle)
        
        if let roktWebView = board.instantiateViewController(withIdentifier: kRoktWebViewIdentifier)
            as? RoktWebView {
            roktWebView.viewModel = WebViewViewModel(url: url,
                                                     sessionId: sessionId,
                                                     campaignId: campaignId,
                                                     lastUrl: "")
            roktWebView.callback = callback
            viewController.present(roktWebView, animated: true)
        }
    }
    
    @IBAction func closeWebView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func reloadWebview(_ sender: Any) {
        webView.reload()
    }
    @IBAction func goBack(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func goForward(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @IBAction func shareWebsite(_ sender: Any) {
        if let link = webView.url {
            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) {
            alert.view.tintColor = .label
        } else {
            alert.view.tintColor = UIColor(colorMap: contentColor, self.traitCollection)
        }

        alert.addAction(UIAlertAction(title: "Open in Browser", style: .default, handler: {_ in
            if let url = self.webView.url {
                self.openExternalBrowser(url: url)
            }
        }))

        alert.addAction(UIAlertAction(title: "Copy Link", style: .default, handler: {_ in
            if let url = self.webView.url {
                UIPasteboard.general.string = url.absoluteString
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true)
    }
    
    private func openExternalBrowser(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func isAppActive() -> Bool {
        return UIApplication.shared.applicationState == .active
    }
    
    private func setDomain(label: UILabel, hasDefault: Bool = false) {
        if let url = webView.url {
            secureURLImage.isHidden = !url.absoluteString.hasPrefix(kHttpsPrefix)
            if let hostName = url.host {
                label.text = hostName
            }
        } else if hasDefault {
            label.text = ""
        }
    }
    
    // MARK: title bar
    private func addTitleBar() {
        titleObservation = webView.observe(\.title, options: [.new]) { _, _ in
            if self.isAppActive() {
                self.titleLabel.text = self.webView.title ?? ""
            }
        }
    }
    
    // MARK: progress bar
    private func addProgressbar() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            if self.isAppActive() {
                self.progressView.progress = Float(self.webView.estimatedProgress)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // reset progress bar for each navigation
        if isAppActive() {
            self.progressView.progress = 0.1
            self.progressView.alpha = 1.0
            setDomain(label: hostLabel)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url ,
           !viewModel.isSupportedUrl(url.absoluteString) {
            openExternalBrowser(url: url)
            isExternalBrowserOpened = true
            decisionHandler(.cancel)
        } else {
            isExternalBrowserOpened = false
            viewModel.lastUrl = navigationAction.request.url?.absoluteString ?? ""
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onNavivationEnded()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        if isExternalBrowserOpened {
            dismiss(animated: true)
        } else {
            onNavivationEnded()
            showErrorPage()
            viewModel.sendWebViewDiagnostics(webView.url, error: error)
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if isAppActive() {
            progressView.alpha = 0.0
        }
    }
    
    func onNavivationEnded() {
        if isAppActive() {
            progressView.alpha = 0.0
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
            setDomain(label: hostLabel)
            if titleLabel.text == kLoadingText { // page with no title
                setDomain(label: titleLabel, hasDefault: true)
            }
        }
    }
    
    func showErrorPage() {
        webView.loadHTMLString(kHtmlError, baseURL: viewModel.url)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        callback?.onWebViewClosed()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false &&
                (UIApplication.shared.applicationState == .inactive ||
                    UIApplication.shared.applicationState == .active) {
                setupColors()
            }
        }
    }
    
    deinit {
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.removeObserver(self, forKeyPath: "title")
        }
        progressObservation = nil
        titleObservation = nil
    }
}
