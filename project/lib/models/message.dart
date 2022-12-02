import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a message.
abstract class Message {
  // The id of the message.
  String messageId;

  /// The id of a foreign entity to connect to.
  String otherId;

  // The user id of the author of this message.
  String author;

  // The date on which the message was made.
  DateTime date;

  /// Creates an instce of [Message].
  Message({
    this.messageId = "",
    required this.otherId,
    required this.author,
    required DateTime? date,
  }) : date = date ?? DateTime.now();

  /// Converts a [Map] object to a [Message] object.
  static Message? fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final String messageId = data["messageId"];
    final String otherId = data["otherId"];
    final String author = data["author"];
    final DateTime date = (data['date'] as Timestamp).toDate();
    final String? imageUrl = data['imageUrl'];
    final String? text = data['text'];

    if (imageUrl != null) {
      return ImageMessage(
          messageId: messageId,
          otherId: otherId,
          author: author,
          date: date,
          imageUrl: imageUrl);
    } else if (text != null) {
      return TextMessage(
          messageId: messageId,
          otherId: otherId,
          author: author,
          date: date,
          text: text);
    } else {
      return null;
    }
  }

  /// Converts given data of [List<QueryDocumentSnapshot<Map<String, dynamic>>>]
  /// to a list of messages.
  static List<Message> fromMaps(var data) {
    List<Message> comments = [];

    for (var value in data) {
      Message? comment = fromMap(value.data());
      if (comment != null) {
        comments.add(comment);
      }
    }
    return comments;
  }

  /// Converts given [Message] to a [Map<String, dynamic>].
  static Map<String, dynamic> toMap(Message message) {
    Map<String, dynamic> map = {
      "messageId": message.messageId,
      "otherId": message.otherId,
      "author": message.author,
      "date": message.date,
    };

    if (message is TextMessage) {
      map["text"] = message.text;
    } else if (message is ImageMessage) {
      map["imageUrl"] = message.imageUrl;
    }

    return map;
  }
}

/// Message where the content is a [imageUrl].
class ImageMessage extends Message {
  /// The image url of the message.
  String imageUrl;

  /// Creates an instance of [ImageMessage], a message where the content
  /// is [imageUrl].
  ImageMessage({
    super.messageId = "",
    super.date,
    required super.otherId,
    required super.author,
    required this.imageUrl,
  });

  /// Creates an instance of [ImageMessage] from the given [Map].
  static ImageMessage? fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    final String messageId = data["messageId"];
    final String otherId = data["otherId"];
    final String author = data["author"];
    final DateTime date = (data["date"] as Timestamp).toDate();
    final String imageUrl = data["imageUrl"];

    return ImageMessage(
      messageId: messageId,
      otherId: otherId,
      author: author,
      date: date,
      imageUrl: imageUrl,
    );
  }
}

/// Message where the content is a [String].
class TextMessage extends Message {
  /// The text content (body) of the message.
  String text;

  /// Creates an instant of [TextMessage], a message where the content
  /// is a [String].
  TextMessage({
    super.messageId = "",
    super.date,
    required super.otherId,
    required super.author,
    required this.text,
  });

  /// Creates an instance of [TextMessage] from the given [Map].
  static TextMessage? fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final String messageId = data["messageId"];
    final String otherId = data["otherId"];
    final String author = data["author"];
    final DateTime date = (data["date"] as Timestamp).toDate();
    final String text = data["text"];

    return TextMessage(
      messageId: messageId,
      otherId: otherId,
      author: author,
      date: date,
      text: text,
    );
  }
}
