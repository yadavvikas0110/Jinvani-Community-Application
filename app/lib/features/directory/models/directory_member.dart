class DirectoryMember {
  final String id;
  final String name;
  final String category; // professionals | business_owners | leaders_financiers | community_services
  final String title;
  final String? company;
  final String city;
  final String? about;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final List<String> tags;

  const DirectoryMember({
    required this.id,
    required this.name,
    required this.category,
    required this.title,
    this.company,
    required this.city,
    this.about,
    this.phone,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.tags = const [],
  });
}

const directoryCategories = [
  DirectoryCategory(id: 'professionals',       label: 'Professionals',        icon: 'work'),
  DirectoryCategory(id: 'business_owners',     label: 'Business Owners',      icon: 'store'),
  DirectoryCategory(id: 'leaders_financiers',  label: 'Leaders / Financiers', icon: 'account_balance'),
  DirectoryCategory(id: 'community_services',  label: 'Community Services',   icon: 'volunteer_activism'),
];

class DirectoryCategory {
  final String id;
  final String label;
  final String icon;
  const DirectoryCategory({required this.id, required this.label, required this.icon});
}

// Filter tags per category
const professionalFilterTags   = ['Lawyer', 'Accountant', 'Finance & Taxation', 'Doctor', 'Engineer'];
const businessFilterTags       = ['Retail', 'Manufacturing', 'Import / Export', 'Real Estate', 'Technology'];
const leaderFilterTags         = ['Investor', 'Philanthropist', 'NGO', 'Politician', 'Religious Leader'];
const communityFilterTags      = ['Healthcare', 'Education', 'Food Relief', 'Cultural', 'Sports'];
