// SPDX-License-Identifier: MIT
/*
MIT License

Copyright (c) 12025 HE Yunseo Kim <contact@yunseo.kim>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*** MY OVERRIDES ***/
user_pref("_user.js.parrot", "overrides section syntax error");

user_pref("browser.startup.page", 1); // 0102: Show home page set in 0103 when browser starts
user_pref("browser.startup.homepage", "about:home"); // 0103: Homepage and new window: Firefox home (default)
user_pref("browser.newtabpage.enabled", true); // 0104: New tab: Firefox home (default)

user_pref("network.file.disable_unc_paths", false); // [HIDDEN PREF] 0703: Enable UNC (Uniform Naming Convention) paths (relaxed settings for normal operation of extension apps) [FF61+]

user_pref("network.trr.mode", 2); // 0710: enable DNS-over-HTTPS (DoH) [FF60+]
user_pref("network.trr.uri", "https://freedns.controld.com/no-ads-gambling-malware-typo"); // 0712: set DoH provider
user_pref("network.trr.custom_uri", "https://freedns.controld.com/no-ads-gambling-malware-typo");

user_pref("browser.urlbar.recentsearches.featureGate", false); // 0808: disable recent searches [FF120+]
user_pref("layout.css.visited_links_enabled", false); // [SETUP-HARDEN] 0820: disable coloring of visited links

user_pref("security.OCSP.require", false); // 1212: set OCSP fetch failures (non-stapled, see 1211) to soft-fail (relaxed settings to prevent SEC_ERROR_OCSP_SERVER_ERROR)

user_pref("privacy.userContext.newTabContainerOnLeftClick.enabled", true); // 1702: set behavior on "+ Tab" button to display container menu on left click [FF74+]
user_pref("browser.link.force_default_user_context_id_for_external_opens", true); // 1703: set external links to open in site-specific containers [FF123+]

user_pref("media.peerconnection.ice.no_host", true); // [SETUP-HARDEN] 2004: force exclusion of private IPs from ICE candidates [FF51+]. This will protect your private IP even in TRUSTED scenarios after you grant device access, but often results in breakage on video-conferencing platforms

user_pref("permissions.default.shortcuts", 2); // 2615: disable websites overriding Firefox's keyboard shortcuts [FF58+]

/* 2660: limit allowed extension directories
 * 1=profile, 2=user, 4=application, 8=system, 16=temporary, 31=all
 * The pref value represents the sum: e.g. 5 would be profile and application directories
 * [SETUP-CHROME] Breaks usage of files which are installed outside allowed directories
 * [1] https://archive.is/DYjAM ***/
user_pref("extensions.enabledScopes", 7); // [HIDDEN PREF]
// Relaxed settings to avoid breaking the 'Progressive Web Apps for Firefox' extension.
// If you don't need it, I recommend reverting to arkenfox's default value of 5.

user_pref("extensions.webextensions.restrictedDomains", ""); // 2662: disable webextension restrictions on certain mozilla domains (you also need 4503) [FF60+]

user_pref("privacy.resistFingerprinting", true); // 4501: enable RFP
user_pref("privacy.spoof_english", 2); // 4506: Enable RFP spoof english (hardened settings) [FF59+] (0=prompt, 1=disabled, 2=enabled)

user_pref("signon.rememberSignons", false); // 5003: disable saving passwords
user_pref("permissions.memory_only", true); // [HIDDEN PREF] 5004: disable permissions manager from writing to disk [FF41+] (This means any permission changes are session only)
user_pref("browser.urlbar.suggest.history", false); // 5010: disable location bar history suggestion

user_pref("_user.js.parrot", "overrides section successful");