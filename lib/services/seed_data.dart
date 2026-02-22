import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to seed sample alumni data into Firestore.
/// Call `SeedData.seedAlumni()` once to populate your database with sample data.
/// You can run this from a button in the app or from a separate script.
class SeedData {
  static Future<void> seedAlumni() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    
    final sampleAlumni = [
      {
        'name': 'Aisha Rahman',
        'email': 'aisha.rahman@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        'bio': 'Software Engineer passionate about AI and machine learning. Building the future one algorithm at a time.',
        'graduationYear': '2020',
        'department': 'Computer Science',
        'degree': 'B.Tech Computer Science',
        'currentCompany': 'Google',
        'currentPosition': 'Software Engineer',
        'location': 'Bangalore, India',
        'phone': '+91 9876543210',
        'linkedIn': 'linkedin.com/in/aisha-rahman',
        'instagram': '@aisha_codes',
        'github': 'github.com/aisha-rahman',
        'skills': ['Python', 'TensorFlow', 'Flutter', 'Firebase', 'Docker'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mohammed Khalid',
        'email': 'mohammed.khalid@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'bio': 'Product Manager with 5+ years of experience in fintech. Passionate about creating impactful products.',
        'graduationYear': '2018',
        'department': 'Business',
        'degree': 'MBA Finance',
        'currentCompany': 'Stripe',
        'currentPosition': 'Senior Product Manager',
        'location': 'Dubai, UAE',
        'phone': '+971 50 123 4567',
        'linkedIn': 'linkedin.com/in/mohammed-khalid',
        'skills': ['Product Management', 'Agile', 'Data Analytics', 'Strategy'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sara Abdullah',
        'email': 'sara.abdullah@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        'bio': 'UX Designer creating beautiful and intuitive digital experiences.',
        'graduationYear': '2021',
        'department': 'Arts',
        'degree': 'B.Des Interaction Design',
        'currentCompany': 'Microsoft',
        'currentPosition': 'UX Designer',
        'location': 'Seattle, USA',
        'linkedIn': 'linkedin.com/in/sara-abdullah',
        'instagram': '@sara_designs',
        'skills': ['Figma', 'Adobe XD', 'User Research', 'Prototyping', 'Design Systems'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Omar Hassan',
        'email': 'omar.hassan@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        'bio': 'Data Scientist | Machine Learning enthusiast | Python developer',
        'graduationYear': '2019',
        'department': 'Computer Science',
        'degree': 'M.Tech Data Science',
        'currentCompany': 'Amazon',
        'currentPosition': 'Data Scientist',
        'location': 'London, UK',
        'linkedIn': 'linkedin.com/in/omar-hassan',
        'github': 'github.com/omar-hassan',
        'skills': ['Python', 'R', 'SQL', 'Machine Learning', 'Deep Learning', 'AWS'],
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Fatima Al-Zahra',
        'email': 'fatima.alzahra@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        'bio': 'Civil Engineer specializing in sustainable infrastructure and green building.',
        'graduationYear': '2017',
        'department': 'Engineering',
        'degree': 'B.E Civil Engineering',
        'currentCompany': 'AECOM',
        'currentPosition': 'Project Engineer',
        'location': 'Riyadh, Saudi Arabia',
        'linkedIn': 'linkedin.com/in/fatima-alzahra',
        'skills': ['AutoCAD', 'Revit', 'Project Management', 'Structural Analysis'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Ahmed Youssef',
        'email': 'ahmed.youssef@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'bio': 'Full Stack Developer | Open Source Contributor | Tech Speaker',
        'graduationYear': '2022',
        'department': 'Computer Science',
        'degree': 'B.Tech Computer Science',
        'currentCompany': 'Netflix',
        'currentPosition': 'Full Stack Developer',
        'location': 'San Francisco, USA',
        'linkedIn': 'linkedin.com/in/ahmed-youssef',
        'github': 'github.com/ahmed-youssef',
        'instagram': '@ahmed_tech',
        'skills': ['React', 'Node.js', 'TypeScript', 'GraphQL', 'MongoDB', 'AWS'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Layla Noor',
        'email': 'layla.noor@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        'bio': 'Biomedical Research Scientist working on groundbreaking cancer treatments.',
        'graduationYear': '2016',
        'department': 'Science',
        'degree': 'Ph.D Biomedical Sciences',
        'currentCompany': 'Johns Hopkins University',
        'currentPosition': 'Research Scientist',
        'location': 'Baltimore, USA',
        'linkedIn': 'linkedin.com/in/layla-noor',
        'skills': ['Research', 'Genomics', 'CRISPR', 'Data Analysis', 'Scientific Writing'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Yusuf Ali',
        'email': 'yusuf.ali@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
        'bio': 'Entrepreneur & Founder of a health-tech startup. Passionate about using technology for social good.',
        'graduationYear': '2015',
        'department': 'Business',
        'degree': 'BBA Management',
        'currentCompany': 'HealthBridge (Founder)',
        'currentPosition': 'CEO & Founder',
        'location': 'Mumbai, India',
        'linkedIn': 'linkedin.com/in/yusuf-ali',
        'instagram': '@yusuf_entrepreneur',
        'skills': ['Entrepreneurship', 'Leadership', 'Fundraising', 'Product Strategy'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Nadia Patel',
        'email': 'nadia.patel@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400',
        'bio': 'Mechanical Engineer turned Robotics Specialist. Building autonomous systems.',
        'graduationYear': '2020',
        'department': 'Engineering',
        'degree': 'M.Tech Robotics',
        'currentCompany': 'Boston Dynamics',
        'currentPosition': 'Robotics Engineer',
        'location': 'Boston, USA',
        'linkedIn': 'linkedin.com/in/nadia-patel',
        'github': 'github.com/nadia-patel',
        'skills': ['ROS', 'C++', 'Python', 'Control Systems', 'Computer Vision'],
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Zainab Hussain',
        'email': 'zainab.hussain@email.com',
        'photoUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
        'bio': 'Clinical Psychologist dedicated to mental health awareness and therapy.',
        'graduationYear': '2019',
        'department': 'Medicine',
        'degree': 'M.A Clinical Psychology',
        'currentCompany': 'Mind Wellness Center',
        'currentPosition': 'Clinical Psychologist',
        'location': 'Toronto, Canada',
        'linkedIn': 'linkedin.com/in/zainab-hussain',
        'instagram': '@zainab_mindful',
        'skills': ['CBT', 'Psychotherapy', 'Research', 'Mindfulness', 'Mental Health'],
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < sampleAlumni.length; i++) {
      final docRef = firestore.collection('alumni').doc('alumni_${i + 1}');
      batch.set(docRef, sampleAlumni[i]);
    }

    await batch.commit();
  }

  static Future<void> seedPosts() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final samplePosts = [
      {
        'authorUid': 'alumni_1',
        'authorName': 'Aisha Rahman',
        'authorPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        'content': 'Thrilled to share that I just gave a talk at Google I/O about Flutter and Firebase integration! 🚀 So grateful for the education I received that got me here. #AlumniPride',
        'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        'likes': ['alumni_2', 'alumni_3', 'alumni_4', 'alumni_6'],
        'commentCount': 12,
        'createdAt': FieldValue.serverTimestamp(),
        'authorDepartment': 'Computer Science',
        'authorGraduationYear': '2020',
      },
      {
        'authorUid': 'alumni_6',
        'authorName': 'Ahmed Youssef',
        'authorPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'content': 'Just completed my open source project that hit 1K stars on GitHub! 🌟 Amazing to see the community come together. Looking for alumni collaborators!',
        'imageUrl': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
        'likes': ['alumni_1', 'alumni_4', 'alumni_9'],
        'commentCount': 8,
        'createdAt': FieldValue.serverTimestamp(),
        'authorDepartment': 'Computer Science',
        'authorGraduationYear': '2022',
      },
      {
        'authorUid': 'alumni_8',
        'authorName': 'Yusuf Ali',
        'authorPhotoUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
        'content': 'HealthBridge just received Series A funding! 🎉 What started as a college project is now transforming healthcare access. Forever grateful to my alma mater.',
        'imageUrl': 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800',
        'likes': ['alumni_1', 'alumni_2', 'alumni_3', 'alumni_5', 'alumni_7', 'alumni_10'],
        'commentCount': 25,
        'createdAt': FieldValue.serverTimestamp(),
        'authorDepartment': 'Business',
        'authorGraduationYear': '2015',
      },
    ];

    for (int i = 0; i < samplePosts.length; i++) {
      final docRef = firestore.collection('posts').doc('post_${i + 1}');
      batch.set(docRef, samplePosts[i]);
    }

    await batch.commit();
  }

  /// Seeds all sample data
  static Future<void> seedAll() async {
    await seedAlumni();
    await seedPosts();
  }
}
