import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:smart_house_flutter/mgr/redux/action.dart';
import './app_state.dart';
import 'dart:developer' as developer;

AppState appReducer(AppState state, dynamic action) {
  var newState = state.copyWith(
    navigationState: _navReducer(state.navigationState, action),
  );

  return newState;
}

///
/// Navigation Reducer
///
final _navReducer = combineReducers<NavigationState>([
  TypedReducer<NavigationState, UpdateNavigationAction>(_updateNavigationState),
]);

NavigationState _updateNavigationState(
    NavigationState state, UpdateNavigationAction action) {
  developer.log(
      '--- NAVIGATE TO ${action.name} (${action.isPage! ? 'PAGE' : 'POPUP'}) by ${action.method!.toUpperCase()} ---');
  var history = List.from(state.history);

  switch (action.method) {
    case 'push':
      if (action.name == '/') {
        history.insert(0, action);
      } else {
        history.add(action);
      }
      break;
    case 'pop':
      if (history.isNotEmpty) {
        history.removeLast();
      }
      break;
    case 'replace':
      if (history.isNotEmpty) {
        history.removeLast();
      }

      history.add(action);
      break;
  }

  if (kDebugMode) {
    developer.log('------------HISTORY-------------');

    for (var i in history.reversed) {
      developer.log('${i.isPage ? 'page' : 'popup'} - ${i.name}');
    }

    developer.log('--------------------------------');
  }

  return state.copyWith(history: history);
}
