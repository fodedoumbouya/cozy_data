#include "include/cozy_data/cozy_data_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "cozy_data_plugin.h"

void CozyDataPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  cozy_data::CozyDataPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
