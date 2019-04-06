import UIKit
import RxSwift
import RxCocoa

final class KSLoginViewController: UIViewController {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel: KSLoginViewModelType = KSLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.statusText.drive(statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.loginButtonEnabled.drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.outputs.loading.drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        usernameTextField.rx.text
            .orEmpty
            .changed.bind(onNext: viewModel.inputs.userNameTextDidChange)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .changed
            .bind(onNext: viewModel.inputs.passwordTextDidChange)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap.bind(onNext: viewModel.inputs.loginButtonPressed)
            .disposed(by: disposeBag)
    }
}
