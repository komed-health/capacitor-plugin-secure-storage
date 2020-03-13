package com.komedhealth.plugin;

import android.content.SharedPreferences;
import android.util.Log;

import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKeys;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import org.json.JSONException;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Map;
import java.util.Set;

@NativePlugin()
public class CapacitorSecureStoragePlugin extends Plugin {

    private SharedPreferences prefs;
    private static final String LOG_TAG = CapacitorSecureStoragePlugin.class.getSimpleName();

    @Override
    public void load() {
        super.load();
        String masterKeyAlias = null;
        try {
            masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);
            prefs = EncryptedSharedPreferences.create(
                    "encrypted_preferences",
                    masterKeyAlias,
                    getContext(),
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (GeneralSecurityException | IOException e) {
            Log.e(LOG_TAG, "PasswordStorage initialisation error:" + e.getMessage(), e);
        }
    }

    @PluginMethod()
    public void get(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
            return;
        }
        String value = prefs.getString(key, null);

        JSObject ret = new JSObject();
        ret.put("value", value == null ? JSObject.NULL : value);
        call.resolve(ret);
    }

    @PluginMethod()
    public void set(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
            return;
        }
        String value = call.getString("value");

        prefs.edit().putString(key, value).apply();
        call.resolve();
    }

    @PluginMethod()
    public void remove(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
            return;
        }

        prefs.edit().remove(key).apply();
        call.resolve();
    }

    @PluginMethod()
    public void keys(PluginCall call) {
        Map<String, ?> values = prefs.getAll();
        Set<String> keys = values.keySet();
        int keySize = keys.size();
        String[] keyArray = keys.toArray(new String[keySize]);
        JSObject ret = new JSObject();
        try {
            ret.put("keys", new JSArray(keyArray));
        } catch (JSONException ex) {
            call.reject("Unable to create key array.");
            return;
        }
        call.resolve(ret);
    }

    @PluginMethod()
    public void clear(PluginCall call) {
        prefs.edit().clear().apply();
        call.resolve();
    }

}
