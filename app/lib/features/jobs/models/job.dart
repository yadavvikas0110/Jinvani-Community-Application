class Job {
  final String id;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final String location;
  final String experience;
  final String payscale;
  final String postedAt;
  final String jobType;
  final String? description;
  final List<String> skills;
  final List<String> requirements;
  final String? aboutCompany;
  bool isSaved;
  bool isApplied;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    required this.location,
    required this.experience,
    required this.payscale,
    required this.postedAt,
    this.jobType = 'Full Time',
    this.description,
    this.skills = const [],
    this.requirements = const [],
    this.aboutCompany,
    this.isSaved = false,
    this.isApplied = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['_id'] as String,
        title: json['title'] as String,
        company: json['company'] as String,
        companyLogoUrl: json['companyLogoUrl'] as String?,
        location: json['location'] as String? ?? '',
        experience: json['experience'] as String? ?? '',
        payscale: json['payscale'] as String? ?? '',
        postedAt: json['postedAt'] as String? ?? '',
        jobType: json['jobType'] as String? ?? 'Full Time',
        description: json['description'] as String?,
        skills: List<String>.from(json['skills'] as List? ?? []),
        requirements: List<String>.from(json['requirements'] as List? ?? []),
        aboutCompany: json['aboutCompany'] as String?,
        isSaved: json['isSaved'] as bool? ?? false,
        isApplied: json['isApplied'] as bool? ?? false,
      );

  Job copyWith({bool? isSaved, bool? isApplied}) => Job(
        id: id,
        title: title,
        company: company,
        companyLogoUrl: companyLogoUrl,
        location: location,
        experience: experience,
        payscale: payscale,
        postedAt: postedAt,
        jobType: jobType,
        description: description,
        skills: skills,
        requirements: requirements,
        aboutCompany: aboutCompany,
        isSaved: isSaved ?? this.isSaved,
        isApplied: isApplied ?? this.isApplied,
      );
}

class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String? companyLogoUrl;
  final String status;
  final String appliedAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    this.companyLogoUrl,
    required this.status,
    required this.appliedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
        id: json['_id'] as String,
        jobId: json['jobId'] as String,
        jobTitle: json['jobTitle'] as String,
        company: json['company'] as String,
        companyLogoUrl: json['companyLogoUrl'] as String?,
        status: json['status'] as String? ?? 'applied',
        appliedAt: json['appliedAt'] as String? ?? '',
      );
}

class SeekerProfile {
  final String role; // 'seeker' | 'recruiter'
  final String fullName;
  final String email;
  final String location;
  final String mobile;
  final String professionalProfile;
  final String professionalSummary;
  final String workExperience;
  final String? cvUrl;
  final String? portfolio;

  const SeekerProfile({
    this.role = 'seeker',
    this.fullName = '',
    this.email = '',
    this.location = '',
    this.mobile = '',
    this.professionalProfile = '',
    this.professionalSummary = '',
    this.workExperience = 'Fresher',
    this.cvUrl,
    this.portfolio,
  });

  SeekerProfile copyWith({
    String? role,
    String? fullName,
    String? email,
    String? location,
    String? mobile,
    String? professionalProfile,
    String? professionalSummary,
    String? workExperience,
    String? cvUrl,
    String? portfolio,
  }) =>
      SeekerProfile(
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        location: location ?? this.location,
        mobile: mobile ?? this.mobile,
        professionalProfile: professionalProfile ?? this.professionalProfile,
        professionalSummary: professionalSummary ?? this.professionalSummary,
        workExperience: workExperience ?? this.workExperience,
        cvUrl: cvUrl ?? this.cvUrl,
        portfolio: portfolio ?? this.portfolio,
      );
}
