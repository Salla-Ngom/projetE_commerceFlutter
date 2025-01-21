abstract class ClientState {}

class ClientInitial extends ClientState {}


class ClientPageChangedState extends ClientState {
  final int currentIndex;

  ClientPageChangedState(this.currentIndex);
}

class ClientLoggedOut extends ClientState {}
