#' Looker Data Column Specifications
#'
#' Defines column specifications for different custom Looks
#'
#' @export
look_specs <- list(
  CE_Referrals_new = readr::cols(
    PersonalID = readr::col_character(),
    UniqueID = readr::col_character(),
    ReferringEnrollmentID = readr::col_character(),
    ReferralID = readr::col_character(),
    ExitUpdatedTime = readr::col_datetime(),
    LastUpdated = readr::col_date(),
    ReferralEndDate = readr::col_date(),
    ReferringAgency = readr::col_character(),
    ReferringProjectID = readr::col_character(),
    ReferredProjectID = readr::col_character(),
    ReferringProjectName = readr::col_character(),
    ReferredProjectName = readr::col_character(),
    ReferringPTC = readr::col_character(),
    ReferredPTC = readr::col_character(),
    ReferringHouseholdID = readr::col_character(),
    ReferredDate = readr::col_date(),
    ReferralAcceptedDate = readr::col_date(),
    ReferralCurrentlyOnQueue = readr::col_character(),
    ExitDestination = readr::col_character(),
    ExitHoused = readr::col_character(),
    DaysInQueue = readr::col_integer(),
    RemovedFromQueueReason = readr::col_character(),
    RemovedFromQueueSubreason = readr::col_character(),
    IsReassigned = readr::col_character(),
    ReassignedDate = readr::col_date(),
    ReferralDaysElapsed = readr::col_integer(),
    DeniedInfo = readr::col_character(),
    DeniedByType = readr::col_character(),
    DeniedReason = readr::col_character(),
    ExitAuto = readr::col_character(),
    ActiveInProject = readr::col_character(),
    IsLastEnrollment = readr::col_character(),
    IsLastReferral = readr::col_character(),
    `Coordinated Entry Event Referral Result` = readr::col_character()
  ),
  Client_MentalHealth = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    ScoreDate = readr::col_date(),
    Deleted = readr::col_character(),
    MentalHealth = readr::col_character(),
    MentalHealthLongTerm = readr::col_character(),
    MentalHealthServices = readr::col_character(),
    SubstanceAbuseServices = readr::col_character(),
    SubstanceAbuse = readr::col_character(),
    SubstanceAbuseLongTerm = readr::col_character()
  ),
  Client_Offer = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    AcceptDeclineDate = readr::col_date(),
    OfferAccepted = readr::col_character(),
    PHTypeOffered = readr::col_character(),
    OfferDate = readr::col_date()
  ),
  Client_SPDAT = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    ScoreDate = readr::col_date(),
    Score = readr::col_integer(),
    CustomScore = readr::col_integer(),
    Deleted = readr::col_character(),
    Name = readr::col_character(),
    Total = readr::col_integer()
  ),
  Client_UniqueID = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character()
  ),
  Client = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    EnrollmentID = readr::col_character(),
    DateVeteranIdentified = readr::col_date(),
    PHTrack = readr::col_character(),
    ExpectedPHDate = readr::col_date(),
    HOMESID = readr::col_character(),
    ListStatus = readr::col_character(),
    VAEligible = readr::col_character(),
    SSVFIneligible = readr::col_character(),
    C19ConsentToVaccine = readr::col_character(),
    C19VaccineConcerns = readr::col_character()
  ),
  Contact = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    EnrollmentID = readr::col_character(),
    CurrentLivingSituation = readr::col_character(),
    ProgramName = readr::col_character(),
    ContactDate = readr::col_date(),
    LocationDetails = readr::col_character()
  ),
  Enrollment = readr::cols(
    PersonalID = readr::col_character(),
    EnrollmentID = readr::col_character(),
    UserCreating = readr::col_character(),
    CountyServed = readr::col_character(),
    CountyPrior = readr::col_character(),
    LastPermanentAddress = readr::col_character()
  ),
  Program_lookup = readr::cols(
    ProgramID = readr::col_character(),
    ProgramName = readr::col_character(),
    ProgramActive = readr::col_character(),
    ProjectType = readr::col_character(),
    `Participation Status` = readr::col_character(),
    AgencyID = readr::col_character(),
    AgencyName = readr::col_character(),
    AgencyActive = readr::col_character(),
    `Property Manager` = readr::col_character(),
    `Start Date` = readr::col_date(),
    `End Date` = readr::col_date(),
    `Last Updated Date` = readr::col_date()
  ),
  Project = readr::cols(
    ProjectID = readr::col_character(),
    ProjectName = readr::col_character(),
    ProjectTypeCode = readr::col_character(),
    Website = readr::col_character(),
    Phone = readr::col_character(),
    Hours = readr::col_character(),
    APCountiesGeneral = readr::col_character(),
    APCountiesVeteran = readr::col_character(),
    APCountiesYouth = readr::col_character(),
    CoCCompDocsReceived = readr::col_character(),
    CoCCompChronicPrioritization = readr::col_character(),
    CoCCompCostPerExit = readr::col_character(),
    CoCCompHousingFirst = readr::col_character(),
    CoCCompOnTrackSpending = readr::col_character(),
    CoCCompUnspentFunds = readr::col_character(),
    Geocode = readr::col_character(),
    Address = readr::col_character(),
    Address2 = readr::col_character(),
    City = readr::col_character(),
    ZIP = readr::col_character(),
    FundingSourceCode = readr::col_integer(),
    NonFederalFundingSourceCode = readr::col_integer(),
    OrganizationName = readr::col_character(),
    FundingSourceID = readr::col_character(),
    ProgramCoC = readr::col_character()
  ),
  Services = readr::cols(
    UniqueID = readr::col_character(),
    PersonalID = readr::col_character(),
    ServiceID = readr::col_character(),
    ServiceItemID = readr::col_character(),
    HouseholdID = readr::col_character(),
    EnrollmentID = readr::col_character(),
    ServiceStartDate = readr::col_date(),
    ServiceEndDate = readr::col_date(),
    ServiceItemName = readr::col_character(),
    FundName = readr::col_character(),
    ServiceAmount = readr::col_double(),
    FundingSourceID = readr::col_character()
  ),
  UserNamesIDs = readr::cols(
    UserCreated = readr::col_character(),
    UserCreatedText = readr::col_character()
  ),
  User = readr::cols(
    UserID = readr::col_character(),
    Deleted = readr::col_character(),
    ProjectID = readr::col_character(),
    ProjectName = readr::col_character()
  )
)
