import AuthenticationClient
import ComposableArchitecture
import TwoFactorCore
import XCTest

class TwoFactorCoreTests: XCTestCase {
  func testFlow_Success() {
    let store = TestStore(
      initialState: TwoFactorState(token: "deadbeefdeadbeef"),
      reducer: twoFactorReducer,
      environment: TwoFactorEnvironment(
        authenticationClient: .failing,
        mainQueue: .immediate
      )
    )

    store.environment.authenticationClient.twoFactor = { _ in
      Effect(value: .init(token: "deadbeefdeadbeef", twoFactorRequired: false))
    }
    store.send(.codeChanged("1")) {
      $0.code = "1"
    }
    store.send(.codeChanged("12")) {
      $0.code = "12"
    }
    store.send(.codeChanged("123")) {
      $0.code = "123"
    }
    store.send(.codeChanged("1234")) {
      $0.code = "1234"
      $0.isFormValid = true
    }
    store.send(.submitButtonTapped) {
      $0.isTwoFactorRequestInFlight = true
    }
    store.receive(/TwoFactorAction.twoFactorResponse) {
      $0.isTwoFactorRequestInFlight = false
    }
  }

  func testFlow_Failure() {
    let store = TestStore(
      initialState: TwoFactorState(token: "deadbeefdeadbeef"),
      reducer: twoFactorReducer,
      environment: TwoFactorEnvironment(
        authenticationClient: .failing,
        mainQueue: .immediate
      )
    )

    store.environment.authenticationClient.twoFactor = { _ in
      Effect(error: AuthenticationError.invalidTwoFactor)
    }

    store.send(.codeChanged("1234")) {
      $0.code = "1234"
      $0.isFormValid = true
    }
    store.send(.submitButtonTapped) {
      $0.isTwoFactorRequestInFlight = true
    }
    store.receive(/TwoFactorAction.twoFactorResponse) {
      $0.alert = .init(
        title: TextState(AuthenticationError.invalidTwoFactor.localizedDescription)
      )
      $0.isTwoFactorRequestInFlight = false
    }
    store.send(.alert(.dismiss)) {
      $0.alert = nil
    }
  }
}
