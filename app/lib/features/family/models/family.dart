const kRelations = <String, String>{
  'father': 'Father',
  'mother': 'Mother',
  'brother': 'Brother',
  'sister': 'Sister',
  'son': 'Son',
  'daughter': 'Daughter',
  'spouse': 'Spouse',
  'uncle': 'Uncle',
  'aunt': 'Aunt',
  'cousin': 'Cousin',
  'grandfather': 'Grandfather',
  'grandmother': 'Grandmother',
  'other': 'Other',
};

String relationLabel(String key) => kRelations[key] ?? key;

class FamilyMember {
  final String id;
  final String? relativeUserId;
  final String relation;
  final String displayName;
  final String? displayAvatar;
  final String? phone;
  final String? email;

  const FamilyMember({
    required this.id,
    required this.relation,
    required this.displayName,
    this.relativeUserId,
    this.displayAvatar,
    this.phone,
    this.email,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> j) => FamilyMember(
        id: (j['id'] ?? j['_id']).toString(),
        relativeUserId: j['relativeUserId']?.toString(),
        relation: j['relation'] as String,
        displayName: j['displayName'] as String,
        displayAvatar: j['displayAvatar'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
      );
}

class InvitationSender {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? city;
  const InvitationSender({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.city,
  });

  factory InvitationSender.fromJson(Map<String, dynamic> j) => InvitationSender(
        id: j['id'].toString(),
        name: j['name'] as String,
        avatarUrl: j['avatarUrl'] as String?,
        city: j['city'] as String?,
      );
}

class FamilyInvitation {
  final String id;
  final String senderId;
  final String? receiverUserId;
  final String relation;
  final String proposedName;
  final String? phone;
  final String? email;
  final String channel; // in_app | external
  final String status; // pending | accepted | rejected | cancelled
  final InvitationSender? sender;

  const FamilyInvitation({
    required this.id,
    required this.senderId,
    required this.relation,
    required this.proposedName,
    required this.channel,
    required this.status,
    this.receiverUserId,
    this.phone,
    this.email,
    this.sender,
  });

  factory FamilyInvitation.fromJson(Map<String, dynamic> j) => FamilyInvitation(
        id: (j['id'] ?? j['_id']).toString(),
        senderId: j['senderId'].toString(),
        receiverUserId: j['receiverUserId']?.toString(),
        relation: j['relation'] as String,
        proposedName: j['proposedName'] as String,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        channel: j['channel'] as String? ?? 'in_app',
        status: j['status'] as String? ?? 'pending',
        sender: j['sender'] is Map<String, dynamic>
            ? InvitationSender.fromJson(j['sender'] as Map<String, dynamic>)
            : null,
      );
}

class FamilySnapshot {
  final List<FamilyMember> members;
  final List<FamilyInvitation> pendingOutgoing;
  final List<FamilyInvitation> pendingIncoming;

  const FamilySnapshot({
    required this.members,
    required this.pendingOutgoing,
    required this.pendingIncoming,
  });

  factory FamilySnapshot.fromJson(Map<String, dynamic> j) => FamilySnapshot(
        members: ((j['members'] ?? const []) as List)
            .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingOutgoing: ((j['pendingOutgoing'] ?? const []) as List)
            .map((e) => FamilyInvitation.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingIncoming: ((j['pendingIncoming'] ?? const []) as List)
            .map((e) => FamilyInvitation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class InviteResult {
  final String status; // sent | user_not_registered
  final FamilyInvitation? invitation;
  final InviteProposal? proposed;

  const InviteResult({required this.status, this.invitation, this.proposed});

  factory InviteResult.fromJson(Map<String, dynamic> j) => InviteResult(
        status: j['status'] as String,
        invitation: j['invitation'] is Map<String, dynamic>
            ? FamilyInvitation.fromJson(j['invitation'] as Map<String, dynamic>)
            : null,
        proposed: j['proposed'] is Map<String, dynamic>
            ? InviteProposal.fromJson(j['proposed'] as Map<String, dynamic>)
            : null,
      );
}

class InviteProposal {
  final String name;
  final String relation;
  final String? phone;
  final String? email;
  const InviteProposal({
    required this.name,
    required this.relation,
    this.phone,
    this.email,
  });

  factory InviteProposal.fromJson(Map<String, dynamic> j) => InviteProposal(
        name: j['name'] as String,
        relation: j['relation'] as String,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
      );
}
