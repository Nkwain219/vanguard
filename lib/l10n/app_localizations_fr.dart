import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Traitz Tech';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get selectRole => 'Sélectionner le rôle';

  @override
  String get loginAsDemo => 'Se connecter en mode démo';

  @override
  String continueAsRole(String role) {
    return 'Continuer en tant que $role';
  }

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get employees => 'Employés';

  @override
  String get volunteers => 'Bénévoles';

  @override
  String get tasks => 'Tâches';

  @override
  String get attendance => 'Présence';

  @override
  String get reports => 'Rapports';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminders => 'Rappels';

  @override
  String get welcome => 'Bienvenue';

  @override
  String welcomeBack(String name) {
    return 'Bon retour, $name';
  }

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get clockIn => 'Pointer l\'entrée';

  @override
  String get clockOut => 'Pointer la sortie';

  @override
  String get clockedIn => 'Pointé à l\'entrée';

  @override
  String get clockedOut => 'Pointé à la sortie';

  @override
  String get clockInSuccess => 'Pointage d\'entrée réussi!';

  @override
  String get clockOutSuccess => 'Pointage de sortie réussi!';

  @override
  String get todayAttendance => 'Présence du jour';

  @override
  String get weeklyHours => 'Heures hebdomadaires';

  @override
  String get monthlyHours => 'Heures mensuelles';

  @override
  String get present => 'Présent';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'En retard';

  @override
  String get onLeave => 'En congé';

  @override
  String get pending => 'En attente';

  @override
  String get approved => 'Approuvé';

  @override
  String get rejected => 'Rejeté';

  @override
  String get inProgress => 'En cours';

  @override
  String get completed => 'Terminé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get create => 'Créer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get submit => 'Soumettre';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get done => 'Terminé';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sortBy => 'Trier par';

  @override
  String get all => 'Tous';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get name => 'Nom';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get fullName => 'Nom complet';

  @override
  String get department => 'Département';

  @override
  String get position => 'Poste';

  @override
  String get salary => 'Salaire';

  @override
  String get phone => 'Téléphone';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get status => 'Statut';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get amount => 'Montant';

  @override
  String get reason => 'Raison';

  @override
  String get description => 'Description';

  @override
  String get type => 'Type';

  @override
  String get priority => 'Priorité';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get admin => 'Administrateur';

  @override
  String get secretary => 'Secrétaire';

  @override
  String get employee => 'Employé';

  @override
  String get volunteer => 'Bénévole';

  @override
  String get totalEmployees => 'Total employés';

  @override
  String get totalVolunteers => 'Total bénévoles';

  @override
  String get totalTasks => 'Total tâches';

  @override
  String get pendingTasks => 'Tâches en attente';

  @override
  String get completedTasks => 'Tâches terminées';

  @override
  String get presentToday => 'Présents aujourd\'hui';

  @override
  String get absentToday => 'Absents aujourd\'hui';

  @override
  String get onLeaveToday => 'En congé aujourd\'hui';

  @override
  String get manageEmployees => 'Gérer les employés';

  @override
  String get manageVolunteers => 'Gérer les bénévoles';

  @override
  String get addEmployee => 'Ajouter un employé';

  @override
  String get addVolunteer => 'Ajouter un bénévole';

  @override
  String get editEmployee => 'Modifier l\'employé';

  @override
  String get editVolunteer => 'Modifier le bénévole';

  @override
  String get employeeDetails => 'Détails de l\'employé';

  @override
  String get volunteerDetails => 'Détails du bénévole';

  @override
  String get deleteEmployee => 'Supprimer l\'employé';

  @override
  String get deleteVolunteer => 'Supprimer le bénévole';

  @override
  String deleteConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name?';
  }

  @override
  String get myTasks => 'Mes tâches';

  @override
  String get assignedTasks => 'Tâches assignées';

  @override
  String get createTask => 'Créer une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get taskDetails => 'Détails de la tâche';

  @override
  String get assignTo => 'Assigner à';

  @override
  String get assignees => 'Assignés';

  @override
  String get comments => 'Commentaires';

  @override
  String get addComment => 'Ajouter un commentaire';

  @override
  String get progress => 'Progression';

  @override
  String get urgent => 'Urgent';

  @override
  String get high => 'Haute';

  @override
  String get medium => 'Moyenne';

  @override
  String get low => 'Basse';

  @override
  String get salaryRequest => 'Demande de salaire';

  @override
  String get salaryRequests => 'Demandes de salaire';

  @override
  String get requestSalary => 'Demander un salaire';

  @override
  String get salaryApproval => 'Approbation de salaire';

  @override
  String get approveSalary => 'Approuver le salaire';

  @override
  String get rejectSalary => 'Rejeter le salaire';

  @override
  String get overtime => 'Heures supplémentaires';

  @override
  String get bonus => 'Prime';

  @override
  String get advance => 'Avance';

  @override
  String get deduction => 'Déduction';

  @override
  String get payslip => 'Bulletin de paie';

  @override
  String get payslips => 'Bulletins de paie';

  @override
  String get viewPayslip => 'Voir le bulletin';

  @override
  String get downloadPayslip => 'Télécharger le bulletin';

  @override
  String get basicSalary => 'Salaire de base';

  @override
  String get netSalary => 'Salaire net';

  @override
  String get totalEarnings => 'Total des gains';

  @override
  String get totalDeductions => 'Total des déductions';

  @override
  String get deposit => 'Dépôt';

  @override
  String get deposits => 'Dépôts';

  @override
  String get depositHistory => 'Historique des dépôts';

  @override
  String get requestDeposit => 'Demander un dépôt';

  @override
  String get depositApproval => 'Approbation de dépôt';

  @override
  String get approveDeposit => 'Approuver le dépôt';

  @override
  String get rejectDeposit => 'Rejeter le dépôt';

  @override
  String get travelExpense => 'Frais de voyage';

  @override
  String get officeSupplies => 'Fournitures de bureau';

  @override
  String get equipment => 'Équipement';

  @override
  String get other => 'Autre';

  @override
  String get leave => 'Congé';

  @override
  String get leaveRequest => 'Demande de congé';

  @override
  String get leaveRequests => 'Demandes de congé';

  @override
  String get requestLeave => 'Demander un congé';

  @override
  String get leaveApproval => 'Approbation de congé';

  @override
  String get approveLeave => 'Approuver le congé';

  @override
  String get rejectLeave => 'Rejeter le congé';

  @override
  String get annualLeave => 'Congé annuel';

  @override
  String get sickLeave => 'Congé maladie';

  @override
  String get maternityLeave => 'Congé maternité';

  @override
  String get paternityLeave => 'Congé paternité';

  @override
  String get unpaidLeave => 'Congé sans solde';

  @override
  String get daysRequested => 'Jours demandés';

  @override
  String get daysRemaining => 'Jours restants';

  @override
  String get leaveBalance => 'Solde de congés';

  @override
  String get attendanceHistory => 'Historique de présence';

  @override
  String get attendanceOverview => 'Aperçu de présence';

  @override
  String get attendanceReport => 'Rapport de présence';

  @override
  String get hoursWorked => 'Heures travaillées';

  @override
  String get averageHours => 'Heures moyennes';

  @override
  String get totalDays => 'Total de jours';

  @override
  String get workingDays => 'Jours ouvrables';

  @override
  String get sendReminder => 'Envoyer un rappel';

  @override
  String get reminderSent => 'Rappel envoyé avec succès';

  @override
  String get selectRecipients => 'Sélectionner les destinataires';

  @override
  String get selectTemplate => 'Sélectionner le modèle';

  @override
  String get customMessage => 'Message personnalisé';

  @override
  String get reminderTemplates => 'Modèles de rappel';

  @override
  String get reportSummary => 'Résumé du rapport';

  @override
  String get attendanceStats => 'Statistiques de présence';

  @override
  String get taskStats => 'Statistiques des tâches';

  @override
  String get salaryStats => 'Statistiques de salaire';

  @override
  String get monthlyReport => 'Rapport mensuel';

  @override
  String get weeklyReport => 'Rapport hebdomadaire';

  @override
  String get generateReport => 'Générer le rapport';

  @override
  String get exportReport => 'Exporter le rapport';

  @override
  String get profileSettings => 'Paramètres du profil';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get theme => 'Thème';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get noEmployees => 'Aucun employé trouvé';

  @override
  String get noVolunteers => 'Aucun bénévole trouvé';

  @override
  String get noTasks => 'Aucune tâche trouvée';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noRequests => 'Aucune demande trouvée';

  @override
  String get noResults => 'Aucun résultat trouvé';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Information';

  @override
  String get onboardingTitle1 => 'Gestion du personnel';

  @override
  String get onboardingDesc1 =>
      'Gérez efficacement vos employés et bénévoles avec Traitz Tech.';

  @override
  String get onboardingTitle2 => 'Suivi de présence';

  @override
  String get onboardingDesc2 =>
      'Pointage facile avec suivi de présence en temps réel.';

  @override
  String get onboardingTitle3 => 'Restez organisé';

  @override
  String get onboardingDesc3 =>
      'Assignez des tâches, gérez les congés et générez des rapports.';

  @override
  String get bankAccount => 'Compte bancaire';

  @override
  String get idCard => 'Carte d\'identité';

  @override
  String get joinDate => 'Date d\'embauche';

  @override
  String get stipend => 'Indemnité';

  @override
  String get quickGlance => 'Aperçu rapide';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get recentTasks => 'Tâches récentes';

  @override
  String get dueToday => 'À faire aujourd\'hui';

  @override
  String tasksDue(int count) {
    return '$count pour aujourd\'hui';
  }

  @override
  String get hoursThisWeek => 'Heures cette semaine';

  @override
  String get workforceManagement => 'Gestion du personnel';

  @override
  String get workforceManagementSystem => 'Système de gestion du personnel';

  @override
  String get welcomeBackSimple => 'Bon retour';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get doingGreat => 'Vous faites du bon travail aujourd\'hui!';

  @override
  String get readyToStart => 'Prêt à commencer votre journée?';

  @override
  String get notClockedIn => 'Pas encore pointé';

  @override
  String get companyDeposits => 'Dépôts de l\'entreprise';

  @override
  String get noDueDate => 'Pas de date limite';

  @override
  String dueLabel(String date) {
    return 'Échéance: $date';
  }

  @override
  String get operationFailed => 'Opération échouée';

  @override
  String get adminDashboard => 'Tableau de bord administrateur';

  @override
  String get secretaryDashboard => 'Tableau de bord secrétaire';

  @override
  String get volunteerDashboard => 'Tableau de bord bénévole';

  @override
  String get employeeDashboard => 'Tableau de bord employé';

  @override
  String get activeTasks => 'Tâches actives';

  @override
  String get activeEmployees => 'Employés actifs';

  @override
  String get completionRate => 'Taux d\'achèvement';

  @override
  String get viewTasks => 'Voir les tâches';

  @override
  String get sendReminders => 'Envoyer des rappels';

  @override
  String get sendNotification => 'Envoyer une notification';

  @override
  String get newProject => 'Nouveau projet';

  @override
  String get editProject => 'Modifier le projet';

  @override
  String get projectDetails => 'Détails du projet';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get createProject => 'Créer un projet';

  @override
  String get updateProject => 'Mettre à jour le projet';

  @override
  String get daysLeft => 'Jours restants';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get reminderCenter => 'Centre de rappels';

  @override
  String get selectEmployees => 'Sélectionner les employés';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get messagePreview => 'Aperçu du message:';

  @override
  String selectedTemplates(int count) {
    return 'Modèles sélectionnés ($count)';
  }

  @override
  String get quickSend => 'Envoi rapide';

  @override
  String get totalReport => 'Total';

  @override
  String get lateArrivals => 'Arrivées tardives';

  @override
  String get weeklyAttendanceTrend => 'Tendance de présence hebdomadaire';

  @override
  String get attendanceDetails => 'Détails de présence';

  @override
  String get presentDays => 'Jours de présence';

  @override
  String get absentDays => 'Jours d\'absence';

  @override
  String get lateDays => 'Jours de retard';

  @override
  String get trackAttendance => 'Suivi de présence';

  @override
  String get manageTasks => 'Gérer les tâches';

  @override
  String get handlePayroll => 'Gérer la paie';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get atWorkLocation => 'Sur le lieu de travail';

  @override
  String get outsideWorkArea => 'Hors zone de travail';

  @override
  String get needsAttention => 'Nécessite attention';

  @override
  String get slideToClockIn => 'Glisser pour pointer l\'entrée';

  @override
  String get slideToClockOut => 'Glisser pour pointer la sortie';

  @override
  String get locationRequired =>
      'Vous devez être sur votre lieu de travail pour pointer';

  @override
  String failedWithError(String error) {
    return 'Échec: $error';
  }

  @override
  String get leaveApprovalMenu => 'Approbation de congé';

  @override
  String get salaryApprovalMenu => 'Approbation de salaire';

  @override
  String get workLocations => 'Lieux de travail';

  @override
  String get myWork => 'Mon travail';

  @override
  String get myAttendance => 'Ma présence';

  @override
  String get myDeposits => 'Mes dépôts';

  @override
  String get attendanceCalendar => 'Calendrier de présence';

  @override
  String get todayTimeline => 'Chronologie du jour';

  @override
  String clockedInAt(String time) {
    return 'Pointé à $time';
  }

  @override
  String workingTime(String time) {
    return 'Temps de travail: $time';
  }

  @override
  String get noAttendanceRecords => 'Aucun enregistrement de présence trouvé';

  @override
  String get pendingSync => 'Synchronisation en attente';

  @override
  String get verified => 'Vérifié ✓';

  @override
  String get autoLeftPerimeter => 'Auto (hors périmètre)';

  @override
  String get locationPermissionRequired =>
      'L\'autorisation de localisation est requise pour la présence';

  @override
  String get clockedInSuccess => 'Pointage d\'entrée réussi!';

  @override
  String get clockedOutSuccess => 'Pointage de sortie réussi!';

  @override
  String get recordingClockIn => 'Enregistrement du pointage d\'entrée...';

  @override
  String get recordingClockOut => 'Enregistrement du pointage de sortie...';

  @override
  String get daysSummary => 'Jours';

  @override
  String get legend => 'Légende';
}
