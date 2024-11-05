#ifndef FLUTTER_PLUGIN_COZY_DATA_PLUGIN_H_
#define FLUTTER_PLUGIN_COZY_DATA_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace cozy_data {

class CozyDataPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CozyDataPlugin();

  virtual ~CozyDataPlugin();

  // Disallow copy and assign.
  CozyDataPlugin(const CozyDataPlugin&) = delete;
  CozyDataPlugin& operator=(const CozyDataPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace cozy_data

#endif  // FLUTTER_PLUGIN_COZY_DATA_PLUGIN_H_
