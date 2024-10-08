workspace "Domäne Web-Portale" {

    !docs docs

    model {
        // Nutzer
        bankMitarbeiter = person "Bankmitarbeiter"
        redaktion = person "Redaktion"
        b2cNutzer = person "B2C Nutzer"

        zielgruppenAdmin = person "Zielgruppen Admin"
        bankAdmin = person "Bank Admin"

        // Portale
        iw = softwareSystem "InvestmentWelt Neu" "" "Portal"
        ik_online = softwareSystem "IK Online" "" "Portal"
        vertriebsCockpit = softwareSystem "Vertriebs Cockpit" "" "Portal"

        // Webseiten
        uip_de = softwareSystem "www.union-investment.de" "www.union-investment.de" "Web-Auftritt,UIP" {
            url https://www.union-investment.de
        }
        uip_at = softwareSystem "www.union-investment.at" "" "Web-Auftritt,UIP"
        uir_intl = softwareSystem "realestate.union-investment.com" "" "Web-Auftritt,UIR"
        umh = softwareSystem "unternehmen.union-investment.de" "" "Web-Auftritt,UMH"
        attrax = softwareSystem "www.attrax.lu" "" "Web-Auftritt,Attrax"

        // 

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

        group "SD Fonds & Produkte" {
            altervorsorge_rechner = softwareSystem "Altervorsorge Rechner" ""
            anlage_rechner = softwareSystem "AnlageRechner" ""
            synfonic = softwareSystem "SynFonIC" ""
            cegeka = softwareSystem "Cegeka" "Digitale Ergebnisberichte"
            fonds_datenkiosk = softwareSystem "Fonds Datenkiosk" ""
            poi_db = softwareSystem "POI-DB" ""
            fondspreisliste = softwareSystem "Fondspreisliste"
            fondportrait = softwareSystem "Fondportait"
            fondspreisliste_alt = softwareSystem "Fondspreisliste Alt"
            fondportrait_alt = softwareSystem "Fondportait Alt"
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
            msdynamics = softwareSystem "MS Dynamics" "" "Andere" {
                crm_ik_pk = container "Customer Insights Journeys (CRM IK/PK)" "" 
            }
            uam = softwareSystem "UAM" "" "Andere"
            depotplatform = softwareSystem "Depotplatform" "" "Andere"
            dvo = softwareSystem "DVO" "" "Andere"
            atol = softwareSystem "ATOL" "" "Andere"
            legacy_apps = softwareSystem "Legacy Apps" "" "Andere"
            depotupload = softwareSystem "Depotupload" "" "Andere"
            ump = softwareSystem "UMP" "" "Andere"
            ladezone = softwareSystem "Ladezone" "" "Andere"
        }

        group "SD User" {
            zielgruppenSystem = softwareSystem "Zielgruppen System" "" "SD User" {
                !docs zielgruppen/docs

                zielgruppenApi = container "Zielgruppen API" "" "Azure APIM Package"
            }

            zielgruppenApi -> crm_ik_pk "liest" 

            azure_adb_2_c = softwareSystem "Azure ADB2C" "" "SD User"
            entra_id = softwareSystem "Azure AD / Entra ID" "" "SD User"

            mitarbeiterverwaltung = softwareSystem "Mitarbeiterverwaltung" "" "SD User" {
                !docs mv/docs

                mv = container "MV" {
                    bankAdmin -> this "administriert Nutzer"
                }

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

                nvFrontend = container "NV Frontend" "" "Vue SPA" "SD User"
                nvBackend = container "NV Backend" "" "Vue SPA" "SD User" {
                    nvBackendApi = component "NV Backend API" "" "Java Quarkus" {
                        nvFrontend -> this "Consumes API"    
                    }
                    nvBackendSync = component "MV/NV Sync Application" "" "Java Quarkus"
                    shared = component "Shared Code" "" "Java"
                    nvBackendApi -> shared "uses"
                    nvBackendSync -> shared "uses"
                }
                nvDb = container "Database" "" "PostgreSQL" "Database, SD User" {
                    nvBackendApi -> this "Reads from and writes to"
                }
            }
            
            nvBackendSync -> nvDb "writes MV changes into NV DB" "JPA"
            nvBackendSync -> uoaSyncSchema "reads MV changes" "JPA"
            
            mvSync -> uoaSyncSchema "reads MV changes" "JPA"
            mvSync -> uoaSyncSchema "writes NV changes into UOA"
        }

        // person -> system
        bankMitarbeiter -> iw "nutzt"
        redaktion -> iw "nutzt"
        redaktion -> magnolia "verwaltet redaktionelle Inhalte"
        redaktion -> totara "verwaltet Lerninhalte"
        bankMitarbeiter -> magnolia "konsumiert redaktionelle Inhalte"
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

        // CRM basierte Zielgruppen
        magnolia -> zielgruppenApi "ruft Zielgruppen ab"        
        magnolia -> entra_id "auth"
        totara -> zielgruppenApi "ruft Zielgruppen ab"
        mitarbeiterverwaltung -> ladezone "speichert Zielgruppen Zutaten"
        ladezone -> crm_ik_pk "speichert Zielgruppen Zutaten"
        zielgruppenAdmin -> crm_ik_pk "manueller Datenabzug" "" "legacy"
        zielgruppenAdmin -> crm_ik_pk "definiert Zielgruppen"
        azure_adb_2_c -> zielgruppenApi "ruft Zielgruppen ab"

        // Liferay basierte Zielgruppen
        bankMitarbeiter -> azure_adb_2_c "login"
        mitarbeiterverwaltung -> liferay "speichert Rechte für Rollengruppen Bildung" "" "legacy"
        azure_adb_2_c -> liferay "ruft Zielgruppen für aktuellen User ab" "" "legacy"
        magnolia -> liferay "ruft Zielgruppen ab" "" "legacy"
        zielgruppenAdmin -> liferay "definiert Zielgruppen" "" "legacy"

        // system -> system alt
        iw_alt -> liferay "zeigt Daten"
        iw_alt -> first_spirit "bezieht Inhalt aus"

        // Privatkunden Auftritt
        b2cNutzer -> uip_de "nutzt"
        uip_de -> intergator "nutzt für die Suche"
        uip_de -> fondportrait_alt "nutzt"
        uip_de -> fondspreisliste_alt "nutzt"
        fondspreisliste_alt -> intergator "basiert auf"
        uip_de -> magnolia "zeigt Inhalte"
    }

    views {
        systemLandscape "Diagram1" {
            include *
            exclude element.tag==Andere
        }


        systemLandscape "Webauftritte" {
            include ->element.tag==Web-Auftritt->
        }

        systemContext uip_de "privatkunden" {
            include *
        }

        systemContext mitarbeiterverwaltung "mv-system-context" {
            include ->mitarbeiterverwaltung->
        }

        systemContext nutzerverwaltung "nv-system-context" {
            include ->nutzerverwaltung-> ->mitarbeiterverwaltung->
        }

        systemLandscape "zielgruppen-api-system-landscape" {
            title "Kontextabgrenzung Zielgruppen System"
            include ->zielgruppenSystem-> mitarbeiterverwaltung redaktion bankMitarbeiter zielgruppenAdmin bankAdmin ladezone azure_adb_2_c
        }

        systemLandscape "zielgruppen-api-system-landscape-aktuell" {
            title "Kontextabgrenzung Zielgruppen System Aktuell"
            include liferay magnolia mitarbeiterverwaltung azure_adb_2_c redaktion bankMitarbeiter zielgruppenAdmin bankAdmin msdynamics
        } 

        systemContext zielgruppenSystem "zielgruppen-system-context" {
            title "Zielgruppen System Kontext"
            include *
        }

        systemContext magnolia "zielgruppen-system-context-konsumenten" {
            title "Zielgruppen System Kontext (Konsumenten)"
            include magnolia zielgruppenSystem totara redaktion azure_adb_2_c bankMitarbeiter
        }

        container msdynamics "zielgruppen-system-context-msdynamics" {
            title "Zielgruppen System Kontext (MS Dynamics)"
            include * mitarbeiterverwaltung
            exclude relationship.tag==legacy
        }

        container zielgruppenSystem "zielgruppen-system-container" {
            include *
        }

        container nutzerverwaltung "nv-container" {
            include *
        }

        container mitarbeiterverwaltung "mv-container" {
            include element.parent==nutzerverwaltung element.parent==mitarbeiterverwaltung
        }

        component nvBackend "nvBackend-component" {
            include *
        }


        dynamic * "zielgruppen-api-get-target-groups-for-user" "Zielgruppen-basierte Contentausspielung" {
            title "Zielgruppen basierte Contentausspielung"
            magnolia -> zielgruppenSystem "ruft Zielgruppen mit Token des Nutzers ab"
            zielgruppenSystem -> msdynamics "Login (technischer User)"
            zielgruppenSystem -> msdynamics "ruft Zielgruppen für UUKEY ab "
            msdynamics -> zielgruppenSystem "liefert Zielgruppen für UUKEY"
            zielgruppenSystem -> magnolia "liefert Zielgruppen für User"
        }


        dynamic * "zielgruppen-api-magnolia-content-ausspielung" "Zielgruppen-basierte Contentausspielung" {
            title "Zielgruppen basierte Contentausspielung"
            bankMitarbeiter -> iw "ruft auf"
            iw -> azure_adb_2_c "Redirect für Login"
            azure_adb_2_c -> zielgruppenSystem "Abruf der Zielgruppen"
            zielgruppenSystem -> msdynamics "login technischer user"
            zielgruppenSystem -> msdynamics "ruft Zielgruppen für uukey ab"
            msdynamics -> zielgruppenSystem "liefert Zielgruppen für uukey"
            zielgruppenSystem -> azure_adb_2_c "liefert Zielgruppen für uukey"
            azure_adb_2_c -> iw "erzeugt Logintoken inkl. Zielgruppen"
            iw -> magnolia "leitet weiter"
            magnolia -> bankMitarbeiter "Content Ausspielung auf Basis Zielgruppenzugehörigkeit"
        }

        dynamic * "zielgruppen-api-magnolia-redaktion" "Magnolia Redaktion" {
            redaktion -> magnolia "verwaltet Inhalt"
            magnolia -> entra_id "redirect für Login"
            entra_id -> magnolia "erzeugt Logintoken"
            magnolia -> zielgruppenSystem "ruft alle verfügbaren Zielgruppen ab"
            zielgruppenSystem -> msdynamics "login technischer user"
            zielgruppenSystem -> msdynamics "ruft alle verfügbaren Zielgruppen ab"
            msdynamics -> zielgruppenSystem "liefert alle Zielgruppen"
            zielgruppenSystem -> magnolia "liefert alle Zielgruppen"
            magnolia -> redaktion "ermöglicht Auswahl der Zielgruppen für Inhalt"
        }


        dynamic * "zielgruppen-api-totara-ausspielung" "Zielgruppen basierte Contentausspielung" {
            bankMitarbeiter -> iw "ruft auf"
            iw -> azure_adb_2_c "redirect für Login"
            azure_adb_2_c -> iw "erzeugt Logintoken"
            iw -> totara "leitet weiter"
            totara -> zielgruppenSystem "ruft Zielgruppen mit Logintoken ab"
            zielgruppenSystem -> msdynamics "ruft Zielgruppen für uukey ab"
            msdynamics -> zielgruppenSystem "liefert Zielgruppen für uukey"
            zielgruppenSystem -> totara "liefert Zielgruppen für user"
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

            element Portal {
                shape Webbrowser
            }

            element "Software System" {
                shape RoundedBox
            }

            element Container {
                shape RoundedBox
            }

            element Component {
                shape RoundedBox
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