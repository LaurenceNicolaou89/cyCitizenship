import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExamCenter extends Equatable {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String district;

  const ExamCenter({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.district,
  });

  factory ExamCenter.fromMap(Map<String, dynamic> map) {
    return ExamCenter(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      district: map['district'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'district': district,
      };

  @override
  List<Object?> get props => [name, district];
}

class ExamDateModel extends Equatable {
  final String id;
  final DateTime date;
  final DateTime registrationOpen;
  final DateTime registrationClose;
  final List<ExamCenter> centers;
  final int year;
  final String session;

  const ExamDateModel({
    required this.id,
    required this.date,
    required this.registrationOpen,
    required this.registrationClose,
    required this.centers,
    required this.year,
    required this.session,
  });

  int get daysUntilExam => date.difference(DateTime.now()).inDays;
  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return now.isAfter(registrationOpen) && now.isBefore(registrationClose);
  }

  factory ExamDateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamDateModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      registrationOpen: (data['registrationOpen'] as Timestamp).toDate(),
      registrationClose: (data['registrationClose'] as Timestamp).toDate(),
      centers: (data['centers'] as List<dynamic>?)
              ?.map((c) => ExamCenter.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      year: data['year'] ?? 0,
      session: data['session'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': Timestamp.fromDate(date),
        'registrationOpen': Timestamp.fromDate(registrationOpen),
        'registrationClose': Timestamp.fromDate(registrationClose),
        'centers': centers.map((c) => c.toMap()).toList(),
        'year': year,
        'session': session,
      };

  @override
  List<Object?> get props => [id, date, session];
}
