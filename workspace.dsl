workspace "Domäne Web-Portale" {

    !docs docs

    model {
        // Nutzer
        bankMitarbeiter = person "Bankmitarbeiter"
        redaktion = person "Redaktion"
        b2cNutzer = person "B2C Nutzer"

        iw = softwareSystem "InvestmentWelt Neu"

        group "SD Infomanagement" {
            magnolia = softwareSystem "Magnolia" "Content Management System" "SD Infomanagement, SDT 342, SDT Code d'Azure"
            first_spirit = softwareSystem "FirstSpirit" "Altes Content Management System" "SD Infomanagement, SDT Asset Force"
            liferay = softwareSystem "Liferay" "Portal Server" "SD Infomanagement, SDT Asset Force"

            celum = softwareSystem "Celum" "Digital Asset Management" "SD Infomanagement, SDT Asset Force"
            moving_image = softwareSystem "MovingImage" "SaaS Video Streaming Dienst" "SD Infomanagement"
            uni_tube = softwareSystem "UniTube" "CorporateTube Produkt von MovingImage" "SD Infomanagement"
            doc_me = softwareSystem "DocMe" ""

            universal_messenger = softwareSystem "Universal Messenger" ""
            webforms = softwareSystem "webforms" "Digitale Formulare"

            intergator = softwareSystem "Intergator" "Suchmaschine"
            elasticsearch = softwareSystem "Elasticsearch" ""

            iw_alt = softwareSystem "InvestmentWelt Alt"
        }

        group "Fonds & Produkte" {
            altervorsorge_rechner = softwareSystem "Altervorsorge Rechner" ""
            anlage_rechner = softwareSystem "AnlageRechner" ""
            synfonic = softwareSystem "SynFonIC" ""
            cegeka = softwareSystem "Cegeka" "Digitale Ergebnisberichte"
            fonds_datenkiosk = softwareSystem "Fonds Datenkiosk" ""
            poi_db = softwareSystem "POI-DB" ""
        }

        group "SD Qualifizierung und Dialog" {
            totara = softwareSystem "Totara" "E-Learning Platform" "SDT Quali"
        }

        group "SD Basis IT" {
            shell_portalrahmen = softwareSystem "Shell / Portalrahmen" "" "SDT Portastruktur"
            solid_design_system = softwareSystem "Solid Design System" "" "SDT SDS"

            usercentrics = softwareSystem "Usercentrics" ""
            webtrekk = softwareSystem "Webtrekk" "Neuer Name Mapp Intelligence"

            algolia = softwareSystem "Algolia" "Neue Suche" "SDT Portastruktur"
        }

        group "Andere" {
            crm_ik_pk = softwareSystem "CRM IK/PK" ""
            uam = softwareSystem "UAM" ""
            depotplatform = softwareSystem "Depotplatform" ""
            dvo = softwareSystem "DVO" ""
            atol = softwareSystem "ATOL" ""
            legacy_apps = softwareSystem "Legacy Apps" ""
            depotupload = softwareSystem "Depotupload" ""
            ump = softwareSystem "UMP" ""
        }

        group "SD User" {
            zielgruppenApi = softwareSystem "Zielgruppen API" "" "SD User"

            zielgruppenApi -> crm_ik_pk "liest"

            azure_adb_2_c = softwareSystem "Azure ADB2C" "" "SD User"

            mitarbeiterverwaltung = softwareSystem "Mitarbeiterverwaltung" "" "SD User" {
                !docs mv/docs

                mv = container "MV"

                uoaDB = container "UOA" "UOA Database" "TSY-Oracle" "Database" {
                    mv -> this "Reads from and writes to"
                }

                uoaSyncSchema = container "Sync Schema" "Dedicated Schema for synching data to and from the NV Database" "TSY-Oracle" "Database" {
                    uoaDB -> this "Writes delta information to this schema using triggers "
                }

                mvSync = container "MV Sync Adapter"

            }

            nutzerverwaltung = softwareSystem "Nutzerverwaltung" "" "SD User" {
                !docs nv/docs

                nvFrontend = container "Frontend" "" "Vue SPA" "SD User"
                nvBackend = container "Backend / API" "" "Vue SPA" "SD User" {
                    nvDbos = component "NV DBOs" "" "Maven Module"
                    nvFrontend -> this "Consumes API"
                }
                nvDb = container "Database" "" "PostgreSQL" "Database, SD User" {
                    nvBackend -> this "Reads from and writes to"
                }
            }



            mvSync -> uoaSyncSchema "reads MV changes" "JPA"
            mvSync -> nvDb "writes MV changes into NV DB" "JPA"
            mvSync -> nvDb "reads NV changes" "Event driven"
            mvSync -> uoaSyncSchema "writes NV changes into UOA"
            mvSync -> nvDbos "reuses code"
        }

        // person -> system
        bankMitarbeiter -> iw "nutzt"
        redaktion -> iw "nutzt"
        redaktion -> magnolia "verwaltet Inhalte"
        bankMitarbeiter -> magnolia "konsumiert Inhalte"
        bankMitarbeiter -> totara "nutzt Lernangebot"

        // system -> system neu
        iw -> magnolia "integriert"
        iw -> algolia "integriert"
        iw -> totara "integriert"

        iw -> iw_alt "verlinkt auf"

        iw -> azure_adb_2_c "AuthN / AuthZ durch"

        magnolia -> algolia "pusht suchbare Inhalte"
        magnolia -> celum "konsumiert Bilder und ruft Dokumente ab"

        totara -> algolia "pusht suchbare Inhalte"

        // Zielgruppen relevantes

        magnolia -> zielgruppenApi "ruft alle vorhandenen ab"
        magnolia -> zielgruppenApi "ruft Zielgruppen für aktuellen User ab"

        totara -> zielgruppenApi "ruft Zielgruppen für aktuellen User ab"
        nutzerverwaltung -> crm_ik_pk "speichert Zielgruppen Zutaten"

        // system -> system alt
        iw_alt -> liferay "zeigt Daten"
        iw_alt -> first_spirit "bezieht Inhalt aus"
    }

    views {
        systemLandscape "Diagram1" {
            include ->iw->
        }

        systemContext mitarbeiterverwaltung "mv-system-context" {
            include ->mitarbeiterverwaltung->
        }

        systemContext nutzerverwaltung "nv-system-context" {
            include ->nutzerverwaltung-> ->mitarbeiterverwaltung->
        }

        systemContext zielgruppenApi "zielgruppen-api-system-context" {
            include ->zielgruppenApi-> nutzerverwaltung redaktion bankMitarbeiter
        }

        container nutzerverwaltung "nv-container" {
            include *
        }

        container mitarbeiterverwaltung "mv-container" {
            include element.parent==nutzerverwaltung element.parent==mitarbeiterverwaltung
        }

        dynamic * "zielgruppen-api-magnolia-content-ausspielung" "Zielgruppen basierte Contentausspielung" {
            bankMitarbeiter -> iw "ruft auf"
            iw -> azure_adb_2_c "redirect für Login"
            azure_adb_2_c -> iw "erzeugt Logintoken"
            iw -> magnolia "leitet weiter"
            magnolia -> zielgruppenApi "ruft Zielgruppen mit Logintoken ab"
            zielgruppenApi -> crm_ik_pk "ruft Zielgruppen für uukey ab"
            crm_ik_pk -> zielgruppenApi "liefert Zielgruppen für uukey"
            zielgruppenApi -> magnolia "liefert Zielgruppen für user"
            magnolia -> bankMitarbeiter "Content Ausspielung auf Basis Zielgruppenzugehörigkeit"
        }


        dynamic * "zielgruppen-api-totara-ausspielung" "Zielgruppen basierte Contentausspielung" {
            bankMitarbeiter -> iw "ruft auf"
            iw -> azure_adb_2_c "redirect für Login"
            azure_adb_2_c -> iw "erzeugt Logintoken"
            iw -> totara "leitet weiter"
            totara -> zielgruppenApi "ruft Zielgruppen mit Logintoken ab"
            zielgruppenApi -> crm_ik_pk "ruft Zielgruppen für uukey ab"
            crm_ik_pk -> zielgruppenApi "liefert Zielgruppen für uukey"
            zielgruppenApi -> totara "liefert Zielgruppen für user"
            totara -> bankMitarbeiter "E-Learnings Ausspielung auf Basis Zielgruppenzugehörigkeit"
        }

        styles {
            element Person {
                shape person
                background #132c64
                color #ffffff
            }

            element Database {
                shape cylinder
            }

            element "Software System" {
                shape RoundedBox
                background #00358e
                color #ffffff
            }

            element Container {
                shape RoundedBox
                background #466daf
                color #ffffff
            }

            element Component {
                shape RoundedBox
                background #466daf
                color #000000
            }

            element "SD User" {
                icon "./icons/SDT_User.png"
            }

            element "SDT Code d'Azure" {
                icon "./icons/SDT_CodeDAzure.png"
            }

            element "SDT Asset Force" {
                icon "./icons/SDT_AssetForce.png"
            }

            element "SDT 342" {
                icon "./icons/SDT_342.png"
            }

            element "SDT Portastruktur" {
                icon "./icons/SDT_Portastruktur.png"
            }

            element "SDT SDS" {
                icon "./icons/SDT_SDS.png"
            }

            element "SDT Quali" {
                icon "./icons/SDT_Qualifizierung.png"
            }
        }

        branding {
            logo "./icons/ui.png"
        }
    }
    

}