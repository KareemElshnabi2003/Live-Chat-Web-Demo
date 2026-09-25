class MemberEntity {
  final int? id;
  final String? username;
  final String? name;
  final String? image;
  final bool? isGuest;
  final String? memberStatus;
  final String? requestStatus;
  final int? isAdmin;

  const MemberEntity({
    this.id,
    this.username,
    this.name,
    this.image,
    this.isGuest,
    this.memberStatus,
    this.requestStatus,
    this.isAdmin,
  });

  String get displayName => (name != null && name!.isNotEmpty)
      ? name!
      : (username != null && username!.isNotEmpty ? username! : 'User');

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'username':
        return username;
      case 'name':
        return name;
      case 'image':
        return image;
      case 'is_guest':
        return isGuest;
      case 'member_status':
        return memberStatus;
      case 'request_status':
        return requestStatus;
      case 'is_admin':
        return isAdmin;
      default:
        return null;
    }
  }
}
