import RxSwift
import RxCocoa
import ReactiveSwift

protocol KSLoginViewModelInputs {
    func passwordTextDidChange(_ text: String)
    func userNameTextDidChange(_ text: String)
    func loginButtonPressed()
}

protocol KSLoginViewModelOutputs {
    var loginButtonEnabled: Driver<Bool> { get }
    var statusText: Driver<String> { get }
    var loading: Driver<Bool> { get }
}

protocol KSLoginViewModelType {
    var inputs: KSLoginViewModelInputs { get }
    var outputs: KSLoginViewModelOutputs { get }
}

final class LogInService {
    func login(username: String, password: String) -> Observable<Bool> {
        return Observable
            .just(Bool.random())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
    }
    
    func rac_login(username: String, password: String) -> SignalProducer<Bool, Never> {
        return SignalProducer(value: Bool.random())
            .delay(3, on: QueueScheduler.main)
    }
}

final class KSLoginViewModel: KSLoginViewModelType, KSLoginViewModelOutputs {
    private let passwordRelay = PublishRelay<String>()
    private let usernameRelay = PublishRelay<String>()
    private let loginTapRelay = PublishRelay<Void>()
    private let loginService = LogInService()
    
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
            .zip(loginTapRelay.asSignal().withLatestFrom(usernameRelay.asSignal()),
                 loginTapRelay.asSignal().withLatestFrom(passwordRelay.asSignal())) { (username, password) in
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
                        return $0 ? "Success" : "Unauthorized"
                    }
            }
        
        self.statusText = Driver.merge(loadingStatus, authStatus)
        
        self.loginButtonEnabled = Observable
            .combineLatest(
                loginInProgress.asObservable(),
                usernameRelay.asObservable(),
                passwordRelay.asObservable(),
                resultSelector: { (isLogginIn, username, password) -> Bool  in
                    return !isLogginIn && !username.isEmpty && !password.isEmpty
            })
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
          
        self.loading = loginInProgress.asDriver()
    }
    
    var inputs: KSLoginViewModelInputs {
        return self
    }
    var outputs: KSLoginViewModelOutputs {
        return self
    }
}

extension KSLoginViewModel: KSLoginViewModelInputs {
    func passwordTextDidChange(_ text: String) {
        passwordRelay.accept(text)
    }
    
    func userNameTextDidChange(_ text: String) {
        usernameRelay.accept(text)
    }
    
    func loginButtonPressed() {
        loginTapRelay.accept(())
    }
}

