import UIKit
import ReactiveSwift
import ReactiveCocoa

final class RAFLoginViewController: UIViewController {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = RAFLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.reactive.continuousTextValues
            .skipNil()
            .observeValues(viewModel.didChangeUsername)
        
        passwordTextField.reactive.continuousTextValues
            .skipNil()
            .observeValues(viewModel.didChangePassword)
        
        loginButton.reactive.controlEvents(.primaryActionTriggered)
            .map { _ in }
            .observeValues(viewModel.didTapSignIn)
        
        viewModel.state.producer
            .startWithValues { [weak self] in
                self?.render(state: $0)
            }
    }
    
    private func render(state: RAFLoginViewModel.State) {
        statusLabel.text = state.status
        loginButton.isEnabled = state.canLogin
        (state.isLoading ? activityIndicator.startAnimating : activityIndicator.stopAnimating)()
    }
}
