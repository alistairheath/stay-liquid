#import <Capacitor/Capacitor.h>

CAP_PLUGIN(TabsBarPlugin, "TabsBar",
  CAP_PLUGIN_METHOD(configure, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(show, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(hide, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(select, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(setBadge, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(getSafeAreaInsets, CAPPluginReturnPromise);
)