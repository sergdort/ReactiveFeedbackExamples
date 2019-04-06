import UIKit
import RxSwift
import RxCocoa

final class RxLoginViewController: UIViewController {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let viewModel = RxLoginViewModel()
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        let input = RxLoginViewModel.Input(
            username: usernameTextField.rx.text.orEmpty.changed.asSignal(),
            password: passwordTextField.rx.text.orEmpty.changed.asSignal(),
            loginTap: loginButton.rx.tap.asSignal()
        )
        let output = viewModel.transform(input: input)
        
        output.loading.drive(activityIndicator.rx.isAnimating).disposed(by: disposeBag)
        output.loginButtonEnabled.drive(loginButton.rx.isEnabled).disposed(by: disposeBag)
        output.statusText.drive(statusLabel.rx.text).disposed(by: disposeBag)
    }
}
