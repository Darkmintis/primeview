import 'package:equatable/equatable.dart';

class ChannelModel extends Equatable {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String? category;
  final String? language;
  final String? country;
  final String? group;
  final bool isActive;

  const ChannelModel({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.category,
    this.language,
    this.country,
    this.group,
    this.isActive = true,
  });

  ChannelModel copyWith({
    String? id,
    String? name,
    String? url,
    String? logo,
    String? category,
    String? language,
    String? country,
    String? group,
    bool? isActive,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      logo: logo ?? this.logo,
      category: category ?? this.category,
      language: language ?? this.language,
      country: country ?? this.country,
      group: group ?? this.group,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, url, logo, category, language, country, group, isActive];
}
