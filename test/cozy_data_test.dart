import 'package:flutter_test/flutter_test.dart';
import 'package:cozy_data/cozy_data.dart';
import 'package:cozy_data/cozy_data_platform_interface.dart';
import 'package:cozy_data/cozy_data_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCozyDataPlatform
    with MockPlatformInterfaceMixin
    implements CozyDataPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CozyDataPlatform initialPlatform = CozyDataPlatform.instance;

  test('$MethodChannelCozyData is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCozyData>());
  });

  test('getPlatformVersion', () async {
    CozyData cozyDataPlugin = CozyData();
    MockCozyDataPlatform fakePlatform = MockCozyDataPlatform();
    CozyDataPlatform.instance = fakePlatform;

    expect(await cozyDataPlugin.getPlatformVersion(), '42');
  });
}
