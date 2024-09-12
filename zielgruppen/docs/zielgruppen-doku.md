# Zielgruppen System

## Einführung und Ziele

Im Kontext der InvestmentWelt werden verschiedene Inhalte nur für bestimmte Nutzergruppen ausgespielt.

Dazu werden Nutzer unter anderem in sogenannte Zielgruppen eingeteilt und Inhalte mit den entsprechenden Zielgruppen verknüpft.
Bei der Anzeige der Inhalte wird dann geprüft, ob der aktuelle Nutzer in der zugehörigen Zielgruppe ist.

### Aufgabenstellung

Die Lösung umfasst zwei Kernpunkte:

1. Die Definition der Zielgruppen anhand verschiedener Kriterien
1. Bereitstellung der Zielgruppen Daten für die Nutzung durch die Umsysteme

### Qualitätsziele

1. Die Zielgruppen Definition soll komfortabler funktionieren als in der bisherigen Liferay basierten Lösung. Idealerweise durchführbar durch Readaktionsmitglieder selber, anstatt durch Expert*Innen.
1. Zielgruppen Zugehörigkeit ist bei Änderungen innerhalb von 1h aktualisiert

## Randbedingungen

### Technische Randbedingungen

### Organisatorische Randbedingungen

Liferay wird Ende 2025 abgeschaltet. Bis dahin muss mindestens eine Übergangslösung produktiv sein und die Umsysteme umgestellt haben.

### Konventionen

## Kontextabgrenzung

### Fachlicher Kontext

![](embed:zielgruppen-api-system-landscape)

### Technischer- oder Verteilungskontext

## Lösungsstrategie

Die Lösung für das Zielgruppen System sieht vor MS Dynamics als Basis der Zielgruppen Berechnung zu verwenden. Dies hat sich aus der Betrachtung verschiedener Optionen als vielversprechend herauskristalisiert. Vor allem weil viele Daten für die Berechnung bereits in MS Dynamics vorhanden sind. Darüber hinaus bietet MS Dynamics komfortable Werkzeuge für die Filterung und Segmentierung von Nutzern, was für die Zielgruppen Defintion verwendet werden kann. Ausserdem kann die Lösung von Produktweiterentwicklungen bspw. im Bereich KI direkt profitieren.

### Zielbild

Zielbild Customer Insights Data
CDP
verschiedene Datentöpfe anzapfen
Dynamische Segementierung

mehrere Fragen für die Einführung offen

### Übergangslösung

Um die Liferay Ablösung durch die Einführung von Customer Insights Data nicht zu gefährden wurde entschieden zunächst eine Übergangslösung auf Basis von dem bereits in betrieb-befindlichen Customer Insights Journeys zu entwickeln.
Die damit einhergehenden Restriktionen (Segment Limit und fehlende Schnittstellen) werden durch Eigenentwicklung ergänzt.
Nach der Einführung der Ziellösung wird die Übergangslösung zurückgebaut.

#### Definition Zielgruppen 

Die Übergangslösung sieht vor, das ein Zielgruppen-Admin innerhalb von Customer Insights Journeys Ansichten definiert, um Kontakte auf Basis von Felder, Beziehungen oder Merkmalen zu selektieren. Eine oder mehrere Ansichten, die letztlich Listen von Kontakten darstellen, können über eine neudefinierte "Zielgruppen" Entität referenziert wird. Über die "Zielgruppen"-Entität können zudem Ansichten verlinkt werden, deren Kontakte aus der Zielgruppe herausgefiltert werden sollen. 

#### Abruf Zielgruppen

Die Ergebnismenge an Kontakten, die sich aus dieser Zielgruppen Definition ergibt wird in regelmäßigen Abständen in eine effizient und kostengünstigen Abfrage-optimierten Struktur übertragen und per Schnittstelle bereit gestellt.

Die Customer Insights Journeys Schnittstellen werden über das API-Management der Konsumenten der Domäne Web-Portale zur Verfügung gestellt. Dabei übernimmt das API-Managment kleinere Datentransformationen, sowie die Authentifizierung für den Zugriff aufs CRM.

#### Zulieferung benötigter Daten

Daten, die für die Zielgruppen Defintion benötigt werden, müssen im Customer Insights Journeys liegen. Für einen Großteil an Daten ist diese bereits der Fall. Darüber hinaus lassen sich zwei Wege unterscheiden, wie Daten in das System eingespielt werden: Automatisiert und manuell.

##### Automatisierte Zulieferung 

Eine wichtige Zutat für die Zielgruppen Definition sind Rollengruppen. Dabei handelt es sich um eine Zusammenfassung mehrere Rechte. Ist einem Nutzer eines der Rechte einer Rollengruppe zugeordnet, gehört der Nutzer der entsprechenden Rollengruppe an. Rollengruppen und deren Rechte-Konfiguration ist ziemlich stabil. Allerdings haben wir mehrere hundert Rechteveränderungen täglich, diese auf die Rollengruppen Zugehörigkeit auswirken kann. Deswegen soll diese Rollengruppenzugehörigkeit automatisiert an das Customer Insights Journeys übertragen werden.

Die Rechte Verwaltung findet heute in der Mitarbeiterverwaltung (zukünftig Nutzerverwaltung) statt. Es gibt mit der Ladezone bereits einen etablierten Weg für die Übertragung von Mitarbeiterdaten zwischen Mitarbeiterverwaltung und Customer Insights Journeys.
Dieser Weg wird für die benötigte Zulieferung pragmatisch erweitert.
Der Datensatz, den die Mitarbeiterverwaltung an das Customer Insights Journeys im Falle von Änderungen an einem Nutzer sendet, wird um ein Feld für die Rollengruppen erweitert. Dieses Feld enthält eine Komma-separierte Liste der Namen der Rollengruppen, denen der Nutzer angehört.

Ein weiteres Merkmal welches für die Zielgruppen Definition verwendet wird, ist die an der Bank definierte Marktforschungszustimmung. Diese Zustimmung wird auch innerhalb der Mitarbeiterverwaltung durch einen Administration der Bank gepflegt. Auch dieses Feld wird über den Weg der Ladezone von der Mitarbeiterverwaltung and Customer Insights Journeys übermittelt.
Der einfachheithalb wird seitens der Mitarbeiterverwaltung das Marktforschungszustimmungs-Merkmal der Bank als Feld am Mitarbeiter übertragen, da es aktuell keinen etablierten Weg gibt Bankdaten aus der Mitarbeiterverwaltung an Customer Insights Journeys zu übertragen.

##### Manuelle Zulieferung

Werden weitere Informationen im Customer Insights Journeys benötigt und vor allem wenn diese nicht ständig (sprich mehrmals wöchtenlich oder montalich) geändert werden müssen, können diese auch manuell ins Customer Insights Journeys eingespielt werden.

Hierfür exisitert mit den Merkmalen bereits eine andere Eigenentwicklung in Customer Insights Journeys. Merkmale können zentral definiert werden und dann einem oder mehreren Kontakten zugewiesen werden. Auch ein Massenimport über Excel/CSV ist bereits möglich.

## Bausteinsicht

### Zielgruppen System Kontext

Die folgende Grafik zeigt den Kontext des Zielgruppen System.

![](embed:zielgruppen-system-context)

### Zielgruppen System Kontext Konsumenten

Die folgende Grafik zeigt den Kontext des Zielgruppen System mit Fokus auf beispielhafte Konsumenten.

![](embed:zielgruppen-system-context-konsumenten)

### Zielgruppen System Kontext MS Dynamics

Die folgende Grafik zeigt den Kontext des Zielgruppen System mit Fokus auf MS Dynamics.

![](embed:zielgruppen-system-context-msdynamics)


### Ebene 2

## Laufzeitsicht

### Abruf der Zielgruppen für einen Nutzer

Die folgende Darstellung zeigt den Abruf der Zielgruppen für den eingeloggten Nutzer.
Hierbei ist hervorzuheben, dass das konsumierende System - hier Magnolia, die Zielgruppen API mit dem Token des eingeloggten Users aufruft.
Damit nicht jeder Nutzer auf die Schnittstellen von MS Dynamics berechtigt werden muss findet Zugriff über einen technischen User statt.
Es ist Aufgabe des Zielgruppen Systems, den Token des Nutzers zu prüfen, daraus den UUKEY zu extrahieren und diesen an MS Dynmamics für die Abfrage zu schicken.

![](embed:zielgruppen-api-get-target-groups-for-user)

### Zielgruppen basierte Inhaltsausspielung

Die folgende Darstellung zeigt den Ablauf für die Zielgruppen basierte Inhaltsausspielung.

![](embed:zielgruppen-api-magnolia-content-ausspielung)

### Abruf aller Zielgruppen

Die folgende Darstellung zeigt den Ablauf für der Abruf aller Zielgruppen für den Anwendungsfall der redaktionelle Arbeit an Inhalten in Magnolia.

![](embed:zielgruppen-api-magnolia-redaktion)

## Verteilungssicht

### Ebene 1

## Querschnittliche Konzepte

### Fachliche Struktur und Modelle

### Architektur und Entwurfsmuster

### Unter-der-Haube

### User Experience

## Entwurfsentscheidungen

## Qualitätsanforderungen

### Qualitätsbaum

### Qualitätsszenarien

## Risiken und technische Schulden

## Glossar

