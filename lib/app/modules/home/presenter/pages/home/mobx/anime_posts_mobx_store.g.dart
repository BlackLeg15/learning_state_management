// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_posts_mobx_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AnimePostsMobxStore on _AnimePostsMobxStoreBase, Store {
  final _$_stateAtom = Atom(name: '_AnimePostsMobxStoreBase._state');

  @override
  AnimePostsMobxStoreState get _state {
    _$_stateAtom.reportRead();
    return super._state;
  }

  @override
  set _state(AnimePostsMobxStoreState value) {
    _$_stateAtom.reportWrite(value, super._state, () {
      super._state = value;
    });
  }

  final _$getPostsAsyncAction =
      AsyncAction('_AnimePostsMobxStoreBase.getPosts');

  @override
  Future<void> getPosts(FetchPostsMobxParams? params) {
    return _$getPostsAsyncAction.run(() => super.getPosts(params));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
