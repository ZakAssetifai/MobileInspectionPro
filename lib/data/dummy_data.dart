import 'models.dart';

/// Single source of truth for the dummy data shown in the demo UI.
/// Replace this file with real API calls once integrated.
class DummyData {
  DummyData._();

  static final List<Asset> assets = [
    const Asset(
      id: 'BR-RUH-001',
      name: 'King Fahd Causeway Approach',
      kind: AssetKind.bridge,
      region: 'Eastern Province',
      city: 'Al Khobar',
      yearBuilt: 1986,
      length: 245,
      material: 'Reinforced concrete',
      lat: 26.2354,
      lng: 50.1971,
      documents: [
        'BR-RUH-001_general-arrangement.pdf',
        'BR-RUH-001_structural-details.pdf',
      ],
    ),
    const Asset(
      id: 'BR-ABH-005',
      name: 'Asir Highland Viaduct',
      kind: AssetKind.bridge,
      region: 'Asir',
      city: 'Abha',
      yearBuilt: 2002,
      length: 410,
      material: 'Pre-stressed concrete',
      lat: 18.2164,
      lng: 42.5053,
    ),
    const Asset(
      id: 'BR-JIZ-006',
      name: 'Jazan Causeway',
      kind: AssetKind.bridge,
      region: 'Jazan',
      city: 'Jazan',
      yearBuilt: 1998,
      length: 320,
      material: 'Reinforced concrete',
      lat: 16.8892,
      lng: 42.5511,
    ),
    const Asset(
      id: 'BR-NAJ-013',
      name: 'Najran Wadi Crossing',
      kind: AssetKind.bridge,
      region: 'Najran',
      city: 'Najran',
      yearBuilt: 2010,
      length: 165,
      material: 'Reinforced concrete',
      lat: 17.4924,
      lng: 44.1277,
    ),
    const Asset(
      id: 'BR-DAM-018',
      name: 'Dammam Port Access Bridge',
      kind: AssetKind.bridge,
      region: 'Eastern Province',
      city: 'Dammam',
      yearBuilt: 1992,
      length: 280,
      material: 'Steel-concrete composite',
      lat: 26.4282,
      lng: 50.1031,
    ),
    const Asset(
      id: 'CV-RUH-101',
      name: 'Wadi Namar Box Culvert',
      kind: AssetKind.culvert,
      region: 'Riyadh',
      city: 'South',
      yearBuilt: 2006,
      length: 18,
      material: 'Reinforced concrete',
      lat: 24.580,
      lng: 46.620,
      documents: [
        'CV-RUH-101_general-arrangement.pdf',
        'CV-RUH-101_structural-details.pdf',
      ],
    ),
    const Asset(
      id: 'CV-TAB-318',
      name: 'Tabuk Drainage Culvert',
      kind: AssetKind.culvert,
      region: 'Tabuk',
      city: 'Tabuk',
      yearBuilt: 2014,
      length: 22,
      material: 'Reinforced concrete',
      lat: 28.3998,
      lng: 36.5700,
    ),
    const Asset(
      id: 'CV-YAN-145',
      name: 'Yanbu Industrial Culvert',
      kind: AssetKind.culvert,
      region: 'Madinah',
      city: 'Yanbu',
      yearBuilt: 2009,
      length: 14,
      material: 'Reinforced concrete',
      lat: 24.0890,
      lng: 38.0618,
    ),
  ];

  static List<InspectionElement> defaultElements() => [
        InspectionElement(
          code: 'Deck',
          name: 'Deck',
          description: 'Riding surface, wearing course, drainage',
          defectTypes: const [
            'Concrete Cracking',
            'Spalling',
            'Corrosion / Rust Staining',
            'Pothole',
            'Water Damage',
          ],
        ),
        InspectionElement(
          code: 'Superstructure',
          name: 'Superstructure',
          description: 'Girders, beams, trusses',
          defectTypes: const [
            'Corrosion',
            'Cracking',
            'Section loss',
            'Connection failure',
          ],
        ),
        InspectionElement(
          code: 'Substructure',
          name: 'Substructure',
          description: 'Piers, abutments, foundations',
          defectTypes: const ['Scour', 'Settlement', 'Cracking'],
        ),
        InspectionElement(
          code: 'Bearings',
          name: 'Bearings',
          description: 'Elastomeric, pot, roller bearings',
          defectTypes: const ['Tear', 'Misalignment', 'Loss of bearing'],
        ),
        InspectionElement(
          code: 'Expansion Joints',
          name: 'Expansion Joints',
          description: 'Strip seal, finger, modular',
          defectTypes: const ['Seal failure', 'Debris', 'Misalignment'],
        ),
        InspectionElement(
          code: 'Parapets & Railings',
          name: 'Parapets & Railings',
          description: 'Crash barriers, railings',
          defectTypes: const ['Impact damage', 'Corrosion', 'Loose anchorage'],
        ),
      ];

  static final List<Inspection> inspections = [
    Inspection(
      id: 'INS-2026-001',
      asset: assets[2], // Jazan Causeway
      kind: InspectionKind.routine,
      status: InspectionStatus.submitted,
      elements: defaultElements()
        ..[0].rating = ConditionRating.good
        ..[1].rating = ConditionRating.excellent
        ..[2].rating = ConditionRating.good
        ..[3].rating = ConditionRating.good,
      weather: WeatherCondition.clear,
      started: DateTime(2026, 4, 28, 22, 18, 54),
      submitted: DateTime(2026, 4, 28, 22, 20, 34),
      accessRestricted: true,
      accessNotes: 'Water level',
      overallCondition: ConditionRating.good,
    ),
    Inspection(
      id: 'INS-2026-002',
      asset: assets[0], // King Fahd
      kind: InspectionKind.routine,
      status: InspectionStatus.submitted,
      elements: defaultElements(),
      started: DateTime(2026, 4, 28, 14, 02, 00),
      submitted: DateTime(2026, 4, 28, 14, 30, 00),
      overallCondition: ConditionRating.good,
    ),
    Inspection(
      id: 'INS-2026-003',
      asset: assets[0],
      kind: InspectionKind.routine,
      status: InspectionStatus.draft,
      elements: defaultElements(),
      started: DateTime(2026, 4, 28, 9, 0, 0),
    ),
    Inspection(
      id: 'INS-2026-004',
      asset: assets[1],
      kind: InspectionKind.routine,
      status: InspectionStatus.submitted,
      elements: defaultElements(),
      started: DateTime(2026, 4, 27, 11, 12, 0),
      submitted: DateTime(2026, 4, 27, 11, 50, 0),
      overallCondition: ConditionRating.good,
    ),
    Inspection(
      id: 'INS-2026-005',
      asset: assets[1],
      kind: InspectionKind.routine,
      status: InspectionStatus.submitted,
      elements: defaultElements(),
      started: DateTime(2026, 4, 26, 9, 30, 0),
      submitted: DateTime(2026, 4, 26, 10, 5, 0),
      overallCondition: ConditionRating.fair,
      criticalFindings: 1,
    ),
    Inspection(
      id: 'INS-2026-006',
      asset: assets[5], // Wadi Namar
      kind: InspectionKind.routine,
      status: InspectionStatus.draft,
      elements: defaultElements(),
      started: DateTime(2026, 4, 28, 22, 18, 24),
    ),
    Inspection(
      id: 'INS-2026-007',
      asset: assets[4], // Dammam Port
      kind: InspectionKind.routine,
      status: InspectionStatus.submitted,
      elements: defaultElements()
        ..[0].rating = ConditionRating.good
        ..[1].rating = ConditionRating.good
        ..[4].rating = ConditionRating.good
        ..[5].rating = ConditionRating.good,
      weather: WeatherCondition.cloudy,
      started: DateTime(2026, 4, 28, 8, 0),
      submitted: DateTime(2026, 4, 28, 8, 45),
      overallCondition: ConditionRating.poor,
      criticalFindings: 1,
    ),
    Inspection(
      id: 'INS-2026-008',
      asset: assets[3], // Najran
      kind: InspectionKind.detailed,
      status: InspectionStatus.submitted,
      elements: defaultElements()
        ..[0].rating = ConditionRating.good,
      started: DateTime(2026, 4, 28, 22, 21, 55),
      submitted: DateTime(2026, 4, 28, 22, 23, 06),
      overallCondition: ConditionRating.good,
    ),
  ];

  static int get draftsCount =>
      inspections.where((i) => i.status == InspectionStatus.draft).length;
  static int get assignedCount => 5;
  static int get pendingSyncCount =>
      inspections.where((i) => i.status == InspectionStatus.submitted).length;
  static int get syncedCount =>
      inspections.where((i) => i.status == InspectionStatus.synced).length;
  static int get criticalCount =>
      inspections.fold(0, (s, i) => s + i.criticalFindings);
}
