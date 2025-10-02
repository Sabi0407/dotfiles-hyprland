// Activer userChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Optimisations Wayland
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);

// Désactiver les décorations côté client
user_pref("browser.tabs.drawInTitlebar", false);
user_pref("browser.tabs.inTitlebar", 0);
