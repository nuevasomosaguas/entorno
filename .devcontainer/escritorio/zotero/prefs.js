// Ajustes iniciales del perfil de Zotero. Van en prefs.js, no en user.js: Zotero los
// lee una vez y luego los guarda él, así que se pueden cambiar en sus preferencias.
// @HOME@ y @HOMEURI@ los pone somosaguas-cuenta.
//
// Los PDF que llegan del navegador (Zotero Connector) no se quedan en el almacén interno
// de Zotero: ZotMoov los mueve a ~/Biblioteca/almacen_pdf, con el nombre «Autor - Año -
// Título», como archivos vinculados relativos a esa carpeta.
user_pref("extensions.zotero.baseAttachmentPath", "@HOME@/Biblioteca/almacen_pdf");
user_pref("extensions.zotero.saveRelativeAttachmentPath", true);
user_pref("extensions.zotmoov.dst_dir", "@HOME@/Biblioteca/almacen_pdf");
// La biblioteca propia, siempre exportada a ~/Biblioteca/zotero.bib por Better BibTeX
// (cada vez que cambia): la leen pandoc y VS Code junto a la de la Nueva Somosaguas.
user_pref("extensions.zotero.translators.better-bibtex.autoExport.@HOMEURI@%2FBiblioteca%2Fzotero%2ebib", "{\"enabled\":true,\"type\":\"library\",\"id\":1,\"path\":\"@HOME@/Biblioteca/zotero.bib\",\"translatorID\":\"ca65189f-8815-4afe-8c8b-8c7c15f0edca\",\"status\":\"done\",\"recursive\":false,\"error\":\"\",\"exportNotes\":false,\"useJournalAbbreviation\":false,\"created\":0,\"updated\":0}");
