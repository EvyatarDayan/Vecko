//
//  AppStrings.swift
//  Vecko
//

import Foundation

enum AppStringKey {
    // Tabs
    case tabInsights, tabGoals, tabHome, tabFamily, tabSettings

    // Welcome
    case welcomeTitle1, welcomeSubtitle1
    case welcomeTitle2, welcomeSubtitle2
    case welcomeTitle3, welcomeSubtitle3
    case welcomeTitle4, welcomeSubtitle4
    case welcomeTitle5, welcomeSubtitle5
    case welcomeDontShowAgain, welcomeNext, welcomeGetStarted

    // Home
    case homeFamilyOverview
    case homeKidsCountFormat
    case homeNoKidSelected
    case homeAllowanceCard
    case homeBalanceNamedFormat
    case homeCurrentBalance
    case homeAllowanceFrequencyFormat
    case homeCardBrand
    case homeTotalBalance
    case homeNoKidsTitle
    case homeNoKidsSubtitleFamily
    case homeCurrent

    // Family list
    case familyTitle
    case familySubtitle
    case familyDeposit
    case familyWithdraw
    case familyNoKidsTitle
    case familyNoKidsSubtitle
    case familyKidsSection
    case familySelectAll
    case familyBulkAmount, familyBulkNote
    case familyBulkAmountRequired, familyBulkNoteRequired, familyBulkKidsRequired
    case familyBulkAdd, familyBulkWithdrawAction
    case familyKidRowCurrent

    // Add / edit kid
    case kidSectionInfo, kidSectionAllowance, kidSectionIcon
    case kidNamePlaceholder, kidNameRequired
    case kidWeeklyAllowancePlaceholder, kidWeeklyAllowanceRequired
    case kidDepositFrequency
    case kidDepositTime
    case kidSelectWeekdayTitle
    case kidSelectMonthDayTitle
    case kidSelectedMonthlyFormat
    case kidDailyAllowanceCaption
    case kidMonthlyInterestHeader
    case kidMonthlyInterestExplanation
    case kidSelectIcon
    case kidDelete
    case kidNavAdd, kidNavEdit
    case kidDeleteConfirmTitle
    case kidDeleteConfirmMessage
    case kidYes

    // Weekdays (full)
    case weekdaySun, weekdayMon, weekdayTue, weekdayWed, weekdayThu, weekdayFri, weekdaySat

    // Deposit frequency (display)
    case frequencyDaily, frequencyWeekly, frequencyMonthly
    case allowanceLineFormat

    // Icon picker
    case iconPickerIcons, iconPickerPhotos
    case iconPickerSelectImage, iconPickerChangeImage, iconPickerUseImage
    case iconPickerNavSelect
    case pickerSelection

    // Goals
    case goalsTitle, goalsSubtitle
    case goalsAll
    case goalsNoGoalsTitle, goalsNoGoalsSubtitle
    case goalsNoKidsTitle, goalsNoKidsSubtitle
    case goalsDeleteSwipe
    case goalsPercentCompleteFormat
    case goalsSectionGoal, goalsSectionPhoto
    case goalsPickerKid
    case goalsGoalTitlePlaceholder, goalsGoalTitleRequired
    case goalsTargetPlaceholder, goalsTargetRequired
    case goalsAddPhoto, goalsPhotoRequired
    case goalsNavNew, goalsNavEdit

    // Insights / history UI
    case insightsTitle, insightsSubtitle
    case insightsTabInsights, insightsTabHistory
    case historyEmptyTitle, historyEmptySubtitle
    case historyFilteredEmptyTitle, historyFilteredEmptySubtitle
    case insightsAll
    case insightsMonthlyOverview, insightsTotalActivity
    case insightsActiveKids, insightsDeposits, insightsWithdrawals
    case insightsInterestThisMonth
    case insightsKidsBreakdown, insightsTotal
    case insightsMonthlyCalendar
    case insightsActivityOnFormat
    case insightsClearSelection
    case insightsNoActivityDay
    case insightsNoActivityYet
    case calendarWeekdayShortFormat
    case insightsInterestByKidTitle
    case insightsGoalsByKidTitle
    case insightsGoalsCountFormat
    case insightsNoGoalsForKid
    case insightsKidHasNoGoalsFormat
    case insightsGoalsRemainingPercentFormat
    case insightsGoalsMissingAmountFormat
    case insightsInterestShareOfMonthFormat
    case insightsKidMonthlyRateFormat
    case insightsDayMovementsFormat
    case insightsDayDepositsLabel
    case insightsDayWithdrawalsLabel
    case insightsDayNetLabel
    case insightsMonthNetLabel
    case insightsNoInterestThisMonth

    // Activity categories (computed events)
    case categoryInterest, categoryDeposit, categoryWithdraw

    // Settings
    case settingsTitle, settingsSubtitle
    case settingsSectionPreferences, settingsSectionSupport, settingsSectionData
    case settingsCurrencyTitle, settingsCurrencySubtitle
    case settingsLanguageTitle, settingsLanguageSubtitle
    case settingsDarkModeTitle, settingsDarkModeSubtitle
    case settingsHelpTitle, settingsHelpSubtitle
    case settingsTermsTitle, settingsTermsSubtitle
    case settingsAboutTitle, settingsAboutSubtitle
    case settingsExportTitle, settingsExportSubtitle
    case settingsClearTitle, settingsClearSubtitle
    case settingsExportAlertTitle, settingsExportAlertMessage
    case settingsClearAlertTitle, settingsClearAlertMessage
    case settingsPlaceholderMessage
    case settingsPlaceholderNavTitle
    case settingsSheetHelpTitle, settingsSheetTermsTitle, settingsSheetAboutTitle
    case languagePickerTitle

    // Common actions
    case commonCancel, commonSave, commonDone, commonClose, commonClear, commonOK, commonSelect

    // Currency picker
    case currencySearchPrompt, currencyNavTitle

    // Misc
    case unknownKid

    // Automation notes (shown in activity / history detail context)
    case noteScheduledAllowanceFormat
    case noteMonthlyInterestFormat

    // History titles (canonical English stored; used for mapping + new rows)
    case historyKidAdded, historyKidRemoved, historyKidUpdated, historyGoalAdded
    case historyAllowancePaid, historyInterestCredited, historyDeposit, historyWithdrawal
}

enum AppStringCatalog {
    static func string(_ key: AppStringKey, language: AppLanguage) -> String {
        switch key {
        case .tabInsights: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .tabGoals: return t(language, en: "Goals", sv: "Mål", es: "Metas", fr: "Objectifs", de: "Ziele")
        case .tabHome: return t(language, en: "Home", sv: "Hem", es: "Inicio", fr: "Accueil", de: "Start")
        case .tabFamily: return t(language, en: "Family", sv: "Familj", es: "Familia", fr: "Famille", de: "Familie")
        case .tabSettings: return t(language, en: "Settings", sv: "Inställningar", es: "Ajustes", fr: "Réglages", de: "Einstellungen")

        case .welcomeTitle1: return t(language, en: "Welcome to Vecko", sv: "Välkommen till Vecko", es: "Bienvenido a Vecko", fr: "Bienvenue dans Vecko", de: "Willkommen bei Vecko")
        case .welcomeSubtitle1: return t(language, en: "Tracking allowance has never been easier.", sv: "Att följa veckopeng har aldrig varit enklare.", es: "Seguir la paga nunca había sido tan fácil.", fr: "Suivre l’argent de poche n’a jamais été aussi simple.", de: "Taschengeld im Blick zu behalten war noch nie so einfach.")
        case .welcomeTitle2: return t(language, en: "Set allowance", sv: "Ställ in veckopeng", es: "Configura la paga", fr: "Définir l’argent de poche", de: "Taschengeld festlegen")
        case .welcomeSubtitle2: return t(language, en: "Create each kid's allowance schedule in a few taps.", sv: "Skapa varje barns schema med några tryck.", es: "Crea el calendario de paga de cada niño en unos toques.", fr: "Créez le planning de chaque enfant en quelques gestes.", de: "Erstelle den Zeitplan fürs Taschengeld jedes Kindes mit wenigen Tipps.")
        case .welcomeTitle3: return t(language, en: "Track progress", sv: "Följ framsteg", es: "Sigue el progreso", fr: "Suivre la progression", de: "Fortschritt verfolgen")
        case .welcomeSubtitle3: return t(language, en: "Keep balances and transactions organized for the whole family.", sv: "Håll koll på saldon och transaktioner för hela familjen.", es: "Mantén saldos y movimientos organizados para toda la familia.", fr: "Gardez soldes et transactions clairs pour toute la famille.", de: "Behalte Salden und Buchungen für die ganze Familie im Griff.")
        case .welcomeTitle4: return t(language, en: "Set goals", sv: "Sätt mål", es: "Define metas", fr: "Fixer des objectifs", de: "Ziele setzen")
        case .welcomeSubtitle4: return t(language, en: "Add savings goals and see progress toward each target.", sv: "Lägg till sparmål och se hur nära målet barnet är.", es: "Añade metas de ahorro y mira el avance hacia cada objetivo.", fr: "Ajoutez des objectifs d’épargne et voyez la progression.", de: "Lege Sparziele an und sieh den Fortschritt je Ziel.")
        case .welcomeTitle5: return t(language, en: "See insights", sv: "Se insikter", es: "Ve información útil", fr: "Voir des analyses", de: "Einblicke gewinnen")
        case .welcomeSubtitle5: return t(language, en: "Understand spending and saving activity with clear summaries.", sv: "Förstå utgifter och sparande med tydliga sammanfattningar.", es: "Entiende gastos y ahorro con resúmenes claros.", fr: "Comprenez dépenses et épargne avec des résumés clairs.", de: "Verstehe Ausgaben und Sparen mit klaren Übersichten.")
        case .welcomeDontShowAgain: return t(language, en: "Don't show again", sv: "Visa inte igen", es: "No volver a mostrar", fr: "Ne plus afficher", de: "Nicht mehr anzeigen")
        case .welcomeNext: return t(language, en: "Next", sv: "Nästa", es: "Siguiente", fr: "Suivant", de: "Weiter")
        case .welcomeGetStarted: return t(language, en: "Get started", sv: "Kom igång", es: "Empezar", fr: "Commencer", de: "Loslegen")

        case .homeFamilyOverview: return t(language, en: "Family Overview", sv: "Familjöversikt", es: "Resumen familiar", fr: "Aperçu de la famille", de: "Familienübersicht")
        case .homeKidsCountFormat: return t(language, en: "%d kids in your account", sv: "%d barn i ditt konto", es: "%d niños en tu cuenta", fr: "%d enfants dans votre compte", de: "%d Kinder in deinem Konto")
        case .homeNoKidSelected: return t(language, en: "No kid selected", sv: "Inget barn valt", es: "Ningún niño seleccionado", fr: "Aucun enfant sélectionné", de: "Kein Kind ausgewählt")
        case .homeAllowanceCard: return t(language, en: "Allowance Card", sv: "Veckopengskort", es: "Tarjeta de paga", fr: "Carte d’argent de poche", de: "Taschengeldkarte")
        case .homeBalanceNamedFormat: return t(language, en: "%@'s balance", sv: "%@s saldo", es: "Saldo de %@", fr: "Solde de %@", de: "Guthaben von %@")
        case .homeCurrentBalance: return t(language, en: "Current balance", sv: "Aktuellt saldo", es: "Saldo actual", fr: "Solde actuel", de: "Aktuelles Guthaben")
        case .homeAllowanceFrequencyFormat: return t(language, en: "%@ allowance %@", sv: "%@ veckopeng %@", es: "Paga %@ %@", fr: "Poche %@ %@", de: "%@ Taschengeld %@")
        case .homeCardBrand: return t(language, en: "Mastercard", sv: "Mastercard", es: "Mastercard", fr: "Mastercard", de: "Mastercard")
        case .homeTotalBalance: return t(language, en: "Total balance", sv: "Totalt saldo", es: "Saldo total", fr: "Solde total", de: "Gesamtguthaben")
        case .homeNoKidsTitle: return t(language, en: "No kids yet", sv: "Inga barn ännu", es: "Aún no hay niños", fr: "Pas encore d’enfants", de: "Noch keine Kinder")
        case .homeNoKidsSubtitleFamily: return t(language, en: "Tap + in the Family tab to add your first allowance details.", sv: "Tryck på + under Familj för att lägga till ditt första veckopengs­upplägg.", es: "Toca + en Familia para añadir tu primera paga.", fr: "Appuyez sur + dans Famille pour ajouter la première allocation.", de: "Tippe in „Familie“ auf +, um dein erstes Taschengeld anzulegen.")
        case .homeCurrent: return t(language, en: "Current", sv: "Aktuellt", es: "Actual", fr: "Actuel", de: "Aktuell")

        case .familyTitle: return t(language, en: "Family", sv: "Familj", es: "Familia", fr: "Famille", de: "Familie")
        case .familySubtitle: return t(language, en: "Manage your kids’ allowance details", sv: "Hantera barnens veckopengar", es: "Gestiona los detalles de la paga", fr: "Gérez les allocations de vos enfants", de: "Verwalte die Taschengeld‑Details deiner Kinder")
        case .familyDeposit: return t(language, en: "Deposit", sv: "Sätt in", es: "Ingresar", fr: "Dépôt", de: "Einzahlen")
        case .familyWithdraw: return t(language, en: "Withdraw", sv: "Ta ut", es: "Retirar", fr: "Retrait", de: "Abheben")
        case .familyNoKidsTitle: return t(language, en: "No kids info yet", sv: "Ingen barninfo ännu", es: "Aún no hay información", fr: "Pas encore d’informations", de: "Noch keine Kinderinfos")
        case .familyNoKidsSubtitle: return t(language, en: "Tap + to add your first allowance details.", sv: "Tryck på + för att lägga till ditt första veckopengs­upplägg.", es: "Toca + para añadir tu primera paga.", fr: "Appuyez sur + pour ajouter la première allocation.", de: "Tippe auf +, um dein erstes Taschengeld anzulegen.")
        case .familyKidsSection: return t(language, en: "Kids", sv: "Barn", es: "Niños", fr: "Enfants", de: "Kinder")
        case .familySelectAll: return t(language, en: "Select all", sv: "Välj alla", es: "Seleccionar todo", fr: "Tout sélectionner", de: "Alle auswählen")
        case .familyBulkAmount: return t(language, en: "Amount", sv: "Belopp", es: "Importe", fr: "Montant", de: "Betrag")
        case .familyBulkNote: return t(language, en: "Note", sv: "Anteckning", es: "Nota", fr: "Note", de: "Notiz")
        case .familyBulkAmountRequired: return t(language, en: "Amount is required", sv: "Belopp krävs", es: "El importe es obligatorio", fr: "Le montant est requis", de: "Betrag ist erforderlich")
        case .familyBulkNoteRequired: return t(language, en: "Note is required", sv: "Anteckning krävs", es: "La nota es obligatoria", fr: "La note est requise", de: "Notiz ist erforderlich")
        case .familyBulkKidsRequired: return t(language, en: "Select at least one kid", sv: "Välj minst ett barn", es: "Selecciona al menos un niño", fr: "Sélectionnez au moins un enfant", de: "Mindestens ein Kind auswählen")
        case .familyBulkAdd: return t(language, en: "Add", sv: "Lägg till", es: "Añadir", fr: "Ajouter", de: "Hinzufügen")
        case .familyBulkWithdrawAction: return t(language, en: "Withdraw", sv: "Ta ut", es: "Retirar", fr: "Retirer", de: "Abheben")
        case .familyKidRowCurrent: return t(language, en: "Current", sv: "Aktuellt", es: "Actual", fr: "Actuel", de: "Aktuell")

        case .kidSectionInfo: return t(language, en: "Kid Information", sv: "Barnuppgifter", es: "Información del niño", fr: "Informations sur l’enfant", de: "Kind‑Informationen")
        case .kidSectionAllowance: return t(language, en: "Allowance", sv: "Veckopeng", es: "Paga", fr: "Argent de poche", de: "Taschengeld")
        case .kidSectionIcon: return t(language, en: "Icon", sv: "Ikon", es: "Icono", fr: "Icône", de: "Symbol")
        case .kidNamePlaceholder: return t(language, en: "Kid name", sv: "Barnets namn", es: "Nombre del niño", fr: "Nom de l’enfant", de: "Name des Kindes")
        case .kidNameRequired: return t(language, en: "Kid name is required", sv: "Barnets namn krävs", es: "El nombre es obligatorio", fr: "Le nom est requis", de: "Name ist erforderlich")
        case .kidWeeklyAllowancePlaceholder: return t(language, en: "Weekly allowance", sv: "Veckopeng", es: "Paga semanal", fr: "Allocation hebdomadaire", de: "Wöchentliches Taschengeld")
        case .kidWeeklyAllowanceRequired: return t(language, en: "Weekly allowance is required", sv: "Veckopeng krävs", es: "La paga semanal es obligatoria", fr: "L’allocation hebdomadaire est requise", de: "Wöchentliches Taschengeld ist erforderlich")
        case .kidDepositFrequency: return t(language, en: "Deposit frequency", sv: "Insättningsfrekvens", es: "Frecuencia de ingreso", fr: "Fréquence du versement", de: "Auszahlungsrhythmus")
        case .kidDepositTime: return t(language, en: "Deposit time", sv: "Insättningstid", es: "Hora del ingreso", fr: "Heure du versement", de: "Auszahlungszeit")
        case .kidSelectWeekdayTitle: return t(language, en: "Select day of week", sv: "Välj veckodag", es: "Elige el día de la semana", fr: "Choisir le jour de la semaine", de: "Wochentag wählen")
        case .kidSelectMonthDayTitle: return t(language, en: "Select the day of the month", sv: "Välj dag i månaden", es: "Elige el día del mes", fr: "Choisir le jour du mois", de: "Tag im Monat wählen")
        case .kidSelectedMonthlyFormat: return t(language, en: "Selected: %@ of every month", sv: "Valt: %@ varje månad", es: "Seleccionado: %@ de cada mes", fr: "Choisi : %@ chaque mois", de: "Ausgewählt: %@ jeden Monats")
        case .kidDailyAllowanceCaption: return t(language, en: "Allowance is deposited every day.", sv: "Veckopeng sätts in varje dag.", es: "La paga se ingresa cada día.", fr: "L’allocation est versée chaque jour.", de: "Das Taschengeld wird täglich gutgeschrieben.")
        case .kidMonthlyInterestHeader: return t(language, en: "Monthly interest", sv: "Månadsränta", es: "Interés mensual", fr: "Intérêts mensuels", de: "Monatszins")
        case .kidMonthlyInterestExplanation: return t(language, en: "On the 1st of each month, interest is added to this kid’s current balance (e.g. 100 at 2% → 102).", sv: "Den 1:a varje månad läggs ränta till barnets saldo (t.ex. 100 vid 2% → 102).", es: "El día 1 de cada mes se añade interés al saldo (p. ej., 100 al 2% → 102).", fr: "Le 1er de chaque mois, des intérêts sont ajoutés au solde (ex. 100 à 2% → 102).", de: "Am 1. jedes Monats wird Zins auf das Guthaben gutgeschrieben (z. B. 100 bei 2% → 102).")
        case .kidSelectIcon: return t(language, en: "Select", sv: "Välj", es: "Elegir", fr: "Choisir", de: "Auswählen")
        case .kidDelete: return t(language, en: "Delete Kid", sv: "Ta bort barn", es: "Eliminar niño", fr: "Supprimer l’enfant", de: "Kind löschen")
        case .kidNavAdd: return t(language, en: "Add Kid", sv: "Lägg till barn", es: "Añadir niño", fr: "Ajouter un enfant", de: "Kind hinzufügen")
        case .kidNavEdit: return t(language, en: "Edit Kid", sv: "Redigera barn", es: "Editar niño", fr: "Modifier l’enfant", de: "Kind bearbeiten")
        case .kidDeleteConfirmTitle: return t(language, en: "Are you sure?", sv: "Är du säker?", es: "¿Seguro?", fr: "Êtes-vous sûr ?", de: "Bist du sicher?")
        case .kidDeleteConfirmMessage: return t(language, en: "All history for this kid will be deleted. This cannot be undone.", sv: "All historik för detta barn tas bort. Detta kan inte ångras.", es: "Se borrará el historial de este niño. No se puede deshacer.", fr: "Tout l’historique de cet enfant sera supprimé. Action irréversible.", de: "Der gesamte Verlauf dieses Kindes wird gelöscht. Das kann nicht rückgängig gemacht werden.")
        case .kidYes: return t(language, en: "Yes", sv: "Ja", es: "Sí", fr: "Oui", de: "Ja")

        case .weekdaySun: return t(language, en: "Sunday", sv: "Söndag", es: "Domingo", fr: "Dimanche", de: "Sonntag")
        case .weekdayMon: return t(language, en: "Monday", sv: "Måndag", es: "Lunes", fr: "Lundi", de: "Montag")
        case .weekdayTue: return t(language, en: "Tuesday", sv: "Tisdag", es: "Martes", fr: "Mardi", de: "Dienstag")
        case .weekdayWed: return t(language, en: "Wednesday", sv: "Onsdag", es: "Miércoles", fr: "Mercredi", de: "Mittwoch")
        case .weekdayThu: return t(language, en: "Thursday", sv: "Torsdag", es: "Jueves", fr: "Jeudi", de: "Donnerstag")
        case .weekdayFri: return t(language, en: "Friday", sv: "Fredag", es: "Viernes", fr: "Vendredi", de: "Freitag")
        case .weekdaySat: return t(language, en: "Saturday", sv: "Lördag", es: "Sábado", fr: "Samedi", de: "Samstag")

        case .frequencyDaily: return t(language, en: "Daily", sv: "Dagligen", es: "Diaria", fr: "Quotidien", de: "Täglich")
        case .frequencyWeekly: return t(language, en: "Weekly", sv: "Veckovis", es: "Semanal", fr: "Hebdomadaire", de: "Wöchentlich")
        case .frequencyMonthly: return t(language, en: "Monthly", sv: "Månadsvis", es: "Mensual", fr: "Mensuel", de: "Monatlich")
        case .allowanceLineFormat: return t(language, en: "%@ allowance %@", sv: "%@ veckopeng %@", es: "Paga %@ %@", fr: "Poche %@ %@", de: "%@ Taschengeld %@")

        case .iconPickerIcons: return t(language, en: "Icons", sv: "Ikoner", es: "Iconos", fr: "Icônes", de: "Symbole")
        case .iconPickerPhotos: return t(language, en: "Photos", sv: "Foton", es: "Fotos", fr: "Photos", de: "Fotos")
        case .iconPickerSelectImage: return t(language, en: "Select image", sv: "Välj bild", es: "Elegir imagen", fr: "Choisir une image", de: "Bild auswählen")
        case .iconPickerChangeImage: return t(language, en: "Change image", sv: "Byt bild", es: "Cambiar imagen", fr: "Changer l’image", de: "Bild ändern")
        case .iconPickerUseImage: return t(language, en: "Use this image", sv: "Använd bilden", es: "Usar esta imagen", fr: "Utiliser cette image", de: "Dieses Bild verwenden")
        case .iconPickerNavSelect: return t(language, en: "Select", sv: "Välj", es: "Seleccionar", fr: "Sélectionner", de: "Auswählen")
        case .pickerSelection: return t(language, en: "Selection", sv: "Val", es: "Selección", fr: "Sélection", de: "Auswahl")

        case .goalsTitle: return t(language, en: "Goals", sv: "Mål", es: "Metas", fr: "Objectifs", de: "Ziele")
        case .goalsSubtitle: return t(language, en: "Track and edit each kid’s goals", sv: "Följ och redigera varje barns mål", es: "Sigue y edita las metas de cada niño", fr: "Suivez et modifiez les objectifs de chaque enfant", de: "Ziele jedes Kindes verfolgen und bearbeiten")
        case .goalsAll: return t(language, en: "All", sv: "Alla", es: "Todos", fr: "Tous", de: "Alle")
        case .goalsNoGoalsTitle: return t(language, en: "No goals yet", sv: "Inga mål ännu", es: "Aún no hay metas", fr: "Pas encore d’objectifs", de: "Noch keine Ziele")
        case .goalsNoGoalsSubtitle: return t(language, en: "Add a goal and track progress by balance.", sv: "Lägg till ett mål och följ hur saldot rör sig mot målet.", es: "Añade una meta y mira el avance según el saldo.", fr: "Ajoutez un objectif et suivez la progression via le solde.", de: "Lege ein Ziel an und verfolge den Fortschritt am Guthaben.")
        case .goalsNoKidsTitle: return t(language, en: "No kids yet", sv: "Inga barn ännu", es: "Aún no hay niños", fr: "Pas encore d’enfants", de: "Noch keine Kinder")
        case .goalsNoKidsSubtitle: return t(language, en: "Add a kid in Family before creating goals.", sv: "Lägg till ett barn under Familj innan du skapar mål.", es: "Añade un niño en Familia antes de crear metas.", fr: "Ajoutez un enfant dans Famille avant de créer des objectifs.", de: "Füge unter „Familie“ ein Kind hinzu, bevor du Ziele anlegst.")
        case .goalsDeleteSwipe: return t(language, en: "Delete", sv: "Ta bort", es: "Eliminar", fr: "Supprimer", de: "Löschen")
        case .goalsPercentCompleteFormat: return t(language, en: "%d%% complete", sv: "%d%% klart", es: "%d%% completado", fr: "%d%% terminé", de: "%d%% erledigt")
        case .goalsSectionGoal: return t(language, en: "Goal", sv: "Mål", es: "Meta", fr: "Objectif", de: "Ziel")
        case .goalsSectionPhoto: return t(language, en: "Photo", sv: "Foto", es: "Foto", fr: "Photo", de: "Foto")
        case .goalsPickerKid: return t(language, en: "Kid", sv: "Barn", es: "Niño", fr: "Enfant", de: "Kind")
        case .goalsGoalTitlePlaceholder: return t(language, en: "Goal title", sv: "Måltitel", es: "Título de la meta", fr: "Titre de l’objectif", de: "Zieltitel")
        case .goalsGoalTitleRequired: return t(language, en: "Goal title is required", sv: "Måltitel krävs", es: "El título es obligatorio", fr: "Le titre est requis", de: "Titel ist erforderlich")
        case .goalsTargetPlaceholder: return t(language, en: "Target amount", sv: "Målbelopp", es: "Importe objetivo", fr: "Montant cible", de: "Zielbetrag")
        case .goalsTargetRequired: return t(language, en: "Target amount is required", sv: "Målbelopp krävs", es: "El importe objetivo es obligatorio", fr: "Le montant cible est requis", de: "Zielbetrag ist erforderlich")
        case .goalsAddPhoto: return t(language, en: "Add photo", sv: "Lägg till foto", es: "Añadir foto", fr: "Ajouter une photo", de: "Foto hinzufügen")
        case .goalsPhotoRequired: return t(language, en: "Photo or icon is required", sv: "Foto eller ikon krävs", es: "Se requiere foto o icono", fr: "Photo ou icône requise", de: "Foto oder Symbol erforderlich")
        case .goalsNavNew: return t(language, en: "New Goal", sv: "Nytt mål", es: "Nueva meta", fr: "Nouvel objectif", de: "Neues Ziel")
        case .goalsNavEdit: return t(language, en: "Edit Goal", sv: "Redigera mål", es: "Editar meta", fr: "Modifier l’objectif", de: "Ziel bearbeiten")

        case .insightsTitle: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .insightsSubtitle: return t(language, en: "Review activity, history, and trends", sv: "Se aktivitet, historik och trender", es: "Revisa actividad, historial y tendencias", fr: "Consultez l’activité, l’historique et les tendances", de: "Aktivität, Verlauf und Trends ansehen")
        case .insightsTabInsights: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .insightsTabHistory: return t(language, en: "History", sv: "Historik", es: "Historial", fr: "Historique", de: "Verlauf")
        case .historyEmptyTitle: return t(language, en: "No history yet", sv: "Ingen historik ännu", es: "Aún no hay historial", fr: "Pas encore d’historique", de: "Noch kein Verlauf")
        case .historyEmptySubtitle: return t(language, en: "Kid changes will appear here.", sv: "Ändringar om barn visas här.", es: "Los cambios de niños aparecerán aquí.", fr: "Les changements liés aux enfants apparaîtront ici.", de: "Änderungen zu Kindern erscheinen hier.")
        case .historyFilteredEmptyTitle: return t(language, en: "No history for this kid", sv: "Ingen historik för detta barn", es: "Sin historial para este niño", fr: "Pas d’historique pour cet enfant", de: "Kein Verlauf für dieses Kind")
        case .historyFilteredEmptySubtitle: return t(language, en: "Try another filter.", sv: "Prova ett annat filter.", es: "Prueba otro filtro.", fr: "Essayez un autre filtre.", de: "Probier einen anderen Filter.")
        case .insightsAll: return t(language, en: "All", sv: "Alla", es: "Todos", fr: "Tous", de: "Alle")
        case .insightsMonthlyOverview: return t(language, en: "Monthly Overview", sv: "Månadsöversikt", es: "Resumen mensual", fr: "Aperçu mensuel", de: "Monatsübersicht")
        case .insightsTotalActivity: return t(language, en: "Total activity", sv: "Total aktivitet", es: "Actividad total", fr: "Activité totale", de: "Gesamtaktivität")
        case .insightsActiveKids: return t(language, en: "Active kids", sv: "Aktiva barn", es: "Niños activos", fr: "Enfants actifs", de: "Aktive Kinder")
        case .insightsDeposits: return t(language, en: "Deposits", sv: "Insättningar", es: "Ingresos", fr: "Dépôts", de: "Einzahlungen")
        case .insightsWithdrawals: return t(language, en: "Withdrawals", sv: "Uttag", es: "Retiros", fr: "Retraits", de: "Auszahlungen")
        case .insightsInterestThisMonth: return t(language, en: "Interest this month", sv: "Ränta denna månad", es: "Intereses este mes", fr: "Intérêts ce mois-ci", de: "Zinsen diesen Monat")
        case .insightsKidsBreakdown: return t(language, en: "Balance", sv: "Saldo", es: "Balance", fr: "Solde", de: "Saldo")
        case .insightsTotal: return t(language, en: "Total", sv: "Totalt", es: "Total", fr: "Total", de: "Gesamt")
        case .insightsMonthlyCalendar: return t(language, en: "Monthly Calendar", sv: "Månadskalender", es: "Calendario mensual", fr: "Calendrier mensuel", de: "Monatskalender")
        case .insightsActivityOnFormat: return t(language, en: "Activity on %@", sv: "Aktivitet den %@", es: "Actividad el %@", fr: "Activité du %@", de: "Aktivität am %@")
        case .insightsClearSelection: return t(language, en: "Clear", sv: "Rensa", es: "Borrar", fr: "Effacer", de: "Zurücksetzen")
        case .insightsNoActivityDay: return t(language, en: "No allowance activity on this day", sv: "Ingen veckopengsaktivitet denna dag", es: "Sin actividad de paga este día", fr: "Pas d’activité d’allocation ce jour-là", de: "Keine Taschengeld‑Aktivität an diesem Tag")
        case .insightsNoActivityYet: return t(language, en: "No activity yet", sv: "Ingen aktivitet ännu", es: "Aún no hay actividad", fr: "Pas encore d’activité", de: "Noch keine Aktivität")
        case .calendarWeekdayShortFormat: return t(language, en: "EEE", sv: "EEE", es: "EEE", fr: "EEE", de: "EEE")
        case .insightsInterestByKidTitle: return t(language, en: "Interest", sv: "Ränta", es: "Intereses", fr: "Intérêts", de: "Zinsen")
        case .insightsGoalsByKidTitle: return t(language, en: "Goals", sv: "Mål", es: "Metas", fr: "Objectifs", de: "Ziele")
        case .insightsGoalsCountFormat: return t(language, en: "%d goals", sv: "%d mål", es: "%d metas", fr: "%d objectifs", de: "%d Ziele")
        case .insightsNoGoalsForKid: return t(language, en: "No goals", sv: "Inga mål", es: "Sin metas", fr: "Pas d’objectif", de: "Keine Ziele")
        case .insightsKidHasNoGoalsFormat: return t(language, en: "%@ has no goals", sv: "%@ har inga mål", es: "%@ no tiene metas", fr: "%@ n’a pas d’objectif", de: "%@ hat keine Ziele")
        case .insightsGoalsRemainingPercentFormat: return t(language, en: "Only %d%% to go", sv: "Bara %d%% kvar", es: "Solo falta %d%%", fr: "Plus que %d%%", de: "Nur noch %d%%")
        case .insightsGoalsMissingAmountFormat: return t(language, en: "Missing only %@", sv: "Saknas bara %@", es: "Faltan solo %@", fr: "Il manque seulement %@", de: "Es fehlen nur %@")
        case .insightsInterestShareOfMonthFormat: return t(language, en: "%d%% of month interest", sv: "%d%% av månadens ränta", es: "%d%% del interés del mes", fr: "%d%% des intérêts du mois", de: "%d%% der Monatszinsen")
        case .insightsKidMonthlyRateFormat: return t(language, en: "%@ gets %d%% monthly", sv: "%@ får %d%% månadsvis", es: "%@ recibe %d%% mensual", fr: "%@ reçoit %d%% par mois", de: "%@ bekommt %d%% monatlich")
        case .insightsDayMovementsFormat: return t(language, en: "%d movements", sv: "%d händelser", es: "%d movimientos", fr: "%d mouvements", de: "%d Buchungen")
        case .insightsDayDepositsLabel: return t(language, en: "In", sv: "In", es: "Entradas", fr: "Entrées", de: "Eingehend")
        case .insightsDayWithdrawalsLabel: return t(language, en: "Out", sv: "Ut", es: "Salidas", fr: "Sorties", de: "Ausgehend")
        case .insightsDayNetLabel: return t(language, en: "Net", sv: "Netto", es: "Neto", fr: "Net", de: "Saldo")
        case .insightsMonthNetLabel: return t(language, en: "Month net (in − out)", sv: "Mån netto (in − ut)", es: "Neto del mes (entradas − salidas)", fr: "Net du mois (entrées − sorties)", de: "Monatsnetto (Ein − Aus)")
        case .insightsNoInterestThisMonth: return t(language, en: "No interest credited this month", sv: "Ingen ränta denna månad", es: "Sin intereses este mes", fr: "Pas d’intérêts ce mois-ci", de: "Keine Zinsen in diesem Monat")

        case .categoryInterest: return t(language, en: "Interest", sv: "Ränta", es: "Interés", fr: "Intérêts", de: "Zins")
        case .categoryDeposit: return t(language, en: "Deposit", sv: "Insättning", es: "Ingreso", fr: "Dépôt", de: "Einzahlung")
        case .categoryWithdraw: return t(language, en: "Withdraw", sv: "Uttag", es: "Retiro", fr: "Retrait", de: "Auszahlung")

        case .settingsTitle: return t(language, en: "Settings", sv: "Inställningar", es: "Ajustes", fr: "Réglages", de: "Einstellungen")
        case .settingsSubtitle: return t(language, en: "Customize your app preferences", sv: "Anpassa appinställningar", es: "Personaliza las preferencias", fr: "Personnalisez vos préférences", de: "Passe die App‑Einstellungen an")
        case .settingsSectionPreferences: return t(language, en: "Preferences", sv: "Inställningar", es: "Preferencias", fr: "Préférences", de: "Einstellungen")
        case .settingsSectionSupport: return t(language, en: "Support", sv: "Support", es: "Soporte", fr: "Assistance", de: "Support")
        case .settingsSectionData: return t(language, en: "Data Management", sv: "Datahantering", es: "Gestión de datos", fr: "Données", de: "Datenverwaltung")
        case .settingsCurrencyTitle: return t(language, en: "Currency", sv: "Valuta", es: "Moneda", fr: "Devise", de: "Währung")
        case .settingsCurrencySubtitle: return t(language, en: "Choose your default currency", sv: "Välj standardvaluta", es: "Elige tu moneda predeterminada", fr: "Choisissez la devise par défaut", de: "Standardwährung wählen")
        case .settingsLanguageTitle: return t(language, en: "Language", sv: "Språk", es: "Idioma", fr: "Langue", de: "Sprache")
        case .settingsLanguageSubtitle: return t(language, en: "Change app language", sv: "Byt appspråk", es: "Cambiar el idioma de la app", fr: "Changer la langue de l’app", de: "App‑Sprache ändern")
        case .settingsDarkModeTitle: return t(language, en: "Dark mode", sv: "Mörkt läge", es: "Modo oscuro", fr: "Mode sombre", de: "Dunkelmodus")
        case .settingsDarkModeSubtitle: return t(language, en: "Toggle appearance", sv: "Byt utseende", es: "Cambiar apariencia", fr: "Changer l’apparence", de: "Darstellung umschalten")
        case .settingsHelpTitle: return t(language, en: "Help & Support", sv: "Hjälp och support", es: "Ayuda y soporte", fr: "Aide et support", de: "Hilfe & Support")
        case .settingsHelpSubtitle: return t(language, en: "Get help using Vecko", sv: "Få hjälp med Vecko", es: "Obtén ayuda con Vecko", fr: "Obtenir de l’aide sur Vecko", de: "Hilfe bei Vecko")
        case .settingsTermsTitle: return t(language, en: "Terms & Privacy", sv: "Villkor och integritet", es: "Términos y privacidad", fr: "Conditions et confidentialité", de: "AGB & Datenschutz")
        case .settingsTermsSubtitle: return t(language, en: "Legal information", sv: "Juridisk information", es: "Información legal", fr: "Informations légales", de: "Rechtliches")
        case .settingsAboutTitle: return t(language, en: "About", sv: "Om", es: "Acerca de", fr: "À propos", de: "Über")
        case .settingsAboutSubtitle: return t(language, en: "App info", sv: "Appinfo", es: "Info de la app", fr: "Infos sur l’app", de: "App‑Infos")
        case .settingsExportTitle: return t(language, en: "Export data", sv: "Exportera data", es: "Exportar datos", fr: "Exporter les données", de: "Daten exportieren")
        case .settingsExportSubtitle: return t(language, en: "Export to a PDF file", sv: "Exportera till en PDF-fil", es: "Exportar a un archivo PDF", fr: "Exporter vers un fichier PDF", de: "In eine PDF-Datei exportieren")
        case .settingsClearTitle: return t(language, en: "Clear all data", sv: "Rensa all data", es: "Borrar todos los datos", fr: "Effacer toutes les données", de: "Alle Daten löschen")
        case .settingsClearSubtitle: return t(language, en: "Delete all app data", sv: "Ta bort all appdata", es: "Eliminar todos los datos de la app", fr: "Supprimer toutes les données de l’app", de: "Alle App-Daten löschen")
        case .settingsExportAlertTitle: return t(language, en: "Export data", sv: "Exportera data", es: "Exportar datos", fr: "Exporter les données", de: "Daten exportieren")
        case .settingsExportAlertMessage: return t(language, en: "This is a placeholder. Export will be connected later.", sv: "Detta är en placeholder. Export kopplas på senare.", es: "Esto es una demostración. La exportación llegará después.", fr: "Ceci est un emplacement. L’export viendra plus tard.", de: "Das ist nur ein Platzhalter. Export folgt später.")
        case .settingsClearAlertTitle: return t(language, en: "Clear all data?", sv: "Rensa all data?", es: "¿Borrar todos los datos?", fr: "Effacer toutes les données ?", de: "Alle Daten löschen?")
        case .settingsClearAlertMessage: return t(language, en: "This is a placeholder. Clearing data will be connected later.", sv: "Detta är en placeholder. Radering kopplas på senare.", es: "Esto es una demostración. El borrado llegará después.", fr: "Ceci est un emplacement. La suppression viendra plus tard.", de: "Das ist nur ein Platzhalter. Löschen folgt später.")
        case .settingsPlaceholderMessage: return t(language, en: "This screen is a placeholder.", sv: "Den här skärmen är en placeholder.", es: "Esta pantalla es temporal.", fr: "Cet écran est temporaire.", de: "Dieser Bildschirm ist ein Platzhalter.")
        case .settingsPlaceholderNavTitle: return t(language, en: "Preview", sv: "Förhandsvisning", es: "Vista previa", fr: "Aperçu", de: "Vorschau")
        case .settingsSheetHelpTitle: return t(language, en: "Help & Support", sv: "Hjälp och support", es: "Ayuda y soporte", fr: "Aide et support", de: "Hilfe & Support")
        case .settingsSheetTermsTitle: return t(language, en: "Terms & Privacy", sv: "Villkor och integritet", es: "Términos y privacidad", fr: "Conditions et confidentialité", de: "AGB & Datenschutz")
        case .settingsSheetAboutTitle: return t(language, en: "About Vecko", sv: "Om Vecko", es: "Acerca de Vecko", fr: "À propos de Vecko", de: "Über Vecko")
        case .languagePickerTitle: return t(language, en: "Language", sv: "Språk", es: "Idioma", fr: "Langue", de: "Sprache")

        case .commonCancel: return t(language, en: "Cancel", sv: "Avbryt", es: "Cancelar", fr: "Annuler", de: "Abbrechen")
        case .commonSave: return t(language, en: "Save", sv: "Spara", es: "Guardar", fr: "Enregistrer", de: "Speichern")
        case .commonDone: return t(language, en: "Done", sv: "Klar", es: "Listo", fr: "OK", de: "Fertig")
        case .commonClose: return t(language, en: "Close", sv: "Stäng", es: "Cerrar", fr: "Fermer", de: "Schließen")
        case .commonClear: return t(language, en: "Clear", sv: "Rensa", es: "Borrar", fr: "Effacer", de: "Löschen")
        case .commonOK: return t(language, en: "OK", sv: "OK", es: "OK", fr: "OK", de: "OK")
        case .commonSelect: return t(language, en: "Select", sv: "Välj", es: "Seleccionar", fr: "Sélectionner", de: "Auswählen")

        case .currencySearchPrompt: return t(language, en: "Search currency", sv: "Sök valuta", es: "Buscar moneda", fr: "Rechercher une devise", de: "Währung suchen")
        case .currencyNavTitle: return t(language, en: "Select Currency", sv: "Välj valuta", es: "Elegir moneda", fr: "Choisir la devise", de: "Währung wählen")

        case .unknownKid: return t(language, en: "Unknown kid", sv: "Okänt barn", es: "Niño desconocido", fr: "Enfant inconnu", de: "Unbekanntes Kind")

        case .noteScheduledAllowanceFormat: return t(language, en: "Scheduled allowance (%@)", sv: "Schemalagd veckopeng (%@)", es: "Paga programada (%@)", fr: "Allocation planifiée (%@)", de: "Geplantes Taschengeld (%@)")
        case .noteMonthlyInterestFormat: return t(language, en: "Monthly interest (%d%%)", sv: "Månadsränta (%d%%)", es: "Interés mensual (%d%%)", fr: "Intérêts mensuels (%d%%)", de: "Monatszins (%d%%)")

        case .historyKidAdded: return t(language, en: "Kid added", sv: "Barn tillagt", es: "Niño añadido", fr: "Enfant ajouté", de: "Kind hinzugefügt")
        case .historyKidRemoved: return t(language, en: "Kid removed", sv: "Barn borttaget", es: "Niño eliminado", fr: "Enfant supprimé", de: "Kind entfernt")
        case .historyKidUpdated: return t(language, en: "Kid updated", sv: "Barn uppdaterat", es: "Niño actualizado", fr: "Enfant mis à jour", de: "Kind aktualisiert")
        case .historyGoalAdded: return t(language, en: "Goal added", sv: "Mål tillagt", es: "Meta añadida", fr: "Objectif ajouté", de: "Ziel hinzugefügt")
        case .historyAllowancePaid: return t(language, en: "Allowance paid", sv: "Veckopeng utbetald", es: "Paga abonada", fr: "Allocation versée", de: "Taschengeld gutgeschrieben")
        case .historyInterestCredited: return t(language, en: "Interest credited", sv: "Ränta tillagd", es: "Interés abonado", fr: "Intérêts crédités", de: "Zins gutgeschrieben")
        case .historyDeposit: return t(language, en: "Deposit", sv: "Insättning", es: "Ingreso", fr: "Dépôt", de: "Einzahlung")
        case .historyWithdrawal: return t(language, en: "Withdrawal", sv: "Uttag", es: "Retiro", fr: "Retrait", de: "Auszahlung")
        }
    }

    static func localizedHistoryTitle(storedTitle: String, language: AppLanguage) -> String {
        switch storedTitle {
        case "Kid added": return string(.historyKidAdded, language: language)
        case "Kid removed": return string(.historyKidRemoved, language: language)
        case "Kid updated": return string(.historyKidUpdated, language: language)
        case "Goal added": return string(.historyGoalAdded, language: language)
        case "Allowance paid": return string(.historyAllowancePaid, language: language)
        case "Interest credited": return string(.historyInterestCredited, language: language)
        case "Deposit": return string(.historyDeposit, language: language)
        case "Withdrawal": return string(.historyWithdrawal, language: language)
        default: return storedTitle
        }
    }

    static func displayDepositFrequency(_ frequency: DepositFrequency, language: AppLanguage) -> String {
        switch frequency {
        case .daily: return string(.frequencyDaily, language: language)
        case .weekly: return string(.frequencyWeekly, language: language)
        case .monthly: return string(.frequencyMonthly, language: language)
        }
    }

    private static func t(
        _ language: AppLanguage,
        en: String,
        sv: String,
        es: String,
        fr: String,
        de: String
    ) -> String {
        switch language {
        case .english: return en
        case .swedish: return sv
        case .spanish: return es
        case .french: return fr
        case .german: return de
        }
    }
}
