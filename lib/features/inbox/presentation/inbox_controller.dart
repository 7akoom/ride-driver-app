import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/inbox_item.dart';
import '../inbox_providers.dart';

final inboxControllerProvider = NotifierProvider.autoDispose<InboxController, InboxState>(InboxController.new);

final class InboxState {
  const InboxState({this.items = const [], this.unread = 0, this.next, this.loading = true, this.failure});

  final List<InboxItem> items;
  final int unread;
  final String? next;
  final bool loading;
  final Failure? failure;

  bool get hasMore => next != null;

  InboxState copyWith({List<InboxItem>? items, int? unread}) =>
      InboxState(items: items ?? this.items, unread: unread ?? this.unread, next: next, loading: loading, failure: failure);
}

/// The inbox a page at a time, and marking messages read (at once on the screen; the
/// backend is told in the background, and the next read says how it really stands).
class InboxController extends AutoDisposeNotifier<InboxState> {
  bool _busy = false;

  @override
  InboxState build() {
    unawaited(Future.microtask(_load));

    return const InboxState();
  }

  Future<void> _load([String? page]) async {
    if (_busy) {
      return;
    }

    _busy = true;
    final result = await ref.read(loadInboxProvider).call(page);
    _busy = false;

    if (page != null && page != state.next) {
      return;
    }

    state = switch (result) {
      Ok(:final value) => InboxState(
          items: page == null ? value.items : [...state.items, ...value.items],
          unread: value.unread,
          next: value.next,
          loading: false,
        ),
      Err(:final failure) =>
        InboxState(items: state.items, unread: state.unread, next: state.next, loading: false, failure: failure),
    };
  }

  void more() {
    if (state.hasMore && state.failure == null && !_busy) {
      unawaited(_load(state.next));
    }
  }

  void retry() {
    state = InboxState(items: state.items, unread: state.unread, next: state.next);
    unawaited(_load(state.next));
  }

  Future<void> refresh() async {
    _busy = false;
    state = InboxState(items: state.items, unread: state.unread, loading: false);
    await _load();
  }

  void markRead(InboxItem item) {
    if (item.read) {
      return;
    }

    state = state.copyWith(
      items: [for (final it in state.items) it.id == item.id ? it.asRead() : it],
      unread: state.unread > 0 ? state.unread - 1 : 0,
    );
    unawaited(ref.read(markInboxReadProvider).call([item.id]));
  }

  void markAllRead() {
    state = state.copyWith(items: [for (final it in state.items) it.asRead()], unread: 0);
    unawaited(ref.read(markInboxReadProvider).call());
  }
}
