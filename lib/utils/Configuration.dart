class Configuration {

  static double APP_VERSION = 0.1;

//  static String SERVER_URL = "https://app.ripapp.it/api/";

  static String SERVER_URL = "http://192.168.1.125:48795/api/";

  //configuration
  static final String APP_UNIQUE_DONWLOAD_URL = "http://onelink.to/w9s89d";
  static final String SEND_TELEGRAM_URL = "http://www.ripapp.it/telegrammi/?code=";
  static final String OneSignalAppID = "";
  static final String PROFILE_PHOTOS = "profile_photos";
  static final String DEMISE_PHOTOS = "demise_photos";
  static final Duration LOADING_TIMEOUT = Duration(milliseconds: 5000);
  static final int CONTACTS_BUFFER_SIZE = 100;
  static final int SYNC_CONTACTS_BUFFER_SIZE = 20;
  static final int TELEPHONE_BOOK_UPDATE_INTERVAL_DAYS = 5;
  static final int DEMISES_CHUNK_SIZE = 20;

  //endpoint
  static String GET_SERVER_VERSION = SERVER_URL + "productionready";
  static String USER_STATUS = SERVER_URL + "userstatus";
  static String UPDATE_USER = SERVER_URL + "auth/account";
  static String LOGIN = SERVER_URL + "login";
  static String CREATE_USER = SERVER_URL + "signup";
  static String CREATE_AGENCY_OPERATOR = SERVER_URL + "signupagencyoperator";
  static String CREATE_ADMIN = SERVER_URL + "admincreate";
  static String CREATE_AGENCY = SERVER_URL + "admin/agencycreate";
  static String CONNECT_AGENCY_TO_USER = SERVER_URL + "admin/connectagencytouser";
  static String GET_USER = SERVER_URL + "auth/account";
  static String GET_CITIES = SERVER_URL + "cities";
  static String SYNCHRONIZE_CONTACTS = SERVER_URL + "auth/phonebook";
  static String GET_DEMISES_BY_CITIES = SERVER_URL + "auth/search/demises";
  static String GET_MY_DEMISES = SERVER_URL + "auth/user/demises";
  static String AUTOCOMPLETE_DEMISES = SERVER_URL + "auth/search/demises/autocomplete";
  static String ADMIN_AUTOCOMPLETE_PHONE_NUMBER = SERVER_URL + "auth/account/search";
  static String AUTOCOMPLETE_CEMETERIES = SERVER_URL + "auth/cemetery/autocomplete";
  static String ADMIN_CREATE_DEMISE = SERVER_URL + "auth/demise";
  static String GET_NOTIFICATIONS = SERVER_URL + "auth/notifications";
  static String ADMIN_GET_ALL_DEMISES = SERVER_URL + "auth/demises";
  static String ADMIN_PUT_DEMISE = SERVER_URL + "auth/demise";
  static String ADMIN_DELETE_DEMISE = SERVER_URL + "auth/demise";
  static String GET_AGENCIES = SERVER_URL + "auth/agency/search?query=";
  static String SEND_CONTACTS_TO_AGENCY = SERVER_URL + "auth/agency/%s/phonebook";
  static String POST_PLAYER_ID = SERVER_URL + "auth/user/playerid/%s";

}