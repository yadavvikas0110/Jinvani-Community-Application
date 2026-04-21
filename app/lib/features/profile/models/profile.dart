class PersonalDetails {
  final String? fullName;
  final int? age;
  final String? gender;
  final String? birthLocation;
  final String? currentLocation;
  final String? preference;

  const PersonalDetails({
    this.fullName,
    this.age,
    this.gender,
    this.birthLocation,
    this.currentLocation,
    this.preference,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic>? j) => PersonalDetails(
        fullName: j?['fullName'] as String?,
        age: (j?['age'] as num?)?.toInt(),
        gender: j?['gender'] as String?,
        birthLocation: j?['birthLocation'] as String?,
        currentLocation: j?['currentLocation'] as String?,
        preference: j?['preference'] as String?,
      );
}

class EducationEntry {
  final String id;
  final String type; // degree | schooling | certification
  final String? degreeName;
  final String? specialization;
  final String? collegeName;
  final String? percentage;
  final String? schoolName;
  final String? stream;
  final String? boardName;
  final String? location;
  final String? achievements;
  final String? certificateUrl;
  final String? certificateName;
  final String? certificateDescription;

  const EducationEntry({
    required this.id,
    required this.type,
    this.degreeName,
    this.specialization,
    this.collegeName,
    this.percentage,
    this.schoolName,
    this.stream,
    this.boardName,
    this.location,
    this.achievements,
    this.certificateUrl,
    this.certificateName,
    this.certificateDescription,
  });

  factory EducationEntry.fromJson(Map<String, dynamic> j) => EducationEntry(
        id: (j['_id'] ?? j['id']).toString(),
        type: j['type'] as String,
        degreeName: j['degreeName'] as String?,
        specialization: j['specialization'] as String?,
        collegeName: j['collegeName'] as String?,
        percentage: j['percentage'] as String?,
        schoolName: j['schoolName'] as String?,
        stream: j['stream'] as String?,
        boardName: j['boardName'] as String?,
        location: j['location'] as String?,
        achievements: j['achievements'] as String?,
        certificateUrl: j['certificateUrl'] as String?,
        certificateName: j['certificateName'] as String?,
        certificateDescription: j['certificateDescription'] as String?,
      );

  String get displayTitle {
    switch (type) {
      case 'degree':
        return degreeName ?? 'Degree';
      case 'schooling':
        return schoolName ?? 'School';
      case 'certification':
        return certificateName ?? 'Certificate';
    }
    return type;
  }

  String get displaySubtitle {
    switch (type) {
      case 'degree':
        return [specialization, collegeName].where((e) => e != null && e.isNotEmpty).join(' • ');
      case 'schooling':
        return [stream, boardName].where((e) => e != null && e.isNotEmpty).join(' • ');
      case 'certification':
        return certificateDescription ?? '';
    }
    return '';
  }
}

class WorkDetails {
  final String? jobType;
  final String? companyName;
  final String? companyType;
  final String? jobRole;
  final int? yearsOfExperience;
  final String? jobLocation;
  final String? roleDescription;

  const WorkDetails({
    this.jobType,
    this.companyName,
    this.companyType,
    this.jobRole,
    this.yearsOfExperience,
    this.jobLocation,
    this.roleDescription,
  });

  factory WorkDetails.fromJson(Map<String, dynamic>? j) => WorkDetails(
        jobType: j?['jobType'] as String?,
        companyName: j?['companyName'] as String?,
        companyType: j?['companyType'] as String?,
        jobRole: j?['jobRole'] as String?,
        yearsOfExperience: (j?['yearsOfExperience'] as num?)?.toInt(),
        jobLocation: j?['jobLocation'] as String?,
        roleDescription: j?['roleDescription'] as String?,
      );
}

class FinancialInfo {
  final String? sourceOfIncome;
  final String? jobStatus;
  final double? currentSavings;

  const FinancialInfo({this.sourceOfIncome, this.jobStatus, this.currentSavings});

  factory FinancialInfo.fromJson(Map<String, dynamic>? j) => FinancialInfo(
        sourceOfIncome: j?['sourceOfIncome'] as String?,
        jobStatus: j?['jobStatus'] as String?,
        currentSavings: (j?['currentSavings'] as num?)?.toDouble(),
      );
}

class FutureGoal {
  final String? goal;
  final String? description;
  const FutureGoal({this.goal, this.description});
  factory FutureGoal.fromJson(Map<String, dynamic>? j) =>
      FutureGoal(goal: j?['goal'] as String?, description: j?['description'] as String?);
}

class InvestmentPortfolio {
  final String? type;
  final double? currentValue;
  final String? notes;
  const InvestmentPortfolio({this.type, this.currentValue, this.notes});
  factory InvestmentPortfolio.fromJson(Map<String, dynamic>? j) => InvestmentPortfolio(
        type: j?['type'] as String?,
        currentValue: (j?['currentValue'] as num?)?.toDouble(),
        notes: j?['notes'] as String?,
      );
}

class EconomicData {
  final FinancialInfo financialInfo;
  final FutureGoal futureGoals;
  final InvestmentPortfolio investmentPortfolio;

  const EconomicData({
    this.financialInfo = const FinancialInfo(),
    this.futureGoals = const FutureGoal(),
    this.investmentPortfolio = const InvestmentPortfolio(),
  });

  factory EconomicData.fromJson(Map<String, dynamic>? j) => EconomicData(
        financialInfo: FinancialInfo.fromJson(j?['financialInfo'] as Map<String, dynamic>?),
        futureGoals: FutureGoal.fromJson(j?['futureGoals'] as Map<String, dynamic>?),
        investmentPortfolio:
            InvestmentPortfolio.fromJson(j?['investmentPortfolio'] as Map<String, dynamic>?),
      );
}

class Bio {
  final String? avatarUrl;
  final String? briefIntroduction;
  const Bio({this.avatarUrl, this.briefIntroduction});
  factory Bio.fromJson(Map<String, dynamic>? j) =>
      Bio(avatarUrl: j?['avatarUrl'] as String?, briefIntroduction: j?['briefIntroduction'] as String?);
}

class Profile {
  final String id;
  final PersonalDetails personalDetails;
  final List<EducationEntry> education;
  final WorkDetails workDetails;
  final EconomicData economicData;
  final Bio bio;
  final List<String> goals;
  final int completion;

  const Profile({
    required this.id,
    required this.personalDetails,
    required this.education,
    required this.workDetails,
    required this.economicData,
    required this.bio,
    required this.goals,
    required this.completion,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: (j['id'] ?? j['_id']).toString(),
        personalDetails:
            PersonalDetails.fromJson(j['personalDetails'] as Map<String, dynamic>?),
        education: ((j['education'] ?? const []) as List)
            .map((e) => EducationEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        workDetails: WorkDetails.fromJson(j['workDetails'] as Map<String, dynamic>?),
        economicData: EconomicData.fromJson(j['economicData'] as Map<String, dynamic>?),
        bio: Bio.fromJson(j['bio'] as Map<String, dynamic>?),
        goals: ((j['goals'] ?? const []) as List).map((e) => e.toString()).toList(),
        completion: (j['completion'] as num?)?.toInt() ?? 0,
      );
}
