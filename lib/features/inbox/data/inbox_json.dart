import '../../../core/network/json.dart';
import '../domain/entities/inbox_item.dart';

/// Reads the inbox answers.
abstract final class InboxJson {
  static InboxPage pageOf(JsonMap json) {
    final next = _text(json['nextPageToken']);

    return InboxPage(
      items: [
        if (json['notifications'] case final List<dynamic> items)
          for (final item in items)
            if (item is Map) itemOf(decodeJsonObject(item)),
      ],
      unread: amountAt(json, 'unreadCount') ?? 0,
      next: next.isEmpty ? null : next,
    );
  }

  static InboxItem itemOf(JsonMap json) => InboxItem(
        id: requiredText(json, 'id'),
        eventKey: _text(json['eventKey']),
        title: _text(json['title']),
        body: _text(json['body']),
        at: DateTime.tryParse(_text(json['createdAt'])) ?? DateTime.fromMillisecondsSinceEpoch(0),
        read: json['read'] == true,
        data: <String, String>{
          if (json['data'] case final Map<dynamic, dynamic> data)
            for (final entry in data.entries) '${entry.key}': '${entry.value}',
        },
      );

  static String _text(Object? value) => value is String ? value.trim() : '';
}
