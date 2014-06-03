Gestion MultiLangue  
===================
Utiliser le module  Dancer::Plugin::I18N
my $lang = languages ;
contient la liste des langues du navigateur
exemple de mon navigateur

$VAR1 = [ 'fr-fr', 'fr', 'en', 'nl-nl', 'nl', 'en-gb', 'ru-ru', 'ru', 'it-it', 'it', 'fr-be', 'fr-ca', 'fr-lu', 'fr-ch', 'fr-mc', 'de-de', 'de', 'en-au', 'i-default' ]; 


0) éditer le fichier config.yml et ajouter

# Module support MultiLangue
############################

    I18N:
        directory: I18N
        lang_default: fr


1) choisir la langue de tag ( de base ) ( choisir d'anglais pour msgid , c'est msgid qu'il faut mettre dans le template )

<h3> Traduction de Hello en Français [% l('Hello') %] </h3>



Crée un fichier po de ce type


# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
msgid ""
msgstr ""
"Project-Id-Version: Dancer\n"
"POT-Creation-Date: YEAR-MO-DA HO:MI+ZONE\n"
"PO-Revision-Date: 2014-03-13 14:31+0100\n"
"Last-Translator: Hugues admin@softalys.com\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=(n > 1);\n"
"Language: fr_FR\n"

msgid "Hello"
msgstr "Bonjour2"



une fois le fichier crée ( on peut l'éditer avec Poedit ) 

il faut le compiler avec la commande
msgfmt --output-file=I18N/fr.mo I18N/fr.po

c'est le fichier fr.mo qui va être utiliser pour rechercher la traduction




