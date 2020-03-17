# capacitor-plugin-secure-storage

Capacitor plugin for storing string values securly on Android.

## How to install

```
npm install https://github.com/komed-health/capacitor-plugin-secure-storage.git
```


### Android

In Android we need to migrate app to AndroidX because this plugin uses [AndroidX Seurity Library](https://developer.android.com/reference/androidx/security/crypto/package-summary)
 
More information about Migration can be found here.
https://developer.android.com/jetpack/androidx/migrate#migrate_an_existing_project_using_android_studio

You have to register plugins manually in MainActivity class of your app.

https://capacitor.ionicframework.com/docs/plugins/android/#export-to-capacitor

```
import com.komedhealth.plugin.CapacitorSecureStoragePlugin;

...

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
      // Ex: add(TotallyAwesomePlugin.class);
      add(CapacitorSecureStoragePlugin.class);
    }});
  }
}
```


## Usage

In a component where you want to use this plugin add to or modify imports:

```
import { Plugins } from '@capacitor/core';

const { CapacitorSecureStoragePlugin } = Plugins;
```

## Methods

- **get**(options: { key: string }): Promise<{ value: string | null }>
  - if item with specified key does not exist, rerturns null value
* **set**(options: { key: string; value: string }): Promise< void >
* **remove**(options: { key: string }): Promise< void >
* **clear**(): Promise< void >
* **key**() : Promise<{ keys: string[] }>
  - returns array of all existing keys

## Example

```
const key = 'name';
const value = 'charlie';

await CapacitorSecureStoragePlugin.set({ key, value })
```

```
const key = 'name';
const data = CapacitorSecureStoragePlugin.get({ key })
console.log(data);
console.log(data.value);
```

## Platform specific information

### Android

On Android it is implemented by  [AndroidX Seurity Library](https://developer.android.com/reference/androidx/security/crypto/package-summary)

##### Warning

For Android minSdk must be >= 23, in order to use the plugin.

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in LocalStorage, but they are at least base64 encoded. Plugin adds **cap_sec_** prefix to keys to avoid conflicts with other data stored in LocalStorage.
