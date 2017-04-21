// #docregion
@Tags(const ['aot'])
@TestOn('browser')

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular_test/angular_test.dart';
import 'package:angular_tour_of_heroes/app_component.dart';
import 'package:angular_tour_of_heroes/dashboard_component.dart';
import 'package:angular_tour_of_heroes/hero_service.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'dashboard_po.dart';

NgTestFixture<DashboardComponent> fixture;
DashboardPO po;

final MockPlatformLocation mockPlatformLocation = new MockPlatformLocation();

class MockPlatformLocation extends Mock implements PlatformLocation {}

@AngularEntrypoint()
void main() {
  final providers = new List.from(ROUTER_PROVIDERS)
    ..addAll([
      provide(APP_BASE_HREF, useValue: '/'),
      provide(ROUTER_PRIMARY_COMPONENT, useValue: AppComponent),
      provide(PlatformLocation, useValue: mockPlatformLocation),
      HeroService,
    ]);
  final testBed = new NgTestBed<DashboardComponent>().addProviders(providers);

  setUpAll(() async {
    when(mockPlatformLocation.pathname).thenReturn('');
    when(mockPlatformLocation.search).thenReturn('');
    when(mockPlatformLocation.hash).thenReturn('');
    when(mockPlatformLocation.getBaseHrefFromDOM()).thenReturn('');
  });

  setUp(() async {
    fixture = await testBed.create();
    po = await fixture.resolvePageObject(DashboardPO);
  });

  tearDown(disposeAnyRunningTest);

  test('title', () async {
    expect(await po.title, 'Top Heroes');
  });

  test('top heroes', () async {
    final expectedNames = ['Narco', 'Bombasto', 'Celeritas', 'Magneta'];
    expect(await po.heroNames.toList(), expectedNames);
  });

  test('select hero and navigate to detail', () async {
    clearInteractions(mockPlatformLocation);
    await po.clickHero(3);
    final vr = verify(mockPlatformLocation.pushState(any, any, captureAny));
    expect(vr.captured.single, '/detail/15');
  });
}
