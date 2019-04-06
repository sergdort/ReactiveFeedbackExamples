import UIKit
import RxSwift
import RxCocoa

final class RelayLoginViewController: UIViewController {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let viewModel = RelayLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.usernameRelay)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.passwordRelay)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: viewModel.loginTapRelay)
            .disposed(by: disposeBag)
        
        viewModel.loading.drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled.drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.statusText.drive(statusLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
