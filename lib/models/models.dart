class User {
  final int? id;
  final String name;
  final String email;
  final String role; // 'student' or 'supervisor'
  final String? password;
  final String? bio;
  final String? skills;
  final String? education;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password,
    this.bio,
    this.skills,
    this.education,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'password': password,
      'bio': bio,
      'skills': skills,
      'education': education,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      password: map['password'],
      bio: map['bio'],
      skills: map['skills'],
      education: map['education'],
    );
  }
}

class Supervisor {
  final int id;
  final String name;
  final String email;
  final String department;

  Supervisor({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }

  factory Supervisor.fromMap(Map<String, dynamic> map) {
    return Supervisor(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      department: map['department'],
    );
  }
}

class Activity {
  final int? id;
  final int studentId;
  final String title;
  final String description;
  final String status; // 'Draft', 'Pending', 'Approved'
  final String date;
  final String? feedback;

  Activity({
    this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
      'feedback': feedback,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      studentId: map['student_id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      date: map['date'],
      feedback: map['feedback'],
    );
  }
}
