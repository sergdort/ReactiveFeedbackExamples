import RxCocoa
import RxSwift

final class RxLoginViewModel {
    struct Input {
        let username: Signal<String>
        let password: Signal<String>
        let loginTap: Signal<Void>
    }
    
    struct Output {
        let loginButtonEnabled: Driver<Bool>
        let statusText: Driver<String>
        let loading: Driver<Bool>
    }
    
    private let loginService = LogInService()
    
    func transform(input: Input) -> Output {
        let loginInProgress = BehaviorRelay<Bool>(value: false)
        
        let loadingStatus = loginInProgress.asDriver()
            .filter { $0 }
            .map { _ in
                return "Loading..."
            }
        
        let userNameAndPassword = Signal
            .zip(
                input.loginTap.withLatestFrom(input.username),
                input.loginTap.withLatestFrom(input.password)
            ) { username, password in
                return (username: username, password: password)
            }
        
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
        
        let loginEnabled = Driver
            .combineLatest(
                loginInProgress.asDriver(),
                input.username.asDriver(onErrorJustReturn: ""),
                input.password.asDriver(onErrorJustReturn: ""),
                resultSelector: { (isLogginIn, username, password) -> Bool in
                    !isLogginIn && !username.isEmpty && !password.isEmpty
                }
            )
            .startWith(false)
        
        return Output(
            loginButtonEnabled: loginEnabled,
            statusText: Driver.merge(loadingStatus, authStatus),
            loading: loginInProgress.asDriver()
        )
    }
}
