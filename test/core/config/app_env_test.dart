import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/core/config/app_env.dart';

void main() {
  const tiles = 'https://tiles.example.com';
  const pins = '/znoiggBJH+VHbPNIMUiGS/IANzoul96aYNRwo80AEc=,aq2F/ouYLqjRaCulKG52etaTzRh6nHeDtNG/e2kvTaQ=';

  test('release builds refuse plain HTTP', () {
    expect(
      AppEnv.check(apiBaseUrl: 'http://api.example.com', mapTilesUrl: tiles, isRelease: true, apiPins: pins),
      [EnvProblem.insecureApiUrl],
    );
    expect(
      AppEnv.check(
        apiBaseUrl: 'https://api.example.com',
        mapTilesUrl: 'http://tiles.example.com',
        isRelease: true,
          apiPins: pins,
      ),
      [EnvProblem.insecureTilesUrl],
    );
  });

  test('debug builds may use plain HTTP to a local backend', () {
    expect(
      AppEnv.check(apiBaseUrl: 'http://10.0.2.2:8080', mapTilesUrl: tiles, isRelease: false),
      isEmpty,
    );
  });

  test('a malformed API address is always a problem', () {
    expect(
      AppEnv.check(apiBaseUrl: 'not a url', mapTilesUrl: tiles, isRelease: false),
      [EnvProblem.invalidApiUrl],
    );
  });

  test('a correct release configuration passes', () {
    expect(
      AppEnv.check(apiBaseUrl: 'https://api.example.com', mapTilesUrl: tiles, isRelease: true, apiPins: pins),
      isEmpty,
    );
  });

  test('brand colours must be #RRGGBB', () {
    List<EnvProblem> withBrand(String brand, [String strong = '']) => AppEnv.check(
          apiBaseUrl: 'https://api.example.com',
          mapTilesUrl: tiles,
          isRelease: true,
          apiPins: pins,
          brandColor: brand,
          brandStrongColor: strong,
        );

    expect(withBrand('#1E3A8A'), isEmpty);
    expect(withBrand('1E3A8A', '#123456'), isEmpty);
    expect(withBrand('gold'), [EnvProblem.invalidBrandColor]);
    expect(withBrand('#1E3A8A', '#12'), [EnvProblem.invalidBrandColor]);
  });

  test('release builds need the server key pins, and pins must look like pins', () {
    const api = 'https://api.example.com';

    expect(
      AppEnv.check(apiBaseUrl: api, mapTilesUrl: tiles, isRelease: true),
      [EnvProblem.missingApiPins],
    );
    expect(
      AppEnv.check(apiBaseUrl: api, mapTilesUrl: tiles, isRelease: false, apiPins: 'abc'),
      [EnvProblem.invalidApiPins],
    );
    expect(AppEnv.check(apiBaseUrl: api, mapTilesUrl: tiles, isRelease: false), isEmpty);
  });
}
