// Zotero sin avisos al empezar: ni la página de inicio en el navegador, ni la oferta de
// instalar el complemento de LibreOffice (Calc no lo usa), ni el aviso de «se le ha
// actualizado» a quien lo abre por primera vez. Va en el perfil, que
// profiles.ini deja creado: los valores por omisión del programa no llegan a leerse.
user_pref("extensions.zotero.firstRun2", false);
user_pref("extensions.zotero.firstRunGuidance", false);
user_pref("extensions.zotero.firstRun.skipFirefoxProfileAccessCheck", true);
user_pref("extensions.zoteroOpenOfficeIntegration.skipInstallation", true);
user_pref("extensions.zotero.showPostUpgradeBanner", false);
