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
    case homeNavEdit
    case homeNoKidSelected
    case homeAllowanceCard
    case homeBalanceNamedFormat
    case homeCurrentBalance
    case homeAllowanceFrequencyFormat
    case homeKidAllowancePerWeekLineFormat, homeKidAllowancePerMonthLineFormat
    case homeCardBrand
    case homeTotalBalance
    case homeNoKidsTitle
    case homeNoKidsSubtitleFamily

    // Family list
    case familyTitle
    case familySubtitle
    case familyDeposit
    case familyWithdraw
    case familyNoKidsTitle
    case familyNoKidsSubtitle
    case familyKidsSection
    case familySelectKids
    case familySelectAll
    case familyBulkAmount, familyBulkNote
    case familyBulkNotePlaceholderDeposit, familyBulkNotePlaceholderWithdraw
    case familyBulkAmountRequired, familyBulkNoteRequired, familyBulkKidsRequired
    case familyBulkNoteRequiredDeposit, familyBulkNoteRequiredWithdraw
    case familyBulkAdd, familyBulkWithdrawAction

    // Add / edit kid
    case kidSectionDetails, kidSectionAllowance, kidSectionSchedule
    case kidBirthday, kidBirthdayToday
    case kidNamePlaceholder, kidNameRequired
    case kidWeeklyAllowancePlaceholder, kidWeeklyAllowanceRequired
    case kidDepositFrequency
    case kidDepositTime
    case kidMonthlyInterestHeader
    case kidSelectIcon
    case kidProfileTapPhoto
    case kidDelete
    case kidNavAdd, kidNavEdit
    case kidDeleteConfirmTitle
    case kidDeleteConfirmMessage
    case kidYes

    // Weekdays (full)
    case weekdaySun, weekdayMon, weekdayTue, weekdayWed, weekdayThu, weekdayFri, weekdaySat

    // Deposit frequency (display)
    case frequencyWeekly, frequencyMonthly
    case allowanceLineFormat

    // Icon picker
    case iconPickerIcons, iconPickerPhotos
    case iconPickerSelectImage, iconPickerChangeImage
    case iconPickerNavSelect
    case pickerSelection

    // Goals
    case goalsTitle, goalsSubtitle
    case goalsAll
    case goalsNoGoalsTitle, goalsNoGoalsSubtitle
    case goalsNoGoalsForKidTitleFormat, goalsNoGoalsForKidSubtitleFormat
    case goalsNoKidsTitle, goalsNoKidsSubtitle
    case goalsDeleteSwipe
    case goalsKidPossessiveGoalFormat
    case goalsPercentCompleteFormat
    case goalsTimeToGoToday
    case goalsTimeToGoOneDay
    case goalsTimeToGoDaysFormat
    case goalsTimeToGoOneWeek
    case goalsTimeToGoWeeksFormat
    case goalsTimeToGoOneMonth
    case goalsTimeToGoMonthsFormat
    case goalsTimeToGoReached
    case goalsTimeToGoNoAllowance
    case goalsTimeToGoBeyondHorizon
    case goalsSectionGoal, goalsSectionPhoto
    case goalsCost, goalsGoalName, goalsSelectKid, goalsKidRequired
    case goalsPickerKid
    case goalsGoalTitlePlaceholder, goalsGoalTitleRequired
    case goalsTargetPlaceholder, goalsTargetRequired
    case goalsAddPhoto, goalsPhotoRequired
    case goalsNavNew, goalsNavEdit
    case goalsDeleteFromDetail, goalsDeleteGoalConfirmTitle, goalsDeleteGoalConfirmMessage
    case goalsDetailInfoAccessibility

    // Insights / history UI
    case insightsTitle, insightsSubtitle
    case insightsTabInsights, insightsTabHistory
    case historyEmptyTitle, historyEmptySubtitle
    case historyFilteredEmptyTitle, historyFilteredEmptySubtitle
    case historySubtitle
    case historyGotIt
    case insightsAll
    case insightsMonthlyOverview, insightsTotalActivity
    case insightsActiveKids, insightsDeposits, insightsWithdrawals
    case insightsInterestThisMonth
    case insightsKidsBreakdown, insightsTotal
    case insightsMonthlyCalendar
    case insightsActivityOnFormat
    case insightsClearSelection
    case insightsNoActivityDay
    case insightsCategoryExpectedAllowance
    case insightsExpectedAmountFormat
    case insightsNoActivityYet
    case calendarWeekdayShortFormat
    case insightsInterestByKidTitle
    case insightsFactsTitle
    case insightsFactsEmpty
    case insightsFactsTip
    case insightsFactBirthdayToday
    case insightsFactMonthInterest
    case insightsFactMonthDeposits
    case insightsFactMonthWithdrawals
    case insightsFactMonthNetPositive
    case insightsFactMonthNetNegative
    case insightsFactBiggestSpender
    case insightsFactBiggestSaver
    case insightsFactWeekDeposits
    case insightsFactGoalReached
    case insightsFactGoalReachedThisWeek
    case insightsFactGoalAlmost
    case insightsFactGoalAlmostLead
    case insightsFactGoalAlmostTrail
    case insightsFactTopBalanceKid
    case insightsFactFamilyBalance
    case insightsFactActiveGoals
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
    case settingsClearHistoryTitle, settingsClearHistorySubtitle
    case settingsClearHistoryAlertTitle, settingsClearHistoryAlertMessage
    case settingsClearTitle, settingsClearSubtitle
    case settingsExportAlertTitle, settingsExportAlertMessage
    case settingsClearAlertTitle, settingsClearAlertMessage
    case settingsSheetHelpTitle, settingsSheetTermsTitle, settingsSheetAboutTitle
    case settingsSupportBackHeaderHelp
    case settingsSupportIntroTitle, settingsSupportIntroLine1, settingsSupportIntroLine2, settingsSupportIntroLine3
    case settingsSupportEmailLabel, settingsSupportWebsiteLabel
    case settingsSupportOr, settingsSupportContactForm, settingsSupportAimRespond
    case settingsSupportNavContact
    case settingsSupportSectionFullName, settingsSupportPlaceholderFullName
    case settingsSupportSectionYourEmail, settingsSupportPlaceholderYourEmail
    case settingsSupportSectionSubject, settingsSupportSectionDescription
    case settingsSupportSend, settingsSupportAllRequired
    case settingsSupportAlertSentTitle, settingsSupportAlertSentMessage
    case settingsSupportAlertMailFail
    case settingsLegalTabTerms, settingsLegalTabPrivacy, settingsLegalTabDisclaimer
    case settingsAboutBody, settingsAboutVersionFormat
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
    case historyAllowancePaid, historyWeeklyAllowancePaidDetailTitle
    case historyInterestCredited, historyInterestCreditedDetailFormat
    case historyDeposit, historyWithdrawal, historyKidBirthday
    case historyKidUpdateNameFormat, historyKidUpdateAllowanceFormat, historyKidUpdateInterestFormat
    case historyKidUpdatePayDayFormat, historyKidUpdateDepositTimeFormat, historyKidUpdateBirthdayFormat
    case historyKidUpdatePhotoFormat
}

enum AppStringCatalog {
    static func string(_ key: AppStringKey, language: AppLanguage) -> String {
        switch key {
        case .tabInsights: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .tabGoals: return t(language, en: "Goals", sv: "Mål", es: "Metas", fr: "Objectifs", de: "Ziele")
        case .tabHome: return t(language, en: "Home", sv: "Hem", es: "Inicio", fr: "Accueil", de: "Start")
        case .tabFamily: return t(language, en: "History", sv: "Historik", es: "Historial", fr: "Historique", de: "Verlauf")
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

        case .homeFamilyOverview: return t(language, en: "Kids Accounts", sv: "Barnkonton", es: "Cuentas de los niños", fr: "Comptes des enfants", de: "Kinderkonten")
        case .homeNavEdit: return t(language, en: "Edit", sv: "Redigera", es: "Editar", fr: "Modifier", de: "Bearbeiten")
        case .homeNoKidSelected: return t(language, en: "No kid selected", sv: "Inget barn valt", es: "Ningún niño seleccionado", fr: "Aucun enfant sélectionné", de: "Kein Kind ausgewählt")
        case .homeAllowanceCard: return t(language, en: "Allowance Card", sv: "Veckopengskort", es: "Tarjeta de paga", fr: "Carte d’argent de poche", de: "Taschengeldkarte")
        case .homeBalanceNamedFormat: return t(language, en: "%@'s balance", sv: "%@s saldo", es: "Saldo de %@", fr: "Solde de %@", de: "Guthaben von %@")
        case .homeCurrentBalance: return t(language, en: "Current balance", sv: "Aktuellt saldo", es: "Saldo actual", fr: "Solde actuel", de: "Aktuelles Guthaben")
        case .homeAllowanceFrequencyFormat: return t(language, en: "%@ %@", sv: "%@ %@", es: "%@ %@", fr: "%@ %@", de: "%@ %@")
        case .homeKidAllowancePerWeekLineFormat: return t(language, en: "%@ / week", sv: "%@ / vecka", es: "%@ / semana", fr: "%@ / semaine", de: "%@ / Woche")
        case .homeKidAllowancePerMonthLineFormat: return t(language, en: "%@ / month", sv: "%@ / månad", es: "%@ / mes", fr: "%@ / mois", de: "%@ / Monat")
        case .homeCardBrand: return t(language, en: "Mastercard", sv: "Mastercard", es: "Mastercard", fr: "Mastercard", de: "Mastercard")
        case .homeTotalBalance: return t(language, en: "Total balance", sv: "Totalt saldo", es: "Saldo total", fr: "Solde total", de: "Gesamtguthaben")
        case .homeNoKidsTitle: return t(language, en: "No kids yet", sv: "Inga barn ännu", es: "Aún no hay niños", fr: "Pas encore d’enfants", de: "Noch keine Kinder")
        case .homeNoKidsSubtitleFamily: return t(language, en: "Tap + in the Family tab to add your first allowance details.", sv: "Tryck på + under Familj för att lägga till ditt första veckopengs­upplägg.", es: "Toca + en Familia para añadir tu primera paga.", fr: "Appuyez sur + dans Famille pour ajouter la première allocation.", de: "Tippe in „Familie“ auf +, um dein erstes Taschengeld anzulegen.")

        case .familyTitle: return t(language, en: "History", sv: "Historik", es: "Historial", fr: "Historique", de: "Verlauf")
        case .familySubtitle: return t(language, en: "All changes and transactions for your kids", sv: "Alla ändringar och transaktioner för dina barn", es: "Todos los cambios y transacciones de tus niños", fr: "Tous les changements et transactions pour vos enfants", de: "Alle Änderungen und Transaktionen für deine Kinder")
        case .familyDeposit: return t(language, en: "Deposit", sv: "Sätt in", es: "Ingresar", fr: "Dépôt", de: "Einzahlen")
        case .familyWithdraw: return t(language, en: "Withdraw", sv: "Ta ut", es: "Retirar", fr: "Retrait", de: "Abheben")
        case .familyNoKidsTitle: return t(language, en: "No kids info yet", sv: "Ingen barninfo ännu", es: "Aún no hay información", fr: "Pas encore d’informations", de: "Noch keine Kinderinfos")
        case .familyNoKidsSubtitle: return t(language, en: "Tap + to add your first allowance details.", sv: "Tryck på + för att lägga till ditt första veckopengs­upplägg.", es: "Toca + para añadir tu primera paga.", fr: "Appuyez sur + pour ajouter la première allocation.", de: "Tippe auf +, um dein erstes Taschengeld anzulegen.")
        case .familyKidsSection: return t(language, en: "Kids", sv: "Barn", es: "Niños", fr: "Enfants", de: "Kinder")
        case .familySelectKids: return t(language, en: "Select kids", sv: "Välj barn", es: "Seleccionar niños", fr: "Sélectionner des enfants", de: "Kinder auswählen")
        case .familySelectAll: return t(language, en: "Select all", sv: "Välj alla", es: "Seleccionar todo", fr: "Tout sélectionner", de: "Alle auswählen")
        case .familyBulkAmount: return t(language, en: "Amount", sv: "Belopp", es: "Importe", fr: "Montant", de: "Betrag")
        case .familyBulkNote: return t(language, en: "Note", sv: "Anteckning", es: "Nota", fr: "Note", de: "Notiz")
        case .familyBulkNotePlaceholderDeposit: return t(language, en: "Reason for deposit", sv: "Anledning till insättning", es: "Motivo del ingreso", fr: "Motif du dépôt", de: "Grund für die Einzahlung")
        case .familyBulkNotePlaceholderWithdraw: return t(language, en: "Reason for Withdraw", sv: "Anledning till uttag", es: "Motivo del retiro", fr: "Motif du retrait", de: "Grund für die Abhebung")
        case .familyBulkAmountRequired: return t(language, en: "Amount is required", sv: "Belopp krävs", es: "El importe es obligatorio", fr: "Le montant est requis", de: "Betrag ist erforderlich")
        case .familyBulkNoteRequired: return t(language, en: "Note is required", sv: "Anteckning krävs", es: "La nota es obligatoria", fr: "La note est requise", de: "Notiz ist erforderlich")
        case .familyBulkNoteRequiredDeposit: return t(language, en: "Reason for deposit is required", sv: "Anledning till insättning krävs", es: "El motivo del ingreso es obligatorio", fr: "Le motif du dépôt est requis", de: "Grund für die Einzahlung ist erforderlich")
        case .familyBulkNoteRequiredWithdraw: return t(language, en: "Reason for Withdraw is required", sv: "Anledning till uttag krävs", es: "El motivo del retiro es obligatorio", fr: "Le motif du retrait est requis", de: "Grund für die Abhebung ist erforderlich")
        case .familyBulkKidsRequired: return t(language, en: "Select at least one kid", sv: "Välj minst ett barn", es: "Selecciona al menos un niño", fr: "Sélectionnez au moins un enfant", de: "Mindestens ein Kind auswählen")
        case .familyBulkAdd: return t(language, en: "Deposit", sv: "Sätt in", es: "Ingresar", fr: "Dépôt", de: "Einzahlen")
        case .familyBulkWithdrawAction: return t(language, en: "Withdraw", sv: "Ta ut", es: "Retirar", fr: "Retirer", de: "Abheben")

        case .kidSectionDetails: return t(language, en: "Kid details", sv: "Barnuppgifter", es: "Datos del niño", fr: "Détails de l’enfant", de: "Kinddetails")
        case .kidSectionAllowance: return t(language, en: "Weekly allowance", sv: "Veckopeng", es: "Paga semanal", fr: "Allocation hebdomadaire", de: "Wöchentliches Taschengeld")
        case .kidSectionSchedule: return t(language, en: "Pay day", sv: "Utbetalningsdag", es: "Día de pago", fr: "Jour de paie", de: "Zahltag")
        case .kidBirthday: return t(language, en: "Birthday", sv: "Födelsedag", es: "Cumpleaños", fr: "Date de naissance", de: "Geburtsdatum")
        case .kidBirthdayToday: return t(language, en: "Happy Birthday!!! 🎁", sv: "Grattis på födelsedagen!!! 🎁", es: "¡Feliz cumpleaños!!! 🎁", fr: "Joyeux anniversaire !!! 🎁", de: "Herzlichen Glückwunsch zum Geburtstag!!! 🎁")
        case .kidNamePlaceholder: return t(language, en: "Kid name", sv: "Barnets namn", es: "Nombre del niño", fr: "Nom de l’enfant", de: "Name des Kindes")
        case .kidNameRequired: return t(language, en: "Kid name is required", sv: "Barnets namn krävs", es: "El nombre es obligatorio", fr: "Le nom est requis", de: "Name ist erforderlich")
        case .kidWeeklyAllowancePlaceholder: return t(language, en: "Weekly allowance", sv: "Veckopeng", es: "Paga semanal", fr: "Allocation hebdomadaire", de: "Wöchentliches Taschengeld")
        case .kidWeeklyAllowanceRequired: return t(language, en: "Weekly allowance is required", sv: "Veckopeng krävs", es: "La paga semanal es obligatoria", fr: "L’allocation hebdomadaire est requise", de: "Wöchentliches Taschengeld ist erforderlich")
        case .kidDepositFrequency: return t(language, en: "Deposit frequency", sv: "Insättningsfrekvens", es: "Frecuencia de ingreso", fr: "Fréquence du versement", de: "Auszahlungsrhythmus")
        case .kidDepositTime: return t(language, en: "Deposit time", sv: "Insättningstid", es: "Hora del ingreso", fr: "Heure du versement", de: "Auszahlungszeit")
        case .kidMonthlyInterestHeader: return t(language, en: "Monthly interest from balance", sv: "Månadsränta på saldo", es: "Interés mensual sobre el saldo", fr: "Intérêts mensuels sur le solde", de: "Monatszins auf Guthaben")
        case .kidSelectIcon: return t(language, en: "Select", sv: "Välj", es: "Elegir", fr: "Choisir", de: "Auswählen")
        case .kidProfileTapPhoto: return t(language, en: "Tap photo to change", sv: "Tryck på bilden för att byta", es: "Toca la foto para cambiar", fr: "Touchez la photo pour changer", de: "Tippe auf das Foto zum Ändern")
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

        case .frequencyWeekly: return t(language, en: "Weekly", sv: "Veckovis", es: "Semanal", fr: "Hebdomadaire", de: "Wöchentlich")
        case .frequencyMonthly: return t(language, en: "Monthly", sv: "Månadsvis", es: "Mensual", fr: "Mensuel", de: "Monatlich")
        case .allowanceLineFormat: return t(language, en: "%@ %@", sv: "%@ %@", es: "%@ %@", fr: "%@ %@", de: "%@ %@")

        case .iconPickerIcons: return t(language, en: "Avatars", sv: "Avatarer", es: "Avatares", fr: "Avatars", de: "Avatare")
        case .iconPickerPhotos: return t(language, en: "Photos", sv: "Foton", es: "Fotos", fr: "Photos", de: "Fotos")
        case .iconPickerSelectImage: return t(language, en: "Select image", sv: "Välj bild", es: "Elegir imagen", fr: "Choisir une image", de: "Bild auswählen")
        case .iconPickerChangeImage: return t(language, en: "Change image", sv: "Byt bild", es: "Cambiar imagen", fr: "Changer l’image", de: "Bild ändern")
        case .iconPickerNavSelect: return t(language, en: "Select", sv: "Välj", es: "Seleccionar", fr: "Sélectionner", de: "Auswählen")
        case .pickerSelection: return t(language, en: "Selection", sv: "Val", es: "Selección", fr: "Sélection", de: "Auswahl")

        case .goalsTitle: return t(language, en: "Goals", sv: "Mål", es: "Metas", fr: "Objectifs", de: "Ziele")
        case .goalsSubtitle: return t(language, en: "Track and edit each kid’s goals", sv: "Följ och redigera varje barns mål", es: "Sigue y edita las metas de cada niño", fr: "Suivez et modifiez les objectifs de chaque enfant", de: "Ziele jedes Kindes verfolgen und bearbeiten")
        case .goalsAll: return t(language, en: "All", sv: "Alla", es: "Todos", fr: "Tous", de: "Alle")
        case .goalsNoGoalsTitle: return t(language, en: "No goals yet", sv: "Inga mål ännu", es: "Aún no hay metas", fr: "Pas encore d’objectifs", de: "Noch keine Ziele")
        case .goalsNoGoalsSubtitle: return t(language, en: "Add a goal and track progress by balance.", sv: "Lägg till ett mål och följ hur saldot rör sig mot målet.", es: "Añade una meta y mira el avance según el saldo.", fr: "Ajoutez un objectif et suivez la progression via le solde.", de: "Lege ein Ziel an und verfolge den Fortschritt am Guthaben.")
        case .goalsNoGoalsForKidTitleFormat: return t(language, en: "No goals for %@", sv: "Inga mål för %@", es: "No hay metas para %@", fr: "Aucun objectif pour %@", de: "Keine Ziele für %@")
        case .goalsNoGoalsForKidSubtitleFormat: return t(language, en: "Add a new goal and track progress with %@’s balance.", sv: "Lägg till ett nytt mål och följ framstegen med %@s saldo.", es: "Añade una meta nueva y sigue el avance con el saldo de %@.", fr: "Ajoutez un nouvel objectif et suivez la progression avec le solde de %@.", de: "Lege ein neues Ziel an und verfolge den Fortschritt am Guthaben von %@.")
        case .goalsNoKidsTitle: return t(language, en: "No kids yet", sv: "Inga barn ännu", es: "Aún no hay niños", fr: "Pas encore d’enfants", de: "Noch keine Kinder")
        case .goalsNoKidsSubtitle: return t(language, en: "Add a kid in Family before creating goals.", sv: "Lägg till ett barn under Familj innan du skapar mål.", es: "Añade un niño en Familia antes de crear metas.", fr: "Ajoutez un enfant dans Famille avant de créer des objectifs.", de: "Füge unter „Familie“ ein Kind hinzu, bevor du Ziele anlegst.")
        case .goalsDeleteSwipe: return t(language, en: "Delete", sv: "Ta bort", es: "Eliminar", fr: "Supprimer", de: "Löschen")
        case .goalsKidPossessiveGoalFormat: return t(language, en: "%@’s goal", sv: "%@s mål", es: "Meta de %@", fr: "Objectif de %@", de: "%@s Ziel")
        case .goalsPercentCompleteFormat: return t(language, en: "%d%% complete", sv: "%d%% klart", es: "%d%% completado", fr: "%d%% terminé", de: "%d%% erledigt")
        case .goalsTimeToGoToday: return t(language, en: "Goal expected today", sv: "Mål väntas idag", es: "Meta prevista hoy", fr: "Objectif prévu aujourd’hui", de: "Ziel voraussichtlich heute")
        case .goalsTimeToGoOneDay: return t(language, en: "Goal expected in 1 day", sv: "Mål väntas om 1 dag", es: "Meta prevista en 1 día", fr: "Objectif prévu dans 1 jour", de: "Ziel voraussichtlich in 1 Tag")
        case .goalsTimeToGoDaysFormat: return t(language, en: "Goal expected in %d days", sv: "Mål väntas om %d dagar", es: "Meta prevista en %d días", fr: "Objectif prévu dans %d jours", de: "Ziel voraussichtlich in %d Tagen")
        case .goalsTimeToGoOneWeek: return t(language, en: "Goal expected in 1 week", sv: "Mål väntas om 1 vecka", es: "Meta prevista en 1 semana", fr: "Objectif prévu dans 1 semaine", de: "Ziel voraussichtlich in 1 Woche")
        case .goalsTimeToGoWeeksFormat: return t(language, en: "Goal expected in %d weeks", sv: "Mål väntas om %d veckor", es: "Meta prevista en %d semanas", fr: "Objectif prévu dans %d semaines", de: "Ziel voraussichtlich in %d Wochen")
        case .goalsTimeToGoOneMonth: return t(language, en: "Goal expected in 1 month", sv: "Mål väntas om 1 månad", es: "Meta prevista en 1 mes", fr: "Objectif prévu dans 1 mois", de: "Ziel voraussichtlich in 1 Monat")
        case .goalsTimeToGoMonthsFormat: return t(language, en: "Goal expected in %d months", sv: "Mål väntas om %d månader", es: "Meta prevista en %d meses", fr: "Objectif prévu dans %d mois", de: "Ziel voraussichtlich in %d Monaten")
        case .goalsTimeToGoReached: return t(language, en: "Goal reached!", sv: "Målet är uppnått!", es: "¡Meta alcanzada!", fr: "Objectif atteint !", de: "Ziel erreicht!")
        case .goalsTimeToGoNoAllowance: return t(language, en: "Set allowance to estimate", sv: "Ange veckopeng för uppskattning", es: "Define la paga para estimar", fr: "Définissez l’allocation pour estimer", de: "Taschengeld festlegen für Schätzung")
        case .goalsTimeToGoBeyondHorizon: return t(language, en: "Goal expected in 1+ years", sv: "Mål väntas om 1+ år", es: "Meta prevista en más de 1 año", fr: "Objectif prévu dans plus d’un an", de: "Ziel voraussichtlich in über 1 Jahr")
        case .goalsSectionGoal: return t(language, en: "Goal", sv: "Mål", es: "Meta", fr: "Objectif", de: "Ziel")
        case .goalsSectionPhoto: return t(language, en: "Photo", sv: "Foto", es: "Foto", fr: "Photo", de: "Foto")
        case .goalsCost: return t(language, en: "Cost", sv: "Kostnad", es: "Coste", fr: "Coût", de: "Kosten")
        case .goalsGoalName: return t(language, en: "Goal title", sv: "Måltitel", es: "Título de la meta", fr: "Titre de l’objectif", de: "Zieltitel")
        case .goalsSelectKid: return t(language, en: "Select kids", sv: "Välj barn", es: "Seleccionar niños", fr: "Sélectionner des enfants", de: "Kinder auswählen")
        case .goalsKidRequired: return t(language, en: "Select at least one kid", sv: "Välj minst ett barn", es: "Selecciona al menos un niño", fr: "Sélectionnez au moins un enfant", de: "Mindestens ein Kind auswählen")
        case .goalsPickerKid: return t(language, en: "Kid", sv: "Barn", es: "Niño", fr: "Enfant", de: "Kind")
        case .goalsGoalTitlePlaceholder: return t(language, en: "Ex: New laptop", sv: "Ex: Ny laptop", es: "Ej.: Portátil nuevo", fr: "Ex. : Nouvel ordinateur", de: "z. B. Neuer Laptop")
        case .goalsGoalTitleRequired: return t(language, en: "Goal title is required", sv: "Måltitel krävs", es: "El título es obligatorio", fr: "Le titre est requis", de: "Titel ist erforderlich")
        case .goalsTargetPlaceholder: return t(language, en: "Target amount", sv: "Målbelopp", es: "Importe objetivo", fr: "Montant cible", de: "Zielbetrag")
        case .goalsTargetRequired: return t(language, en: "Cost is required", sv: "Kostnad krävs", es: "El coste es obligatorio", fr: "Le coût est requis", de: "Kosten erforderlich")
        case .goalsAddPhoto: return t(language, en: "Add photo", sv: "Lägg till foto", es: "Añadir foto", fr: "Ajouter une photo", de: "Foto hinzufügen")
        case .goalsPhotoRequired: return t(language, en: "Photo or icon is required", sv: "Foto eller ikon krävs", es: "Se requiere foto o icono", fr: "Photo ou icône requise", de: "Foto oder Symbol erforderlich")
        case .goalsNavNew: return t(language, en: "New Goal", sv: "Nytt mål", es: "Nueva meta", fr: "Nouvel objectif", de: "Neues Ziel")
        case .goalsNavEdit: return t(language, en: "Edit Goal", sv: "Redigera mål", es: "Editar meta", fr: "Modifier l’objectif", de: "Ziel bearbeiten")
        case .goalsDeleteFromDetail: return t(language, en: "Delete goal", sv: "Ta bort mål", es: "Eliminar meta", fr: "Supprimer l’objectif", de: "Ziel löschen")
        case .goalsDeleteGoalConfirmTitle: return t(language, en: "Delete this goal?", sv: "Ta bort detta mål?", es: "¿Eliminar esta meta?", fr: "Supprimer cet objectif ?", de: "Dieses Ziel löschen?")
        case .goalsDeleteGoalConfirmMessage: return t(language, en: "This goal will be removed from your list. This cannot be undone.", sv: "Målet tas bort från listan. Detta kan inte ångras.", es: "La meta se eliminará de la lista. No se puede deshacer.", fr: "Cet objectif sera retiré de la liste. Action irréversible.", de: "Das Ziel wird aus der Liste entfernt. Das kann nicht rückgängig gemacht werden.")
        case .goalsDetailInfoAccessibility: return t(language, en: "Goal details", sv: "Måldetaljer", es: "Detalles de la meta", fr: "Détails de l’objectif", de: "Zieldetails")

        case .insightsTitle: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .insightsSubtitle: return t(language, en: "Review activity and trends", sv: "Se aktivitet och trender", es: "Revisa actividad y tendencias", fr: "Consultez l’activité et les tendances", de: "Aktivität und Trends ansehen")
        case .insightsTabInsights: return t(language, en: "Insights", sv: "Insikter", es: "Resumen", fr: "Analyses", de: "Einblicke")
        case .insightsTabHistory: return t(language, en: "History", sv: "Historik", es: "Historial", fr: "Historique", de: "Verlauf")
        case .historyEmptyTitle: return t(language, en: "No history yet", sv: "Ingen historik ännu", es: "Aún no hay historial", fr: "Pas encore d’historique", de: "Noch kein Verlauf")
        case .historyEmptySubtitle: return t(language, en: "Kid changes will appear here.", sv: "Ändringar om barn visas här.", es: "Los cambios de niños aparecerán aquí.", fr: "Les changements liés aux enfants apparaîtront ici.", de: "Änderungen zu Kindern erscheinen hier.")
        case .historyFilteredEmptyTitle: return t(language, en: "No history for this kid", sv: "Ingen historik för detta barn", es: "Sin historial para este niño", fr: "Pas d’historique pour cet enfant", de: "Kein Verlauf für dieses Kind")
        case .historyFilteredEmptySubtitle: return t(language, en: "Try another filter.", sv: "Prova ett annat filter.", es: "Prueba otro filtro.", fr: "Essayez un autre filtre.", de: "Probier einen anderen Filter.")
        case .historySubtitle: return t(language, en: "All kids transactions", sv: "Alla barnens transaktioner", es: "Todas las transacciones de los niños", fr: "Toutes les transactions des enfants", de: "Alle Transaktionen der Kinder")
        case .historyGotIt: return t(language, en: "Got it", sv: "Okej", es: "Entendido", fr: "Compris", de: "Verstanden")
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
        case .insightsCategoryExpectedAllowance: return t(language, en: "Expected allowance", sv: "Förväntad veckopeng", es: "Paga prevista", fr: "Allocation prévue", de: "Erwartetes Taschengeld")
        case .insightsExpectedAmountFormat: return t(language, en: "Expected %@", sv: "Förväntat %@", es: "Previsto %@", fr: "Prévu %@", de: "Erwartet %@")
        case .insightsNoActivityYet: return t(language, en: "No activity yet", sv: "Ingen aktivitet ännu", es: "Aún no hay actividad", fr: "Pas encore d’activité", de: "Noch keine Aktivität")
        case .calendarWeekdayShortFormat: return t(language, en: "EEE", sv: "EEE", es: "EEE", fr: "EEE", de: "EEE")
        case .insightsInterestByKidTitle: return t(language, en: "Interest", sv: "Ränta", es: "Intereses", fr: "Intérêts", de: "Zinsen")
        case .insightsFactsTitle: return t(language, en: "Did you know?", sv: "Visste du?", es: "¿Sabías que…?", fr: "Le saviez-vous ?", de: "Wusstest du?")
        case .insightsFactsEmpty: return t(language, en: "Add kids to see personalized insights here.", sv: "Lägg till barn för att se insikter här.", es: "Añade niños para ver datos aquí.", fr: "Ajoutez des enfants pour voir des infos ici.", de: "Füge Kinder hinzu, um Einblicke zu sehen.")
        case .insightsFactsTip: return t(language, en: "Log deposits and set goals to unlock more insights.", sv: "Bokför insättningar och sätt mål för fler insikter.", es: "Registra ingresos y metas para más datos.", fr: "Enregistrez des dépôts et des objectifs pour plus d’infos.", de: "Buche Einzahlungen und Ziele für mehr Einblicke.")
        case .insightsFactBirthdayToday: return t(language, en: "Today is %@’s birthday! 🎁", sv: "Idag fyller %@ år! 🎁", es: "¡Hoy es el cumpleaños de %@! 🎁", fr: "C’est l’anniversaire de %@ aujourd’hui ! 🎁", de: "Heute hat %@ Geburtstag! 🎁")
        case .insightsFactMonthInterest: return t(language, en: "This month you paid %@ in interest to your kids.", sv: "Denna månad betalade du %@ i ränta till barnen.", es: "Este mes pagaste %@ de intereses a tus niños.", fr: "Ce mois-ci, vous avez versé %@ d’intérêts à vos enfants.", de: "Diesen Monat hast du %@ Zinsen an deine Kinder gezahlt.")
        case .insightsFactMonthDeposits: return t(language, en: "This month %@ was deposited for your kids.", sv: "Denna månad sattes %@ in till barnen.", es: "Este mes se ingresaron %@ para tus niños.", fr: "Ce mois-ci, %@ ont été déposés pour vos enfants.", de: "Diesen Monat wurden %@ für deine Kinder eingezahlt.")
        case .insightsFactMonthWithdrawals: return t(language, en: "This month your kids withdrew %@.", sv: "Denna månad tog barnen ut %@.", es: "Este mes tus niños retiraron %@.", fr: "Ce mois-ci, vos enfants ont retiré %@.", de: "Diesen Monat haben deine Kinder %@ abgehoben.")
        case .insightsFactMonthNetPositive: return t(language, en: "This month your kids saved %@ net.", sv: "Denna månad sparade barnen %@ netto.", es: "Este mes tus niños ahorraron %@ netos.", fr: "Ce mois-ci, vos enfants ont épargné %@ nets.", de: "Diesen Monat haben deine Kinder netto %@ gespart.")
        case .insightsFactMonthNetNegative: return t(language, en: "This month net spending was %@.", sv: "Denna månad var nettouttag %@.", es: "Este mes el gasto neto fue %@.", fr: "Ce mois-ci, les dépenses nettes ont été de %@.", de: "Diesen Monat betrug die Nettoausgabe %@.")
        case .insightsFactBiggestSpender: return t(language, en: "The biggest spender is %@ at %@ this month.", sv: "Störst utgifter har %@ med %@ denna månad.", es: "Quien más gastó este mes es %@ con %@.", fr: "Le plus gros dépensier ce mois-ci est %@ avec %@.", de: "Am meisten ausgegeben hat %@ diesen Monat mit %@.")
        case .insightsFactBiggestSaver: return t(language, en: "The biggest saver is %@ at %@ this month.", sv: "Mest sparade %@ med %@ denna månad.", es: "Quien más ahorró este mes es %@ con %@.", fr: "Le plus gros épargnant ce mois-ci est %@ avec %@.", de: "Am meisten gespart hat %@ diesen Monat mit %@.")
        case .insightsFactWeekDeposits: return t(language, en: "This week %@ was deposited for your kids.", sv: "Denna vecka sattes %@ in till barnen.", es: "Esta semana se ingresaron %@ para tus niños.", fr: "Cette semaine, %@ ont été déposés pour vos enfants.", de: "Diese Woche wurden %@ für deine Kinder eingezahlt.")
        case .insightsFactGoalReached: return t(language, en: "%@ reached the goal", sv: "%@ nådde målet", es: "%@ alcanzó la meta", fr: "%@ a atteint l’objectif", de: "%@ hat das Ziel erreicht")
        case .insightsFactGoalReachedThisWeek: return t(language, en: "This week %@ reached the goal", sv: "Denna vecka nådde %@ målet", es: "Esta semana %@ alcanzó la meta", fr: "Cette semaine, %@ a atteint l’objectif", de: "Diese Woche hat %@ das Ziel erreicht")
        case .insightsFactGoalAlmost: return t(language, en: "%@ is only %@ away from «%@».", sv: "%@ saknar bara %@ till «%@».", es: "A %@ le faltan solo %@ para «%@».", fr: "Il ne manque que %@ à %@ pour « %@ ».", de: "%@ fehlen nur noch %@ bis «%@».")
        case .insightsFactGoalAlmostLead: return t(language, en: "%@ is only ", sv: "%@ saknar bara ", es: "A %@ le faltan solo ", fr: "Il ne manque que ", de: "%@ fehlen nur noch ")
        case .insightsFactGoalAlmostTrail: return t(language, en: " away from.", sv: " kvar.", es: " para alcanzarlo.", fr: " restants.", de: " entfernt.")
        case .insightsFactTopBalanceKid: return t(language, en: "%@ has the highest balance at %@.", sv: "%@ har högst saldo med %@.", es: "%@ tiene el saldo más alto: %@.", fr: "%@ a le plus gros solde : %@.", de: "%@ hat mit %@ das höchste Guthaben.")
        case .insightsFactFamilyBalance: return t(language, en: "Your kids hold %@ in total.", sv: "Barnen har totalt %@.", es: "Tus niños tienen %@ en total.", fr: "Vos enfants détiennent %@ au total.", de: "Deine Kinder haben insgesamt %@.")
        case .insightsFactActiveGoals: return t(language, en: "Your family is working toward %d savings goals.", sv: "Familjen jobbar mot %d sparmål.", es: "Tu familia trabaja en %d metas de ahorro.", fr: "Votre famille poursuit %d objectifs d’épargne.", de: "Eure Familie verfolgt %d Sparziele.")
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
        case .settingsClearHistoryTitle: return t(language, en: "Clear history", sv: "Rensa historik", es: "Borrar historial", fr: "Effacer l’historique", de: "Verlauf löschen")
        case .settingsClearHistorySubtitle: return t(language, en: "Remove all history entries", sv: "Ta bort alla historikposter", es: "Eliminar todas las entradas del historial", fr: "Supprimer toutes les entrées d’historique", de: "Alle Verlaufseinträge entfernen")
        case .settingsClearHistoryAlertTitle: return t(language, en: "Clear history?", sv: "Rensa historik?", es: "¿Borrar historial?", fr: "Effacer l’historique ?", de: "Verlauf löschen?")
        case .settingsClearHistoryAlertMessage: return t(language, en: "All history entries will be permanently deleted. Kids, goals, and transactions are not affected.", sv: "All historik tas bort permanent. Barn, mål och transaktioner påverkas inte.", es: "Se borrará todo el historial de forma permanente. Los niños, metas y transacciones no se verán afectados.", fr: "Tout l’historique sera définitivement supprimé. Les enfants, objectifs et transactions ne sont pas concernés.", de: "Der gesamte Verlauf wird dauerhaft gelöscht. Kinder, Ziele und Transaktionen bleiben unverändert.")
        case .settingsClearTitle: return t(language, en: "Clear all data", sv: "Rensa all data", es: "Borrar todos los datos", fr: "Effacer toutes les données", de: "Alle Daten löschen")
        case .settingsClearSubtitle: return t(language, en: "Delete all app data", sv: "Ta bort all appdata", es: "Eliminar todos los datos de la app", fr: "Supprimer toutes les données de l’app", de: "Alle App-Daten löschen")
        case .settingsExportAlertTitle: return t(language, en: "Export data", sv: "Exportera data", es: "Exportar datos", fr: "Exporter les données", de: "Daten exportieren")
        case .settingsExportAlertMessage: return t(language, en: "This is a placeholder. Export will be connected later.", sv: "Detta är en placeholder. Export kopplas på senare.", es: "Esto es una demostración. La exportación llegará después.", fr: "Ceci est un emplacement. L’export viendra plus tard.", de: "Das ist nur ein Platzhalter. Export folgt später.")
        case .settingsClearAlertTitle: return t(language, en: "Clear all data?", sv: "Rensa all data?", es: "¿Borrar todos los datos?", fr: "Effacer toutes les données ?", de: "Alle Daten löschen?")
        case .settingsClearAlertMessage: return t(language, en: "This is a placeholder. Clearing data will be connected later.", sv: "Detta är en placeholder. Radering kopplas på senare.", es: "Esto es una demostración. El borrado llegará después.", fr: "Ceci est un emplacement. La suppression viendra plus tard.", de: "Das ist nur ein Platzhalter. Löschen folgt später.")
        case .settingsSheetHelpTitle: return t(language, en: "Help & Support", sv: "Hjälp och support", es: "Ayuda y soporte", fr: "Aide et support", de: "Hilfe & Support")
        case .settingsSheetTermsTitle: return t(language, en: "Terms & Privacy", sv: "Villkor och integritet", es: "Términos y privacidad", fr: "Conditions et confidentialité", de: "AGB & Datenschutz")
        case .settingsSheetAboutTitle: return t(language, en: "About Vecko", sv: "Om Vecko", es: "Acerca de Vecko", fr: "À propos de Vecko", de: "Über Vecko")
        case .settingsSupportBackHeaderHelp: return t(language, en: "Help and support", sv: "Hjälp och support", es: "Ayuda y soporte", fr: "Aide et support", de: "Hilfe und Support")
        case .settingsSupportIntroTitle: return t(language, en: "We’d love to hear from you!", sv: "Vi vill gärna höra från dig!", es: "¡Nos encantaría saber de ti!", fr: "Nous serions ravis de vous lire !", de: "Wir freuen uns auf deine Nachricht!")
        case .settingsSupportIntroLine1: return t(language, en: "Whether you have questions,", sv: "Oavsett om du har frågor,", es: "Tanto si tienes preguntas,", fr: "Que vous ayez des questions,", de: "Ob du Fragen hast,")
        case .settingsSupportIntroLine2: return t(language, en: "feedback, or just want to say hi,", sv: "synpunkter eller bara vill säga hej,", es: "comentarios o solo quieres saludar,", fr: "des retours ou simplement envie de dire bonjour,", de: "Feedback hast oder nur Hallo sagen willst,")
        case .settingsSupportIntroLine3: return t(language, en: "feel free to reach out.", sv: "är du välkommen att höra av dig.", es: "escríbenos cuando quieras.", fr: "contactez-nous.", de: "melde dich gern.")
        case .settingsSupportEmailLabel: return t(language, en: "Email", sv: "E-post", es: "Correo", fr: "E-mail", de: "E-Mail")
        case .settingsSupportWebsiteLabel: return t(language, en: "Website", sv: "Webbplats", es: "Sitio web", fr: "Site web", de: "Website")
        case .settingsSupportOr: return t(language, en: "OR", sv: "ELLER", es: "O", fr: "OU", de: "ODER")
        case .settingsSupportContactForm: return t(language, en: "Contact form", sv: "Kontaktformulär", es: "Formulario de contacto", fr: "Formulaire de contact", de: "Kontaktformular")
        case .settingsSupportAimRespond: return t(language, en: "We aim to respond within 24 hours.", sv: "Vi strävar efter att svara inom 24 timmar.", es: "Intentamos responder en 24 horas.", fr: "Nous essayons de répondre sous 24 h.", de: "Wir antworten in der Regel innerhalb von 24 Stunden.")
        case .settingsSupportNavContact: return t(language, en: "Contact us", sv: "Kontakta oss", es: "Contáctanos", fr: "Nous contacter", de: "Kontakt")
        case .settingsSupportSectionFullName: return t(language, en: "Your full name", sv: "Ditt fullständiga namn", es: "Tu nombre completo", fr: "Votre nom complet", de: "Dein vollständiger Name")
        case .settingsSupportPlaceholderFullName: return t(language, en: "Full name", sv: "Fullständigt namn", es: "Nombre completo", fr: "Nom complet", de: "Vollständiger Name")
        case .settingsSupportSectionYourEmail: return t(language, en: "Your Email", sv: "Din e-post", es: "Tu correo", fr: "Votre e-mail", de: "Deine E-Mail")
        case .settingsSupportPlaceholderYourEmail: return t(language, en: "Email", sv: "E-post", es: "Correo", fr: "E-mail", de: "E-Mail")
        case .settingsSupportSectionSubject: return t(language, en: "Subject", sv: "Ämne", es: "Asunto", fr: "Objet", de: "Betreff")
        case .settingsSupportSectionDescription: return t(language, en: "Description", sv: "Beskrivning", es: "Descripción", fr: "Description", de: "Beschreibung")
        case .settingsSupportSend: return t(language, en: "Send", sv: "Skicka", es: "Enviar", fr: "Envoyer", de: "Senden")
        case .settingsSupportAllRequired: return t(language, en: "All fields are required.", sv: "Alla fält är obligatoriska.", es: "Todos los campos son obligatorios.", fr: "Tous les champs sont requis.", de: "Alle Felder sind erforderlich.")
        case .settingsSupportAlertSentTitle: return t(language, en: "Message ready", sv: "Meddelande klart", es: "Mensaje listo", fr: "Message prêt", de: "Nachricht bereit")
        case .settingsSupportAlertSentMessage: return t(language, en: "Your mail app should open with your message. If it does not, email us using the address shown above.", sv: "Din e-postapp ska öppnas med ditt meddelande. Om inte, mejla oss med adressen ovan.", es: "Se abrirá tu app de correo con el mensaje. Si no, escríbenos con la dirección indicada.", fr: "Votre app Mail devrait s’ouvrir. Sinon, écrivez-nous à l’adresse ci-dessus.", de: "Die Mail-App sollte sich mit deiner Nachricht öffnen. Sonst schreib uns an die Adresse oben.")
        case .settingsSupportAlertMailFail: return t(language, en: "Could not open Mail. Please email us at %@", sv: "Kunde inte öppna Mail. Mejla oss på %@", es: "No se pudo abrir Mail. Escríbenos a %@", fr: "Impossible d’ouvrir Mail. Écrivez-nous à %@", de: "Mail konnte nicht geöffnet werden. Schreib uns an %@")
        case .settingsLegalTabTerms: return t(language, en: "Terms", sv: "Villkor", es: "Términos", fr: "Conditions", de: "Bedingungen")
        case .settingsLegalTabPrivacy: return t(language, en: "Privacy", sv: "Integritet", es: "Privacidad", fr: "Confidentialité", de: "Datenschutz")
        case .settingsLegalTabDisclaimer: return t(language, en: "Disclaimer", sv: "Ansvarsfriskrivning", es: "Aviso legal", fr: "Avertissement", de: "Haftungsausschluss")
        case .settingsAboutBody: return t(language, en: "Vecko is for parents and carers who want pocket money under control. For each child you set a weekly amount, how deposits run (daily, weekly on a chosen weekday, or monthly on a chosen day), and optional simple interest credited on the 1st of every month. Log extra deposits and withdrawals, savings goals with targets and optional photos, and review a full history that includes scheduled allowances and interest. Home, Family, Goals, and Insights show balances, bulk actions, goal progress, and month-by-month activity. Everything stays on your device in the currency and language you pick, and you can export a PDF when you need a record to keep or share.", sv: "Vecko är för vuxna som vill ha koll på barnens veckopeng. För varje barn anger du belopp, hur insättningar sker (varje dag, en vald veckodag eller en vald dag i månaden) samt valfri enkel månadsränta som läggs till den 1:a varje månad. Du bokför extra insättningar och uttag, sparmål med målbelopp och valfria foton, och följer historik med schemalagda utbetalningar och ränta. Hem, Familj, Mål och Insikter visar saldon, snabbåtgärder, målframsteg och aktivitet per månad. Allt finns på din enhet i den valuta och det språk du väljer, och du kan exportera en PDF när du vill spara eller dela en sammanställning.", es: "Vecko está pensado para padres y cuidadores que quieren ordenar la paga de los niños. En cada hijo defines el importe semanal, la frecuencia de los ingresos (cada día, semanal con un día fijo o mensual con un día del mes) y un interés mensual opcional que se abona el día 1. Registra ingresos y retiros extra, metas de ahorro con objetivo y fotos opcionales, y revisa el historial con pagas programadas e intereses. Inicio, Familia, Metas y Resumen muestran saldos, acciones rápidas, avance de metas y actividad mes a mes. Los datos permanecen en tu dispositivo con la moneda e idioma que elijas, y puedes exportar un PDF cuando necesites un archivo para archivar o compartir.", fr: "Vecko s’adresse aux parents et aidants qui veulent suivre l’argent de poche au quotidien. Pour chaque enfant vous définissez le montant hebdomadaire, le rythme des versements (chaque jour, chaque semaine un jour fixe, ou chaque mois un jour du mois) et des intérêts mensuels simples facultatifs crédités le 1er. Vous enregistrez dépôts et retraits ponctuels, des objectifs d’épargne avec cible et photos optionnelles, et consultez l’historique avec allocations planifiées et intérêts. Accueil, Famille, Objectifs et Analyses regroupent soldes, actions groupées, progression et activité mois par mois. Les données restent sur l’appareil dans la devise et la langue choisies, et vous pouvez exporter un PDF pour archiver ou partager.", de: "Vecko richtet sich an Eltern und Betreuungspersonen, die Taschengeld transparent im Blick behalten wollen. Pro Kind legst du den Wochenbetrag fest, wie Auszahlungen laufen (täglich, wöchentlich an einem Wochentag oder monatlich an einem Kalendertag) sowie optional einfachen Monatszins, der jeweils am 1. gutgeschrieben wird. Du erfasst zusätzliche Ein- und Auszahlungen, Sparziele mit Zielbetrag und optionalen Fotos und siehst die Historie inklusive geplantem Taschengeld und Zinsen. Start, Familie, Ziele und Einblicke zeigen Salden, Sammelaktionen, Zielfortschritt und Aktivität monatsweise. Alles bleibt auf deinem Gerät in deiner Währung und Sprache; als PDF kannst du eine Übersicht exportieren, um sie zu archivieren oder zu teilen.")
        case .settingsAboutVersionFormat: return t(language, en: "Version %@ (%@)", sv: "Version %@ (%@)", es: "Versión %@ (%@)", fr: "Version %@ (%@)", de: "Version %@ (%@)")
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
        case .historyGoalAdded: return t(language, en: "New goal", sv: "Nytt mål", es: "Nueva meta", fr: "Nouvel objectif", de: "Neues Ziel")
        case .historyAllowancePaid: return t(language, en: "Allowance paid", sv: "Veckopeng utbetald", es: "Paga abonada", fr: "Allocation versée", de: "Taschengeld gutgeschrieben")
        case .historyWeeklyAllowancePaidDetailTitle: return t(language, en: "Weekly allowance paid", sv: "Veckopeng utbetald", es: "Paga semanal abonada", fr: "Allocation hebdomadaire versée", de: "Wöchentliches Taschengeld gutgeschrieben")
        case .historyInterestCredited: return t(language, en: "Interest credited", sv: "Ränta tillagd", es: "Interés abonado", fr: "Intérêts crédités", de: "Zins gutgeschrieben")
        case .historyInterestCreditedDetailFormat: return t(language, en: "%d%% interest paid - %@", sv: "%d%% ränta utbetald - %@", es: "%d%% interés pagado - %@", fr: "%d%% intérêts versés - %@", de: "%d%% Zins ausgezahlt - %@")
        case .historyDeposit: return t(language, en: "Deposit", sv: "Insättning", es: "Ingreso", fr: "Dépôt", de: "Einzahlung")
        case .historyWithdrawal: return t(language, en: "Withdrawal", sv: "Uttag", es: "Retiro", fr: "Retrait", de: "Auszahlung")
        case .historyKidBirthday: return t(language, en: "Birthday", sv: "Födelsedag", es: "Cumpleaños", fr: "Anniversaire", de: "Geburtstag")
        case .historyKidUpdateNameFormat: return t(language, en: "Name updated to %@", sv: "Namn uppdaterat till %@", es: "Nombre actualizado a %@", fr: "Nom mis à jour : %@", de: "Name aktualisiert zu %@")
        case .historyKidUpdateAllowanceFormat: return t(language, en: "Weekly allowance updated to %@", sv: "Veckopeng uppdaterad till %@", es: "Paga semanal actualizada a %@", fr: "Allocation hebdomadaire mise à jour : %@", de: "Wöchentliches Taschengeld aktualisiert auf %@")
        case .historyKidUpdateInterestFormat: return t(language, en: "Interest updated to %d%%", sv: "Ränta uppdaterad till %d%%", es: "Interés actualizado a %d%%", fr: "Intérêts mis à jour : %d%%", de: "Zins aktualisiert auf %d%%")
        case .historyKidUpdatePayDayFormat: return t(language, en: "Pay day updated to %@", sv: "Utbetalningsdag uppdaterad till %@", es: "Día de pago actualizado a %@", fr: "Jour de paie mis à jour : %@", de: "Zahltag aktualisiert auf %@")
        case .historyKidUpdateDepositTimeFormat: return t(language, en: "Deposit time updated to %@", sv: "Insättningstid uppdaterad till %@", es: "Hora de ingreso actualizada a %@", fr: "Heure de dépôt mise à jour : %@", de: "Einzahlungszeit aktualisiert auf %@")
        case .historyKidUpdateBirthdayFormat: return t(language, en: "Birthday updated to %@", sv: "Födelsedag uppdaterad till %@", es: "Cumpleaños actualizado a %@", fr: "Date de naissance mise à jour : %@", de: "Geburtsdatum aktualisiert auf %@")
        case .historyKidUpdatePhotoFormat: return t(language, en: "Profile photo updated", sv: "Profilbild uppdaterad", es: "Foto de perfil actualizada", fr: "Photo de profil mise à jour", de: "Profilfoto aktualisiert")
        }
    }

    static func localizedHistoryTitle(storedTitle: String, language: AppLanguage) -> String {
        switch storedTitle {
        case "Kid added": return string(.historyKidAdded, language: language)
        case "Kid removed": return string(.historyKidRemoved, language: language)
        case "Kid updated": return string(.historyKidUpdated, language: language)
        case "Goal added", "New goal": return string(.historyGoalAdded, language: language)
        case "Allowance paid", "Weekly allowance paid": return string(.historyAllowancePaid, language: language)
        case "Interest credited": return string(.historyInterestCredited, language: language)
        case "Deposit": return string(.historyDeposit, language: language)
        case "Withdrawal": return string(.historyWithdrawal, language: language)
        case "Birthday": return string(.historyKidBirthday, language: language)
        default: return storedTitle
        }
    }

    /// Title shown in the history detail popup (may differ from the list row title).
    static func localizedHistoryDetailTitle(storedTitle: String, language: AppLanguage) -> String {
        switch storedTitle {
        case "Allowance paid", "Weekly allowance paid":
            return string(.historyWeeklyAllowancePaidDetailTitle, language: language)
        case "Birthday":
            return string(.kidBirthdayToday, language: language)
        default:
            return localizedHistoryTitle(storedTitle: storedTitle, language: language)
        }
    }

    /// Subtitle/detail line for history list rows and the birthday popup body.
    static func localizedKidBirthdayHistoryDetail(kidName: String, language: AppLanguage) -> String {
        String(
            format: string(.insightsFactBirthdayToday, language: language),
            locale: language.locale,
            arguments: [kidName]
        )
    }

    static func displayDepositFrequency(_ frequency: DepositFrequency, language: AppLanguage) -> String {
        switch frequency {
        case .weekly: return string(.frequencyWeekly, language: language)
        case .monthly: return string(.frequencyMonthly, language: language)
        }
    }

    /// `weekday` is `Calendar` weekday (1 = Sunday … 7 = Saturday).
    /// e.g. `2% interest paid - 34.80 SEK` (popup); parses legacy `1% · +34.80` rows too.
    static func localizedInterestCreditedDetail(storedDetail: String, language: AppLanguage) -> String {
        guard let parsed = parseInterestCreditedDetail(storedDetail) else { return storedDetail }
        let amountText = displayAmountTextForInterestDetail(parsed.amountText)
        return String(
            format: string(.historyInterestCreditedDetailFormat, language: language),
            locale: language.locale,
            arguments: [parsed.percent, amountText]
        )
    }

    private static func parseInterestCreditedDetail(_ storedDetail: String) -> (percent: Int, amountText: String)? {
        let trimmed = storedDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        if let marker = trimmed.range(of: "% interest paid - ") {
            let percentPart = String(trimmed[..<marker.lowerBound]).trimmingCharacters(in: .whitespaces)
            let amountPart = String(trimmed[marker.upperBound...]).trimmingCharacters(in: .whitespaces)
            guard let percent = Int(percentPart), !amountPart.isEmpty else { return nil }
            return (percent, amountPart)
        }
        if let separator = trimmed.range(of: " · ") {
            let left = String(trimmed[..<separator.lowerBound]).trimmingCharacters(in: .whitespaces)
            var right = String(trimmed[separator.upperBound...]).trimmingCharacters(in: .whitespaces)
            if right.hasPrefix("+") {
                right = String(right.dropFirst()).trimmingCharacters(in: .whitespaces)
            }
            guard left.hasSuffix("%"), let percent = Int(String(left.dropLast()).trimmingCharacters(in: .whitespaces)),
                  !right.isEmpty else { return nil }
            return (percent, right)
        }
        return nil
    }

    private static func displayAmountTextForInterestDetail(_ raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "+", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let numericPart = cleaned.split(separator: " ").first.map(String.init) ?? cleaned
        let normalized = numericPart.replacingOccurrences(of: ",", with: "")
        if let value = Double(normalized) {
            return CurrencyManager().formatAmount(value)
        }
        return raw
    }

    static func weekdayName(_ weekday: Int, language: AppLanguage) -> String {
        switch weekday {
        case 1: return string(.weekdaySun, language: language)
        case 2: return string(.weekdayMon, language: language)
        case 3: return string(.weekdayTue, language: language)
        case 4: return string(.weekdayWed, language: language)
        case 5: return string(.weekdayThu, language: language)
        case 6: return string(.weekdayFri, language: language)
        case 7: return string(.weekdaySat, language: language)
        default: return string(.weekdayMon, language: language)
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
