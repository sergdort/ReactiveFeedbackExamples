import Loop
import ReactiveSwift

open class BaseLoopViewModel<State, Event> {
  private let loop: FeedbackLoop<State, Event>
  private let input = FeedbackLoop<State, Event>.Feedback.input

  open var state: SignalProducer<State, Never> {
    return loop.producer.observe(on: UIScheduler())
  }

  public init(initial: State, reduce: @escaping (inout State, Event) -> Void, feedbacks: [FeedbackLoop<State, Event>.Feedback]) {
    self.loop = FeedbackLoop(
      initial: initial,
      reduce: reduce,
      feedbacks: feedbacks + [input.feedback]
    )
  }

  open func send(event: Event) {
    input.observer(event)
  }

  open func didLoad() {
    loop.start()
  }
}
