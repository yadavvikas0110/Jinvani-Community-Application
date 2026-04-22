import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';

// Stub data — replace with real API calls once backend endpoints are ready
final _stubJobs = [
  Job(
    id: '1',
    title: 'Account Executive',
    company: 'Mehta & Associates CA Firm',
    location: 'New Delhi, India',
    experience: '1-2 Years',
    payscale: '4.5 to 6 LPA',
    postedAt: '2 days ago',
    jobType: 'Full Time',
    description:
        'We seek a detail-oriented account executive with 2+ years of experience in client management. The ideal candidate will drive sales, build relationships, and provide top-notch service to our clients.',
    skills: [
      'Proficiency in CRM software',
      'Excellent communication skills',
      'Sales and negotiation abilities',
      'Client relationship management',
    ],
    requirements: [
      "Bachelor's degree in business or related field",
      'Proven track record in sales',
      'Strong problem-solving skills',
      'Ability to work independently',
      'Excellent presentation skills',
    ],
    aboutCompany:
        'We are currently looking for an account executive with 2 years experience and can operate our CRM product on a full time basis and can work from anywhere, aka WFA.',
  ),
  Job(
    id: '2',
    title: 'Product Manager',
    company: 'Innovate Tech Solutions',
    location: 'Bangalore, India',
    experience: '3-5 Years',
    payscale: '12 to 15 LPA',
    postedAt: '1 week ago',
    jobType: 'Full Time',
    description: 'Lead product strategy and roadmap for our flagship SaaS platform.',
    skills: ['Product roadmap planning', 'Agile/Scrum', 'Stakeholder management'],
    requirements: ["Bachelor's in CS or MBA", '3+ years product experience'],
    aboutCompany: 'Innovate Tech Solutions builds cutting-edge SaaS products for the enterprise market.',
  ),
  Job(
    id: '3',
    title: 'UI/UX Designer',
    company: 'Creative Studio',
    location: 'Mumbai, India',
    experience: '0-2 Years',
    payscale: '6 to 8 LPA',
    postedAt: '3 days ago',
    jobType: 'Full Time',
    description: 'Design beautiful and intuitive user experiences for mobile and web.',
    skills: ['Figma', 'Prototyping', 'User research'],
    requirements: ['Portfolio required', 'Degree in Design or equivalent'],
    aboutCompany: 'Creative Studio is a design-first product agency.',
  ),
  Job(
    id: '4',
    title: 'MIS Analyst',
    company: 'DataBridge Corp',
    location: 'Pune, India',
    experience: '1-3 Years',
    payscale: '5 to 7 LPA',
    postedAt: '5 days ago',
    jobType: 'Full Time',
    description: 'Manage and analyze management information systems data.',
    skills: ['Excel', 'SQL', 'Power BI'],
    requirements: ['B.Com or BCA', '1+ year experience'],
    aboutCompany: 'DataBridge Corp provides analytics solutions across industries.',
  ),
  Job(
    id: '5',
    title: 'Product Designer',
    company: 'Tech Innovations',
    location: 'San Francisco, USA',
    experience: '2-4 Years',
    payscale: '80k - 100k USD',
    postedAt: '1 week ago',
    jobType: 'Remote',
    description: 'Own end-to-end design for consumer product features.',
    skills: ['Figma', 'Design systems', 'Motion design'],
    requirements: ['Strong portfolio', '2+ years product design experience'],
    aboutCompany: 'Tech Innovations is a silicon valley startup disrupting consumer tech.',
  ),
  Job(
    id: '6',
    title: 'Interaction Designer',
    company: 'Design Co.',
    location: 'London, UK',
    experience: '4-6 Years',
    payscale: '50k - 70k GBP',
    postedAt: '2 weeks ago',
    jobType: 'Full Time',
    description: 'Define interaction patterns for complex enterprise software.',
    skills: ['Interaction design', 'Accessibility', 'Usability testing'],
    requirements: ['Senior-level portfolio', '4+ years experience'],
    aboutCompany: 'Design Co. is a London-based design consultancy.',
  ),
];

final _stubApplications = <JobApplication>[
  JobApplication(
    id: 'app1',
    jobId: '1',
    jobTitle: 'Account Executive',
    company: 'Mehta & Associates CA Firm',
    status: 'Application viewed',
    appliedAt: '2 days ago',
  ),
  JobApplication(
    id: 'app2',
    jobId: '2',
    jobTitle: 'Account Executive',
    company: 'Mehta & Associates CA Firm',
    status: 'Applied 2m ago',
    appliedAt: '2 minutes ago',
  ),
  JobApplication(
    id: 'app3',
    jobId: '3',
    jobTitle: 'Account Executive',
    company: 'Mehta & Associates CA Firm',
    status: 'Application viewed',
    appliedAt: '3 days ago',
  ),
];

class JobsRepository {
  Future<List<Job>> fetchJobs({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      return _stubJobs
          .where((j) =>
              j.title.toLowerCase().contains(q) ||
              j.company.toLowerCase().contains(q) ||
              j.location.toLowerCase().contains(q))
          .toList();
    }
    if (category != null && category != 'All') {
      return _stubJobs
          .where((j) => j.title.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
    return List.from(_stubJobs);
  }

  Future<Job> fetchJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _stubJobs.firstWhere((j) => j.id == id);
  }

  Future<List<JobApplication>> fetchApplications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_stubApplications);
  }

  Future<List<Job>> fetchSavedJobs() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _stubJobs.where((j) => j.isSaved).toList();
  }

  Future<void> toggleSave(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _stubJobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _stubJobs[idx] = _stubJobs[idx].copyWith(isSaved: !_stubJobs[idx].isSaved);
    }
  }

  Future<bool> applyToJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final idx = _stubJobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _stubJobs[idx] = _stubJobs[idx].copyWith(isApplied: true);
    }
    return true;
  }
}

final jobsRepositoryProvider = Provider<JobsRepository>((ref) => JobsRepository());
