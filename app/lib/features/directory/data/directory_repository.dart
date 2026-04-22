import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/directory_member.dart';

class DirectoryRepository {
  static final _members = <DirectoryMember>[
    // ── Professionals ────────────────────────────────────────────────────────
    DirectoryMember(
      id: 'p1', name: 'Rajesh Shah', category: 'professionals',
      title: 'Chartered Accountant', company: 'Shah & Associates',
      city: 'Mumbai', isVerified: true,
      about: 'Experienced CA with 15+ years in taxation, audit, and financial advisory. Specialising in Jain community businesses.',
      phone: '+91 98200 11234', email: 'rajesh.shah@example.com',
      tags: ['Accountant', 'Finance & Taxation'],
    ),
    DirectoryMember(
      id: 'p2', name: 'Priya Shah', category: 'professionals',
      title: 'Corporate Lawyer', company: 'Mehta Legal LLP',
      city: 'Delhi', isVerified: true,
      about: 'Corporate law specialist with expertise in mergers, acquisitions, and commercial contracts.',
      phone: '+91 98100 55678', email: 'priya.shah@example.com',
      tags: ['Lawyer'],
    ),
    DirectoryMember(
      id: 'p3', name: 'Aarti Jain', category: 'professionals',
      title: 'Financial Advisor', company: 'Wealth First',
      city: 'Ahmedabad', isVerified: false,
      about: 'Certified financial planner helping families build wealth and plan for retirement.',
      phone: '+91 98790 22345', email: 'aarti.jain@example.com',
      tags: ['Finance & Taxation', 'Accountant'],
    ),
    DirectoryMember(
      id: 'p4', name: 'Kunal Mehta', category: 'professionals',
      title: 'Tax Consultant', company: 'KM Tax Solutions',
      city: 'Surat', isVerified: true,
      about: 'GST and income tax specialist. 10+ years helping businesses stay compliant and tax-efficient.',
      phone: '+91 99090 33456', email: 'kunal.mehta@example.com',
      tags: ['Accountant', 'Finance & Taxation'],
    ),
    DirectoryMember(
      id: 'p5', name: 'Neha Oswal', category: 'professionals',
      title: 'Doctor (MBBS, MD)', company: 'City Hospital',
      city: 'Pune', isVerified: true,
      about: 'Practising physician with specialisation in internal medicine. Community health camp organiser.',
      phone: '+91 98500 44567', email: 'neha.oswal@example.com',
      tags: ['Doctor'],
    ),
    DirectoryMember(
      id: 'p6', name: 'Vikram Kothari', category: 'professionals',
      title: 'Software Engineer', company: 'TechMinds Pvt Ltd',
      city: 'Bangalore', isVerified: false,
      about: 'Full-stack developer specialising in fintech and enterprise solutions.',
      phone: '+91 98440 55678', email: 'vikram.kothari@example.com',
      tags: ['Engineer'],
    ),

    // ── Business Owners ──────────────────────────────────────────────────────
    DirectoryMember(
      id: 'b1', name: 'Sunita Kothari', category: 'business_owners',
      title: 'Business Owner', company: 'Kothari Jewellers',
      city: 'Jaipur', isVerified: true,
      about: 'Third generation jewellery business. Specialising in traditional Rajasthani gold jewellery and wedding collections.',
      phone: '+91 98290 66789', email: 'sunita@kotharijewellers.com',
      tags: ['Retail'],
    ),
    DirectoryMember(
      id: 'b2', name: 'Anand Jain', category: 'business_owners',
      title: 'Managing Director', company: 'Jain Textiles Exports',
      city: 'Surat', isVerified: true,
      about: 'Leading textile export house with 25 years of experience. Exporting to 30+ countries.',
      phone: '+91 99250 77890', email: 'anand@jaintextiles.com',
      tags: ['Import / Export', 'Manufacturing'],
    ),
    DirectoryMember(
      id: 'b3', name: 'Meena Shah', category: 'business_owners',
      title: 'Founder & CEO', company: 'GreenLeaf Foods',
      city: 'Mumbai', isVerified: false,
      about: 'Pure vegetarian organic food brand. Champion of Jain-compliant, sustainable food practices.',
      phone: '+91 98200 88901', email: 'meena@greenleaffoods.com',
      tags: ['Retail', 'Manufacturing'],
    ),
    DirectoryMember(
      id: 'b4', name: 'Rakesh Lodha', category: 'business_owners',
      title: 'Real Estate Developer', company: 'Lodha Realty',
      city: 'Mumbai', isVerified: true,
      about: 'Residential and commercial real estate developer. 500+ projects delivered across Maharashtra.',
      phone: '+91 98210 99012', email: 'rakesh@lodharealty.com',
      tags: ['Real Estate'],
    ),
    DirectoryMember(
      id: 'b5', name: 'Pooja Bhatia', category: 'business_owners',
      title: 'Co-founder', company: 'DigiSpark Technologies',
      city: 'Bangalore', isVerified: false,
      about: 'Tech startup founder focused on AI-driven analytics for SME businesses.',
      phone: '+91 98440 00123', email: 'pooja@digispark.tech',
      tags: ['Technology'],
    ),

    // ── Leaders / Financiers ─────────────────────────────────────────────────
    DirectoryMember(
      id: 'l1', name: 'Dr. Mahendra Lodha', category: 'leaders_financiers',
      title: 'Angel Investor', company: 'Lodha Capital',
      city: 'Mumbai', isVerified: true,
      about: 'Serial entrepreneur and angel investor. Backed 40+ startups across fintech, edtech, and healthtech.',
      phone: '+91 98210 11234', email: 'dr.lodha@lodhacapital.com',
      tags: ['Investor'],
    ),
    DirectoryMember(
      id: 'l2', name: 'Kavita Sanghvi', category: 'leaders_financiers',
      title: 'Philanthropist', company: 'Sanghvi Foundation',
      city: 'Ahmedabad', isVerified: true,
      about: 'Leading the Sanghvi Foundation — funding education, healthcare, and poverty alleviation across Gujarat.',
      phone: '+91 98790 22345', email: 'kavita@sanghvifoundation.org',
      tags: ['Philanthropist', 'NGO'],
    ),
    DirectoryMember(
      id: 'l3', name: 'Ramesh Jain', category: 'leaders_financiers',
      title: 'Community President', company: 'All India Jain Federation',
      city: 'Delhi', isVerified: true,
      about: 'President of the All India Jain Federation. Working towards unity and welfare of the global Jain community.',
      phone: '+91 98100 33456', email: 'ramesh@aijf.org',
      tags: ['Religious Leader', 'NGO'],
    ),
    DirectoryMember(
      id: 'l4', name: 'Preethi Firodia', category: 'leaders_financiers',
      title: 'VC Partner', company: 'Alpha Ventures',
      city: 'Pune', isVerified: true,
      about: r'Venture capital professional with $200M+ AUM. Focus on early-stage deep tech and sustainability.',
      phone: '+91 98500 44567', email: 'preethi@alphaventures.in',
      tags: ['Investor'],
    ),

    // ── Community Services ───────────────────────────────────────────────────
    DirectoryMember(
      id: 'c1', name: 'Suresh Mehta', category: 'community_services',
      title: 'Food Bank Coordinator', company: 'Jain Seva Mandal',
      city: 'Mumbai', isVerified: true,
      about: 'Coordinating free meal distribution to 1000+ families weekly. Jai Jinendra!',
      phone: '+91 98200 55678', email: 'suresh@jainsevamandal.org',
      tags: ['Food Relief'],
    ),
    DirectoryMember(
      id: 'c2', name: 'Lata Vora', category: 'community_services',
      title: 'Education NGO Head', company: 'Vidya Daan Trust',
      city: 'Ahmedabad', isVerified: false,
      about: 'Providing free education to underprivileged children. 5000+ students supported since 2010.',
      phone: '+91 98790 66789', email: 'lata@vidyadaan.org',
      tags: ['Education'],
    ),
    DirectoryMember(
      id: 'c3', name: 'Girish Patni', category: 'community_services',
      title: 'Healthcare Volunteer', company: 'Swasthya Seva Trust',
      city: 'Jaipur', isVerified: true,
      about: 'Running free health camps in rural areas. 200+ camps conducted across Rajasthan.',
      phone: '+91 98290 77890', email: 'girish@swasthyaseva.org',
      tags: ['Healthcare'],
    ),
  ];

  Future<List<DirectoryMember>> fetchMembers({
    required String category,
    String? search,
    List<String>? tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _members.where((m) => m.category == category).toList();
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.title.toLowerCase().contains(q) ||
        (m.company?.toLowerCase().contains(q) ?? false) ||
        m.city.toLowerCase().contains(q)
      ).toList();
    }
    if (tags != null && tags.isNotEmpty) {
      list = list.where((m) => m.tags.any((t) => tags.contains(t))).toList();
    }
    return list;
  }

  Future<DirectoryMember?> fetchMemberById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final m in _members) {
      counts[m.category] = (counts[m.category] ?? 0) + 1;
    }
    return counts;
  }

  List<DirectoryMember> getFeaturedMembers({int limit = 6}) {
    return _members.where((m) => m.isVerified).take(limit).toList();
  }
}

final directoryRepositoryProvider = Provider<DirectoryRepository>((_) => DirectoryRepository());
