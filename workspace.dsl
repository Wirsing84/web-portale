workspace "Domäne Web-Portale" {

    !docs docs

    model {
        // Nutzer
        bankMitarbeiter = person "Bank Mitarbeiter"
        redaktion = person "Redaktion"

        iw = softwareSystem "InvestmentWelt Neu"

        group "SD Infomanagement" {
            magnolia = softwareSystem "Magnolia" "Content Management System" "SD Infomanagement, SDT 342, SDT Code d'Azure"
            first_spirit = softwareSystem "FirstSpirit" "Altes Content Management System" "SD Infomanagement, SDT Asset Force"
            liferay = softwareSystem "Liferay" "Portal Server" "SD Infomanagement, SDT Asset Force"

            celum = softwareSystem "Celum" "Digital Asset Management" "SD Infomanagement, SDT Asset Force"
            moving_image = softwareSystem "MovingImage" "SaaS Video Streaming Dienst" "SD Infomanagement"
            uni_tube = softwareSystem "UniTube" "CorporateTube Produkt von MovingImage" "SD Infomanagement"
            doc_me = softwareSystem "DocMe" ""

            universal_messanger = softwareSystem "Universal Messanger" ""
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
            totara = softwareSystem "Totara" "E-Learning Platform"
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
            azure_adb_2_c = softwareSystem "Azure ADB2C" "" "SD User"

            mitarbeiterverwaltung = softwareSystem "Mitarbeiterverwaltung" "" "SD User" {
                !docs mv/docs

                mvBackend = container "MV Backend"

                uoaDB = container "UOA" "UOA Database" "TSY-Oracle" "Database" {
                    mvBackend -> this "Reads from and writes to"
                }

                uoaSyncSchema = container "Sync Schema" "Dedicated Schema for synching data to and from the NV Database" "TSY-Oracle" "Database" {
                    uoaDB -> this "Writes delta information to this schema using triggers "
                }

                mvSyncOutgoing = container "MV Sync Outgoing"
                mvSyncIncoming = container "MV Sync Incoming"

            }

            nutzerverwaltung = softwareSystem "Nutzerverwaltung" "" "SD User" {
                !docs nv/docs

                nvFrontend = container "Frontend" "" "Vue SPA" "SD User"
                nvBackend = container "Backend / API" "" "Vue SPA" "SD User" {
                    nvFrontend -> this "Consumes API"
                }
                nvDb = container "Database" "" "PostgreSQL" "Database, SD User" {
                    nvBackend -> this "Reads from and writes to"
                }
            }

            mvSyncOutgoing -> uoaSyncSchema "reads MV changes" "JPA"
            mvSyncOutgoing -> nvDb "writes MV changes into NV DB" "JPA"

            mvSyncIncoming -> nvDb "reads NV changes" "Event driven"
            mvSyncIncoming -> uoaSyncSchema "writes NV changes into UOA"
        }

        // person -> system
        bankMitarbeiter -> iw "nutzt"
        redaktion -> iw "nutzt"
        redaktion -> magnolia "verwaltet Inhalte"

        // system -> system neu


        // iw -> shell_portalrahmen "basiert auf"

        iw -> magnolia "integriert"
        iw -> algolia "integriert"
        iw -> totara "integriert"

        iw -> iw_alt "verlinkt auf"

        magnolia -> algolia "pusht suchbare Inhalte"
        magnolia -> celum "konsumiert Bilder und ruft Dokumente ab"

        totara -> algolia "pusht suchbare Inhalte"


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
            include ->nutzerverwaltung->
        }

        container nutzerverwaltung "nv-container" {
            include *
        }

        container mitarbeiterverwaltung "mv-container" {
            include *
        }

        styles {
            element Person {
                shape person
            }
            element Database {
                shape cylinder
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
        }
    }

}