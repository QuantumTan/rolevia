import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/location_service.dart';
import 'fixtures.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

void main() {
  group('Haversine distance calculations', () {
    test('calculates correct distance between Taguig and Makati', () {
      // Taguig BGC: 14.5547, 121.0244
      // Makati: 14.5583, 121.0183
      final distance = computeHaversineDistanceKm(14.5547, 121.0244, 14.5583, 121.0183);
      expect(distance, greaterThan(0.5));
      expect(distance, lessThan(3.0));
    });

    test('calculates correct distance between Manila and Cebu', () {
      // Manila: 14.5995, 120.9842
      // Cebu: 10.3297, 123.9063
      final distance = computeHaversineDistanceKm(14.5995, 120.9842, 10.3297, 123.9063);
      expect(distance, greaterThan(500.0));
      expect(distance, lessThan(650.0));
    });

    test('identical coordinates return 0.0 distance', () {
      final distance = computeHaversineDistanceKm(14.5547, 121.0244, 14.5547, 121.0244);
      expect(distance, closeTo(0.0, 0.001));
    });
  });

  group('PhilippineHubs and hub resolver', () {
    test('resolves closest hub for coordinates near BGC as Taguig', () {
      final hub = resolveClosestHub(14.5500, 121.0300);
      expect(hub, 'Taguig / BGC');
    });

    test('resolves closest hub for coordinates in Cebu as Cebu IT Park', () {
      final hub = resolveClosestHub(10.3300, 123.9050);
      expect(hub, 'Cebu IT Park');
    });

    test('resolves closest hub for coordinates in Davao as Davao City', () {
      final hub = resolveClosestHub(7.0700, 125.6000);
      expect(hub, 'Davao City');
    });
  });

  group('Job model location and distance properties', () {
    test('distanceLabel formats meters when under 1 km', () {
      const job = Job(
        id: 'test',
        role: 'Dev',
        company: 'Corp',
        location: 'Taguig',
        mode: WorkMode.onSite,
        type: EmploymentType.fullTime,
        postedDays: 1,
        skills: [],
        overview: '',
        responsibilities: [],
        qualifications: [],
        distanceKm: 0.45,
      );
      expect(job.distanceLabel, '450m away');
    });

    test('distanceLabel formats kilometers when 1 km or greater', () {
      const job = Job(
        id: 'test',
        role: 'Dev',
        company: 'Corp',
        location: 'Taguig',
        mode: WorkMode.onSite,
        type: EmploymentType.fullTime,
        postedDays: 1,
        skills: [],
        overview: '',
        responsibilities: [],
        qualifications: [],
        distanceKm: 3.24,
      );
      expect(job.distanceLabel, '3.2km away');
    });

    test('Job json roundtrip preserves coordinates and distance', () {
      const original = Job(
        id: 'test_geo',
        role: 'Flutter Lead',
        company: 'Bayani Tech',
        location: 'Taguig',
        mode: WorkMode.hybrid,
        type: EmploymentType.fullTime,
        postedDays: 2,
        skills: ['Flutter', 'Dart'],
        overview: 'Great opportunity',
        responsibilities: ['Build apps'],
        qualifications: ['Experience'],
        latitude: 14.5547,
        longitude: 121.0244,
        distanceKm: 1.5,
      );

      final json = original.toJson();
      final restored = Job.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.distanceKm, original.distanceKm);
    });
  });

  group('Near Me proximity filtering in filterJobs', () {
    test('filters and orders jobs within 15 km when Near Me is active', () {
      const taguigLocation = UserLocation(
        latitude: 14.5547,
        longitude: 121.0244,
        label: 'Taguig / BGC',
      );

      final filtered = filterJobs(
        jobs: seedJobs,
        userLocation: taguigLocation,
        categoryFilters: {'Near Me (< 15 km)'},
      );

      // In seedJobs:
      // j2 is Taguig (distance ~0 km) -> included
      // j1 is Davao (distance ~960 km) -> excluded
      // j3 is Cebu (distance ~570 km) -> excluded
      // j4 is Remote (no lat/lon) -> excluded from strict radius
      expect(filtered.any((j) => j.id == 'j2'), isTrue);
      expect(filtered.any((j) => j.id == 'j1'), isFalse);
      expect(filtered.any((j) => j.id == 'j3'), isFalse);

      final taguigJob = filtered.firstWhere((j) => j.id == 'j2');
      expect(taguigJob.distanceKm, isNotNull);
      expect(taguigJob.distanceKm!, lessThan(1.0));
    });

    test('without Near Me filter, all jobs remain visible with distances attached', () {
      const taguigLocation = UserLocation(
        latitude: 14.5547,
        longitude: 121.0244,
        label: 'Taguig / BGC',
      );

      final allFiltered = filterJobs(
        jobs: seedJobs,
        userLocation: taguigLocation,
        categoryFilters: {},
      );

      expect(allFiltered.length, seedJobs.length);
      final taguigJob = allFiltered.firstWhere((j) => j.id == 'j2');
      final cebuJob = allFiltered.firstWhere((j) => j.id == 'j3');
      expect(taguigJob.distanceKm, lessThan(1.0));
      expect(cebuJob.distanceKm, greaterThan(500.0));
    });
  });
}
