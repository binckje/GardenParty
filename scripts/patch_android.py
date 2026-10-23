#!/usr/bin/env python3
"""Réglages Android requis par flutter_local_notifications (android/ est généré par flutter create).

- desugaring Java (obligatoire pour le plugin) ;
- permissions INTERNET (Google Agenda en release) et RECEIVE_BOOT_COMPLETED ;
- récepteurs des notifications programmées (reprogrammées après redémarrage).
Idempotent : relançable sans effet si déjà appliqué.
"""
import pathlib
import sys

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".")
gradle = root / "android/app/build.gradle.kts"
manifest = root / "android/app/src/main/AndroidManifest.xml"

g = gradle.read_text()
if "isCoreLibraryDesugaringEnabled" not in g:
    g = g.replace("compileOptions {", "compileOptions {\n        isCoreLibraryDesugaringEnabled = true", 1)
    g += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    gradle.write_text(g)
    print("build.gradle.kts : desugaring activé")

m = manifest.read_text()
if "ScheduledNotificationReceiver" not in m:
    perms = (
        '    <uses-permission android:name="android.permission.INTERNET"/>\n'
        '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>\n'
    )
    receivers = """        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
"""
    m = m.replace("    <application", perms + "    <application", 1)
    m = m.replace("    </application>", receivers + "    </application>", 1)
    manifest.write_text(m)
    print("AndroidManifest.xml : permissions et récepteurs de notifications ajoutés")
