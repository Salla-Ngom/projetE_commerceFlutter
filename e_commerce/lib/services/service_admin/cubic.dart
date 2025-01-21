import 'package:bloc/bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0); // État initial : index 0 (HomePage)

  void navigateTo(int index) {
    emit(index); // Mise à jour de l'état avec l'index sélectionné
  }
}
