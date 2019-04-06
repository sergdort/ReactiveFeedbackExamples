import RxCocoa
import RxSwift

final class RelayLoginViewModel {
    private let loginService = LogInService()
    
    // Input
    let passwordRelay = BehaviorRelay<String>(value: "")
    let usernameRelay = BehaviorRelay<String>(value: "")
    let loginTapRelay = PublishRelay<Void>()
    // Output
    let loginButtonEnabled: Driver<Bool>
    let statusText: Driver<String>
    let loading: Driver<Bool>
    
    init() {
        let loginInProgress = BehaviorRelay<Bool>(value: false)
        
        let loadingStatus = loginInProgress.asDriver()
            .filter { $0 }
            .map { _ in
                return "Loading..."
            }
        
        let userNameAndPassword = Signal
            .zip(
                loginTapRelay.asSignal().withLatestFrom(passwordRelay.asDriver()),
                loginTapRelay.asSignal().withLatestFrom(usernameRelay.asDriver()),
                resultSelector: { username, password in
                    (username: username, password: password)
                }
            )
        
        let authStatus = userNameAndPassword
            .flatMapLatest { [loginService] in
                return loginService.login(username: $0.username, password: $0.password)
                    .do(onSubscribed: { [loginInProgress] in
                        loginInProgress.accept(true)
                    })
                    .do(onError: { _ in
                        loginInProgress.accept(false)
                    })
                    .do(onCompleted: { [loginInProgress] in
                        loginInProgress.accept(false)
                    })
                    .asDriver(onErrorJustReturn: false)
                    .map {
                        $0 ? "Success" : "Unauthorized"
                    }
            }
        
        self.statusText = Driver.merge(loadingStatus, authStatus)
        
        self.loginButtonEnabled = Driver.combineLatest(
            loginInProgress.asDriver(),
            usernameRelay.asDriver(onErrorJustReturn: ""),
            passwordRelay.asDriver(onErrorJustReturn: "")
        ) { (isLogginIn, username, password) -> Bool in
            return !isLogginIn && !username.isEmpty && !password.isEmpty
        }
        .startWith(false)
        
        self.loading = loginInProgress.asDriver()
    }
}
