# Stay Liquid: Native Liquid Glass for Ionic & Capacitor Applications

The introduction of Apple’s new Liquid Glass design language poses a challenge for Ionic and Capacitor developers. The native Liquid Glass components use techniques beyond the capabilities of CSS to render the effects of light from the layers behind as they pass through the element.

Stay Liquid works as a way of rendering true Native Liquid Glass components on top of Ionic’s webview. Simply call the plugin from within your Typescript or Javascript code. When an event is registered on the native component, it emits an event which is apssed back to Ionic for you to handle.

The first component available is the Tab Navigation bar, but over time we will extend this further to other components. Installation and usage instructions can be found below.

***In the meantime, Stay liquid.***

![](https://64.media.tumblr.com/2d8b0c258b8ec61704001da74fbd99e0/4b167236fab79c9f-17/s640x960/9cebc10ca65f9404f49721c864c90165006390f4.gif)

## 📦 Installation

We’re not on npm (yet) but you can still install from GitHub using npm.

```powershell
npm i https://github.com/alistairheath/stay-liquid
```

Then sync it to your Ionic or Capacitor build.

```powershell
ionic cap sync ios
```

## 🚀 Usage

In `tabs.page.ts` import the TabsBar from the stay-liquid library. You’ll also want to import some helper functions from rxjs and the router for your framework. Here we’re using Angular but similar principles could be applied to react and Vue.

```tsx
//IMPORTS
import { Device, DeviceInfo } from '@capacitor/device';
import { TabsBar } from 'stay-liquid';
import { filter, Subscription } from 'rxjs';
import { Router, NavigationEnd } from '@angular/router';
```

Then in you class add an `ionViewDidEnter()`  method that initiates the Liquid Glass TabBar if the app is running on iOS and iOS version 26+.

```tsx
  private sub?: Subscription;
  private useNativeTabs: boolean = false;
  async ionViewDidEnter() {
    const deviceInfo: DeviceInfo = await Device.getInfo();
    if (deviceInfo.platform !== 'ios') return; // keep Ionic tabs on web/android
    if (deviceInfo.iOSVersion && deviceInfo.iOSVersion >= 260000) {
      this.useNativeTabs = true;
    } else {
      return;
    }

    await TabsBar.configure({
      visible: true,
      initialId: 'home',
      items: [
        { id: 'home', title: 'Home', systemIcon: 'house' },
        { id: 'new', title: 'New', systemIcon: 'sparkles' },
        { id: 'calendar', title: 'Calendar', systemIcon: 'calendar' },
        { id: 'data', title: 'Data', systemIcon: 'chart.bar' },
        { id: 'settings', title: 'Settings', systemIcon: 'gear' },
      ],
      // Optional: Customize tab icon colors
      selectedIconColor: '#007AFF',      // Blue for selected tab
      unselectedIconColor: '#8E8E93'     // Gray for unselected tabs
    });

    // Native → JS (user taps native tab)
    await TabsBar.addListener('selected', ({ id }: { id: string }) => {
      this.router.navigateByUrl(`/tabs/${id}`);
    });

    // JS → Native (keep native highlight in sync with route)
    this.sub = this.router.events
      .pipe(filter(e => e instanceof NavigationEnd))
      .subscribe(() => {
        const id = this.routeToTabId(this.router.url);
        if (id) TabsBar.select({ id });
      });
  }

  private routeToTabId(url: string): string | null {
    if (url.startsWith('/tabs/home')) return 'home';
    if (url.startsWith('/tabs/new')) return 'new';
    if (url.startsWith('/tabs/calendar')) return 'calendar';
    if (url.startsWith('/tabs/data')) return 'data';
    if (url.startsWith('/tabs/settings')) return 'settings';
    return null;
  }
```

⚠️ Remember: You will need to build and run with iOS 26+ from Xcode Beta for the navigation bar to be visible.

👀 If you are using Ionic’s tabs for other platforms, you can use the above useNativeTabs attribute to hide them on iOS 26+.

```html
<ion-tabs [class.hidden]="useNativeTabs">
    ... Tabs content here
</ion-tabs>
```

## 🎨 Color Customization

Stay Liquid now supports dynamic color customization for tab icons. You can specify custom colors for both selected and unselected tab states using hex or RGBA color formats.

### Supported Color Formats

- **Hex Colors**: `#FF5733`, `#F57` (3-digit), `#FF5733FF` (with alpha)
- **RGBA Colors**: `rgba(255, 87, 51, 1.0)`, `rgb(255, 87, 51)`

### Configuration Options

```tsx
await TabsBar.configure({
  items: [...],
  // Color customization options
  selectedIconColor: '#FF5733',           // Hex color for selected tab
  unselectedIconColor: 'rgba(142, 142, 147, 0.6)', // RGBA color for unselected tabs
});
```

### Color Examples

```tsx
// Example 1: Using hex colors
await TabsBar.configure({
  items: [...],
  selectedIconColor: '#007AFF',      // iOS blue
  unselectedIconColor: '#8E8E93'     // iOS gray
});

// Example 2: Using RGBA colors with transparency
await TabsBar.configure({
  items: [...],
  selectedIconColor: 'rgba(0, 122, 255, 1.0)',    // Blue with full opacity
  unselectedIconColor: 'rgba(142, 142, 147, 0.6)' // Gray with 60% opacity
});

// Example 3: Using short hex notation
await TabsBar.configure({
  items: [...],
  selectedIconColor: '#F57',    // Expands to #FF5577
  unselectedIconColor: '#999'   // Expands to #999999
});

// Example 4: Dynamic color changes
setTimeout(async () => {
  await TabsBar.configure({
    items: [...],
    selectedIconColor: '#FF3B30',  // Change to red
    unselectedIconColor: '#C7C7CC' // Change to lighter gray
  });
}, 3000);
```

### Color Validation & Fallbacks

- Invalid color formats will trigger warnings and fall back to system defaults
- Colors are validated on both TypeScript and iOS sides
- Color changes apply immediately and persist across tab selections
- If no colors are specified, the system uses iOS default colors

## 🔜 Contributing and Further Developments

Stay liquid is still a proof-of-concept but the idea of rendering specific native components on top of Ionic’s webview is an idea worth exploring. So far, we have implemented this solely for the tabs navigation bar but I hope to build out the library to contain more components and add more flexibility into how each component can be controlled from within Ionic.

If you want to help, please feel free to report bugs, ask questions and create new branches.
