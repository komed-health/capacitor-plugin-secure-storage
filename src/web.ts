import { WebPlugin } from '@capacitor/core';
import { CapacitorSecureStoragePluginPlugin } from './definitions';

export class CapacitorSecureStoragePluginWeb extends WebPlugin implements CapacitorSecureStoragePluginPlugin {

  constructor() {
    super({
      name: 'CapacitorSecureStoragePlugin',
      platforms: ['web']
    });
  }

  PREFIX = 'cap_sec_';

  get(options: { key: string; }): Promise<{ value: string; }> {
    return Promise.resolve({ value: atob(localStorage.getItem(this.addPrefix(options.key))) });
  }

  set(options: { key: string; value: string; }): Promise<void> {
    localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
    return Promise.resolve();
  }

  remove(options: { key: string; }): Promise<void> {
    localStorage.removeItem(this.addPrefix(options.key));
    return Promise.resolve();
  }

  clear(): Promise<void> {
    for (var key in localStorage) {
      if (key.indexOf(this.PREFIX) === 0) {
        localStorage.removeItem(key);
      }
    }
    return Promise.resolve();
  }

  keys(): Promise<{ keys: string[]; }> {
    return Promise.resolve({ keys: Object.keys(localStorage).filter(key => key.indexOf(this.PREFIX) === 0) });
  }

  private addPrefix = (key: string) => this.PREFIX + key;
}

const CapacitorSecureStoragePlugin = new CapacitorSecureStoragePluginWeb();

export { CapacitorSecureStoragePlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(CapacitorSecureStoragePlugin);
