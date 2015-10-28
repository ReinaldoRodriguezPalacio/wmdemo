
//  WTGAIUtils.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 02/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum WMGAIUtils : String {


case GAI_APP_KEY = "UA-52615607-1" // productivo
//case GAI_APP_KEY = "UA-68704781-1" // desarrollo


    
    //Mark: All screen names
    case SCREEN_SPLASH = "Splash"
    case SCREEN_TUTORIAL = "Tutorial"
    case SCREEN_HOME = "Home"
    case SCREEN_PRODUCTDETAIL = "ProductDetail"
    case SCREEN_OPTIONSEARCHPRODUCT = "OptionSearchProduct"
    case SCREEN_TAKEPHOTO = "TakePhoto"
    case SCREEN_SCANBARCODE = "ScanBarCode"
    case SCREEN_FILTER = "Filter"
    case SCREEN_MGDEPARTMENT = "MGDepartment"
    case SCREEN_MGFAMILIES = "MGFamilies"
    case SCREEN_SUPER = "Super"
    case SCREEN_MYLIST = "MyList"
    case SCREEN_WISHLISTEMPTY = "WishlistEmpty"
    case SCREEN_WISHLIST = "WishList"
    case SCREEN_PRACTILISTA = "Practilista"
    case SCREEN_PACTILISTASDETAILS = "PractilistaDetail"
    case SCREEN_ADDTOLIST = "AddtoList"
    case SCREEN_MYLISTDETAILEMPTY = "MyListDetailEmpty"
    case SCREEN_PRESHOPPINGCART = "PreShoppingCart"
    case SCREEN_ADDTOSHOPPINGCARTALERT = "AddToShoppingCartAlert"
    case SCREEN_NOTESHOPPINGCART = "NoteShoppingCart"
    case SCREEN_SHOPPINGCART = "ShoppingCart"
    case SCREEN_SHOPPINGCARTMG = "ShoppingCartMG"
    case SCREEN_GRSHOPPINGCART = "GRShoppingCart"
    case SCREEN_MGSHOPPINGCART = "MGShoppingCart"
    case SCREEN_KEYBOARDGRAMS = "keyBoardGrams"
    case SCREEN_QUANTITYKEYBOARD = "QuantityKeyBoard"
    case SCREEN_MOREOPTIONS = "MoreOptions"
    case SCREEN_LOGIN = "Login"
    case SCREEN_EDITPROFILE = "EditProfile"
    case SCREEN_LEGALINFORMATION = "LegalInformation"
    case SCREEN_CHANGEPASSWORD = "ChangePassword"
    case SCREEN_MYADDRESSES = "MyAddresses"
    case SCREEN_MGMYADDRESSES = "MGMyAddresses"
    case SCREEN_GRMYADDRESSES = "GRMyAddresses"
    case SCREEN_TOPPURCHASED = "TopPurchased"
    case SCREEN_PREVIOUSORDERS = "PreviousOrders"
    case SCREEN_TERMSANDCONDITIONS = "TermsAndConditions"
    case SCREEN_SUPPORT = "Support"
    case SCREEN_STORELOCATORMAP = "StoreLocatorMap"
    case SCREEN_STORELOCATOR = "StoreLocator"
    case SCREEN_LISTSTORELOCATOR = "ListStoreLocator"
    case SCREEN_GENERATEBILLING = "GenerateBilling"
    case SCREEN_NOTIFICATION = "Notification"
    case SCREEN_CHECKOUT = "Checkout"
    case SCREEN_SELECTEDADDRESS = "SelectedAddress"
    case SCREEN_ADDNEWADDRESS = "AddNewAddress"
    case SCREEN_MGPREVIOUSORDERSDETAIL = "MGPreviousOrdersDetail"
    case SCREEN_GRPREVIOUSORDERSDETAIL = "GRPreviousOrdersDetail"
    case SCREEN_MGSEARCHRESULT = "MGSearchResult"
    case SCREEN_GRSEARCHRESULT = "GRSearchResult"
    case SCREEN_MGNEWADDRESSDELIVERY = "MGNewAddressDelivery"
    case SCREEN_PREVIOUSORDERDETAIL = "PreviousOrderDetail"
    case SCREEN_HOWTOUSETHEAPP = " HowToUseTheApp"
    case SCREEN_FREQUENTQUESTIONS = "FrequentQuestions"
    case SCREEN_ZOOMPRODUCTDETAIL = "ZoomProductDetail"
    case SCREEN_INVOICE = "SCREEN_INVOICE"
    
//MARK - CATEGORY
case CATEGORY_TUTORIAL_AUTH = "TUTORIAL_AUTH"
case CATEGORY_TUTORIAL_NO_AUTH = "TUTORIAL_NO_AUTH"
case GR_CATEGORY_BANNER_COLLECTION_VIEW = "GRBANNER_COLLECTION_VIEW"
case MG_CATEGORY_BANNER_COLLECTION_VIEW = "MGBANNER_COLLECTION_VIEW"
case CATEGORY_BANNER_TERMS = "BANNER_TERMS"
case CATEGORY_SHOPPING_CAR_AUTH = "SHOPPING_CAR_AUTH"
case CATEGORY_SHOPPING_CAR_NO_AUTH = "SHOPPING_CAR_NO_AUTH"
case CATEGORY_NAVIGATION_BAR = "NAVIGATION_BAR"
case CATEGORY_SEARCH = "SEARCH"
case CATEGORY_SPECIAL_BANNER = "SPECIAL_BANNER"
case CATEGORY_CAROUSEL = "CAROUSEL"
case CATEGORY_SPECIAL_DETAILS = "SPECIAL_DETAILS"
case CATEGORY_TAP_BAR = "TAP_BAR"
case CATEGORY_PRODUCT_DETAIL_AUTH = "PRODUCT_DETAIL_AUTH"
case CATEGORY_PRODUCT_DETAIL_NO_AUTH = "PRODUCT_DETAIL_NO_AUTH"
case CATEGORY_SEARCH_PRODUCT = "SEARCH_PRODUCT"
case CATEGORY_CAM_FIND_SEARCH = "CAM_FIND_SEARCH"
case CATEGORY_SCAN_BAR_CODE = "SCAN_BAR_CODE"
case CATEGORY_SEARCH_PRODUCT_FILTER_AUTH = "SEARCH_PRODUCT_FILTER_AUTH"
case CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH = "SEARCH_PRODUCT_FILTER_NO_AUTH"
case MG_CATEGORY_SEARCH_PRODUCT_FILTER = "MGSEARCH_PRODUCT_FILTER"
case MG_CATEGORY_DEPARTMENT_VIEW_AUTH = "MGDEPARTMENT_VIEW_AUTH"
case MG_CATEGORY_DEPARTEMNT_VIEW_NO_AUTH = "MGDEPARTEMNT_VIEW_NO_AUTH"
case MG_CATEGORY_ACCESSORY_AUTH = "MGACCESSORY_AUTH"
case MG_CATEGORY_ACCESSORY_NO_AUTH = "MGACCESSORY_NO_AUTH"
case GR_CATEGORY_ACCESSORY_AUTH = "GRACCESSORY_AUTH"
case GR_CATEGORY_ACCESSORY_NO_AUTH = "GRACCESSORY_NO_AUTH"
case MG_CATEGORY_FAMILIES_LIST_AUTH = "MGFAMILIES_LIST_AUTH"
case MG_CATEGORY_FAMILIES_LIST_NO_AUTH = "MGFAMILIES_LIST_NO_AUTH"
case GR_CATEGORY_FAMILIES_LIST_AUTH = "GRFAMILIES_LIST_AUTH"
case GR_CATEGORY_FAMILIES_LIST_NO_AUTH = "GRFAMILIES_LIST_NO_AUTH"
case CATEGORY_SUPER = "SUPER"
case CATEGORY_MY_LISTS = "MY_LISTS"
case CATEGORY_MY_LIST = "MY_LIST"
case CATEGORY_WISHLIST_EMPTY = "WISHLIST_EMPTY"
case CATEGORY_WISHLIST = "WISHLIST"
case CATEGORY_PRACTILISTA = "PRACTILISTA"
case CATEGORY_PRACTILISTA_AUTH = "PRACTILISTA_AUTH"
case CATEGORY_PRACTILISTA_NO_AUTH = "PRACTILISTA_NO_AUTH"
case CATEGORY_PRE_SHOPPING_CART = "PRE_SHOPPING_CART"
case MG_CATEGORY_EMPTY_SHOPPING_CART = "MGEMPTY_SHOPPING_CART"
case GR_CATEGORY_EMPTY_SHOPPING_CART = "GREMPTY_SHOPPING_CART"
case CATEGORY_SHOPPING_CART_SUPER = "SHOPPING_CART_SUPER"
case CATEGORY_SHOPPING_CART = "SHOPPING_CART"
case MG_CATEGORY_BEFORE_TO_GO = "MGBEFORE_TO_GO"
case GR_CATEGORY_SHOPPING_CART_AUTH = "GRSHOPPING_CART_AUTH"
case GR_CATEGORY_SHOPPING_CART_NO_AUTH = "GRSHOPPING_CART_NO_AUTH"
case MG_CATEGORY_SHOPPING_CART_AUTH = "MGSHOPPING_CART_AUTH"
case MG_CATEGORY_SHOPPING_CART_NO_AUTH = "MGSHOPPING_CART_NO_AUTH"
case CATEGORY_QUANTITY_KEYBOARD_AUTH = "QUANTITY_KEYBOARD_AUTH"
case CATEGORY_QUANTITY_KEYBOARD_NO_AUTH = "QUANTITY_KEYBOARD_NO_AUTH"
case CATEGORY_KEYBOARD_WEIGHABLE = "KEYBOARD_WEIGHABLE"
case GR_CATEGORY_SHOPPING_CART = "GRSHOPPING_CART"
case CATEGORY_NOTE_IN_KEY_BOARD = "NOTE_IN_KEY_BOARD"
case CATEGORY_NOTIFICATION_AUTH = "NOTIFICATION_AUTH"
case CATEGORY_NOTIFICATION_NO_AUTH = "NOTIFICATION_NO_AUTH"
case CATEGORY_GENERATE_BILLING_AUTH = "GENERATE_BILLING_AUTH"
case CATEGORY_GENERATE_BILLING_NO_AUTH = "GENERATE_BILLING_NO_AUTH"
case CATEGORY_STORELOCATOR_AUTH = "STORELOCATOR_AUTH"
case CATEGORY_STORELOCATOR_NO_AUTH = "STORELOCATOR_NO_AUTH"
case CATEGORY_SUPPORT_AUTH = "SUPPORT_AUTH"
case CATEGORY_SUPPORT_NO_AUTH = "SUPPORT_NO_AUTH"
case CATEGORY_GENERATE_ORDER_AUTH = "GENERATE_ORDER_AUTH"
case CATEGORY_GENERATE_ORDER_NO_AUTH = "GENERATE_ORDER_NO_AUTH"
case CATEGORY_KEYBOARD_GRAMS = "KEYBOARD_GRAMS"
case CATEGORY_MORE_OPTIONS_AUTH = "MORE_OPTIONS_AUTH"
case CATEGORY_MORE_OPTIONS_NO_AUTH = "MORE_OPTIONS_NO_AUTH"
case CATEGORY_LOGIN = "LOGIN"
case CATEGORY_FORGOT_PASSWORD = "FORGOT_PASSWORD"
case CATEGORY_CREATE_ACOUNT = "CREATE_ACOUNT"
case CATEGORY_EDIT_PROFILE = "EDIT_PROFILE"
case CATEGORY_LEGAL_INFORMATION = "LEGAL_INFORMATION"
case CATEGORY_CHANGE_PASSWORD = "CHANGE_PASSWORD"
case CATEGORY_MY_ADDRES = "MY_ADDRES"
case CATEGORY_GR_NEW_ADDRESS = "GR_NEW_ADDRESS"
case CATEGORY_MG_NEW_ADDRESS = "MG_NEW_ADDRESS"
case CATEGORY_GR_EDIT_ADDRESS = "GR_EDIT_ADDRESS"
case CATEGORY_MG_EDIT_ADDRESS = "MG_EDIT_ADDRESS"
case CATEGORY_ADD_TO_SHOPPING_CART_ALERT = "ADD_TO_SHOPPING_CART_ALERT"
case CATEGORY_TOP_PURCHASED = "TOP_PURCHASED"
case CATEGORY_PREVIOUS_ORDERS = "PREVIOUS_ORDERS"
case CATEGORY_TERMS_CONDITION_AUTH = "TERMS_CONDITION_AUTH"
case CATEGORY_TERMS_CONDITION_NO_AUTH  = "TERMS_CONDITION_NO_AUTH"
case CATEGORY_LIST_STORELOCATOR_AUTH = "LIST_STORELOCATOR_AUTH"
case CATEGORY_LIST_STORELOCATOR_NO_AUTH = "LIST_STORELOCATOR_NO_AUTH"
case CATEGORY_GENERATE_ORDER_OK = "GENERATE_ORDER_OK"
case CATEGORY_HOW_TO_USE_APP = "HOW_TO_USE_APP"

    
    
case ACTION_OPEN_BARCODE_SCANNED_UPC = "OPEN_BARCODE_SCANNED_UPC"
case ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO = "OPEN_SEARCH_BY_TAKING_A_PHOTO"
case ACTION_BARCODE_SCANNED_UPC = "BARCODE_SCANNED_UPC"
case ACTION_SEARCH_BY_TAKING_A_PHOTO = "SEARCH_BY_TAKING_A_PHOTO"
case ACTION_CANCEL_SEARCH = "CANCEL_SEARCH"
case ACTION_BACK_SEARCH_PRODUCT = "BACK_SEARCH_PRODUCT"
case ACTION_APPLY_FILTER = "APPLY_FILTER"
case ACTION_SORT_BY_A_Z = "SORT_BY_A_Z"
case ACTION_SORT_BY_Z_A = "SORT_BY_Z_A"
case ACTION_SORT_BY_$_$$$ = "SORT_BY_$_$$$"
case ACTION_SORT_BY_$$$_$ = "SORT_BY_$$$_$"
case ACTION_BY_POPULARITY = "BY_POPULARITY"
case ACTION_OPEN_CATEGORY_DEPARMENT = "OPEN_CATEGORY_DEPARMENT"
case ACTION_OPEN_CATEGORY = "OPEN_CATEGORY"
case ACTION_OPEN_CATEGORY_FAMILY = "OPEN_CATEGORY_FAMILY"
case ACTION_OPEN_CATEGORY_LINE = "OPEN_CATEGORY_LINE"
case ACTION_SLIDER_PRICE_RANGE_SELECT = "SLIDER_PRICE_RANGE_SELECT"
case ACTION_BRAND_SELECTION = "BRAND_SELECTION"
case ACTION_SHOW_FAMILIES = "SHOW_FAMILIES"
case ACTION_OPEN_ACCESSORY_LINES = "OPEN_ACCESSORY_LINES"
case ACTION_OPEN_LINES = "OPEN_LINES"
case ACTION_SELECTED_LINE = "SELECTED_LINE"
case ACTION_HIDE_HIGHLIGHTS = "HIDE_HIGHLIGHTS"
case ACTION_VIEW_RECOMMENDED = "VIEW_RECOMMENDED"
case ACTION_NEW_LIST = "NEW_LIST"
case ACTION_EDIT_LIST = "EDIT_LIST"
case ACTION_TAPPED_VIEW_DETAILS_WISHLIST = "TAPPED_VIEW_DETAILS_WISHLIST"
case ACTION_TAPPED_VIEW_DETAILS_SUPERLIST = "TAPPED_VIEW_DETAILS_SUPERLIST"
case ACTION_TAPPED_VIEW_DETAILS_MYLIST = "TAPPED_VIEW_DETAILS_MYLIST"
case ACTION_BACK_WISHLIST = "BACK_WISHLIST"
case ACTION_EDIT_WISHLIST = "BACK_EDIT_WISHLIST"
case ACTION_OPEN_DETAIL_WISHLIST = "OPEN_DETAIL_WISHLIST"
case ACTION_DELETE_PRODUCT_WISHLIST = "DELETE_PRODUCT_WISHLIST"
case ACTION_DELETE_ALL_PRODUCTS_WISHLIST = "DELETE_ALL_PRODUCTS_WISHLIST"
case ACTION_DELETE_PRODUCT_MYLIST = "DELETE_PRODUCT_MYLIST"
case ACTION_DELETE_PRODUCT_CART = "DELETE_PRODUCT_CART"
case ACTION_DELETE_ALL_PRODUCTS_CART = "DELETE_ALL_PRODUCTS_CART"
case ACTION_DELETE_ALL_PRODUCTS_MYLIST = "DELETE_ALL_PRODUCTS_MYLIST"
case ACTION_CHECKOUT = "CHECKOUT"
case ACTION_OPEN_PRACTILISTA = "OPEN_PRACTILISTA"
case ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA = "OPEN_PRODUCT_DETAIL_PRACTILISTA"
case ACTION_ADD_ALL_TO_SHOPPING_CART = "ADD_ALL_TO_SHOPPING_CART"
case ACTION_DUPLICATE_LIST = "DUPLICATE_LIST"
case ACTION_CANCEL_NEW_LIST = "CANCEL_NEW_LIST"
case ACTION_CREATE_NEW_LIST = "CREATE_NEW_LIST"
case ACTION_CANCEL_ADD_TO_LIST = "CANCEL_ADD_TO_LIST"
case ACTION_EMPTY_LIST = "EMPTY_LIST"
case ACTION_EDIT_MY_LIST = "EDIT_MY_LIST"
case ACTION_BACK_MY_LIST = "BACK_MY_LIST"
case ACTION_OPEN_PRODUCT_DETAIL = "OPEN_PRODUCT_DETAIL"
case ACTION_DISABLE_PRODUCT = "DISABLE_PRODUCT"
case ACTION_ENABLE_PRODUCT = "ENABLE_PRODUCT"
case ACTION_GR_OPEN_CATEGORY = "GR_OPEN_CATEGORY"
case ACTION_MG_OPEN_CATEGORY = "MG_OPEN_CATEGORY"
case ACTION_GR_OPEN_SHOPPING_CART = "GR_OPEN_SHOPPING_CART"
case ACTION_MG_OPEN_SHOPPING_CART = "MG_OPEN_SHOPPING_CART"
case ACTION_CLOSED = "CLOSED"
case ACTION_ERASE_QUANTITY = "ERASE_QUANTITY"
case ACTION_OPEN_SHOPPING_CART_SUPER = "OPEN_SHOPPING_CART_SUPER"
case ACTION_OPEN_SHOPPING_CART_MG = "OPEN_SHOPPING_CART_MG"
case ACTION_ADD_NOTE = "ADD_NOTE"
case ACTION_ADD_NOTE_FOR_SEND = "ADD_NOTE_FOR_SEND"
case ACTION_CART_CLOSED = "CART_CLOSED"
case ACTION_EDIT_CART = "EDIT_CART"
case ACTION_BACK_TO_PRE_SHOPPING_CART = "BACK_TO_PRE_SHOPPING_CART"
case ACTION_QUANTITY_KEYBOARD = "QUANTITY_KEYBOARD"
case ACTION_CHANGE_NUMER_OF_PIECES = "CHANGE_NUMER_OF_PIECES"
case ACTION_ADD_TO_SHOPPING_CART = "ADD_TO_SHOPPING_CART"
case ACTION_OPEN_LOGIN_PRE_CHECKOUT = "OPEN_LOGIN_PRE_CHECKOUT"
case ACTION_OPEN_LOGIN = "OPEN_LOGIN"
case ACTION_ADD_ALL_WISHLIST = "ADD_ALL_WISHLIST"
case ACTION_CHANGE_NUMER_OF_KG = "CHANGE_NUMER_OF_KG"
case ACTION_ADD_MY_LIST = "ADD_MY_LIST"
case ACTION_OK = "OK"
case ACTION_REMOVE_ALL = "REMOVE_ALL"
case ACTION_BACK_PRE_SHOPPING_CART = "BACK_PRE_SHOPPING_CART"
case ACTION_REMOVE = "REMOVE"
case ACTION_ADD_GRAMS = "ADD_GRAMS"
case ACTION_DECREASE_GRAMS = "DECREASE_GRAMS"
case ACTION_TAPPED_100_GR = "TAPPED_100_GR"
case ACTION_TAPPED_250_GR = "TAPPED_250_GR"
case ACTION_TAPPED_500_GR = "TAPPED_500_GR"
case ACTION_TAPPED_750_GR = "TAPPED_750_GR"
case ACTION_TAPPED_1_KG = "TAPPED_1_KG"
case ACTION_UPDATE_SHOPPING_CART = "UPDATE_SHOPPING_CART"
case ACTION_UPDATE_LIST = "UPDATE_LIST"
case ACTION_OPEN_KEYBOARD_KILO = "OPEN_KEYBOARD_KILO"
case ACTION_BACK_KEYBOARG_GRAMS = "BACK_KEYBOARG_GRAMS"
case ACTION_OPEN_NOTE = "OPEN_NOTE"
case ACTION_CLOSE_NOTE = "CLOSE_NOTE"
case ACTION_BACK_TO_MORE_OPTION = "BACK_TO_MORE_OPTION"
case ACTION_OPEN_DETAIL_NOTIFICATION = "OPEN_DETAIL_NOTIFICATION"
case ACTION_CLOSE_GERATE_BILLIG = "CLOSE_GERATE_BILLIG"
case ACTION_BACK_TO_MAP = "BACK_TO_MAP"
case ACTION_LIST_SHARE_STORE = "LIST_SHARE_STORE"
case ACTION_LIST_CALL_STORE = "LIST_CALL_STORE"
case ACTION_LIST_DIRECTIONS = "LIST_DIRECTIONS"
case ACTION_LIST_SHOW_ON_MAP = "LIST_SHOW_ON_MAP"
case ACTION_MY_LISTS_DETAIL_EMPTY = "MY_LISTS_DETAIL_EMPTY"
case ACTION_MAP_SHARE_STORE = "MAP_SHARE_STORE"
case ACTION_MAP_CALL_STORE = "MAP_CALL_STORE"
case ACTION_MAP_DIRECTIONS = "MAP_DIRECTIONS"
case ACTION_MAP_ROUTE_STORE = "MAP_ROUTE_STORE"
case ACTION_STOREDETAIL = "STOREDETAIL"
case ACTION_USER_CURRENT_LOCATION = "USER_CURRENT_LOCATION"
case ACTION_MAP_TYPE = "MAP_TYPE"
case ACTION_CALL_SUPPORT = "CALL_SUPPORT"
case ACTION_EMAIL_SUPPORT = "EMAIL_SUPPORT"
case ACTION_SHIPPING_OPTIONS = "SHIPPING_OPTIONS"
case ACTION_PAYMENTOPTIONS = "PAYMENTOPTIONS"
case ACTION_TYPE_DELIVERY = "TYPE_DELIVERY"
case ACTION_CHANGE_ADDRES_DELIVERY = "CHANGE_ADDRES_DELIVERY"
case ACTION_CHANGE_DELIVERY_TYPE = "CHANGE_DELIVERY_TYPE"
case ACTION_CHANGE_TIME_DELIVERY = "CHANGE_TIME_DELIVERY"
case ACTION_DATE_CHANGE = "DATE_CHANGE"
case ACTION_TIME_DELIVERY = "TIME_DELIVERY"
case ACTION_FINIHS_ORDER = "FINIHS_ORDER"
case ACTION_OPEN_CONFIRMATION = "OPEN_CONFIRMATION"    
case ACTION_DISCOUT_ASOCIATE = "DISCOUT_ASOCIATE"
case ACTION_BUY_GR = "BUY_GR"
case ACTION_CLOSE_SESSION = "CLOSE_SESSION"
case ACTION_OPEN_ACCOUNT_ADDRES = "OPEN_ACCOUNT_ADDRES"
case ACTION_OPEN_MORE_ITEMES_PURCHASED = "OPEN_MORE_ITEMES_PURCHASED"
case ACTION_OPEN_PREVIOUS_ORDERS = "OPEN_PREVIOUS_ORDERS"
case ACTION_OPEN_SCANNED_TICKET = "OPEN_SCANNED_TICKET"
case ACTION_OPEN_STORE_LOCATOR = "OPEN_STORE_LOCATOR"
case ACTION_OPEN_ELECTRONIC_BILLING = "OPEN_ELECTRONIC_BILLING"
case ACTION_OPEN_NOTIFICATIONS = "OPEN_NOTIFICATIONS"
case ACTION_OPEN_HOW_USE_APP = "OPEN_HOW_USE_APP"
case ACTION_OPEN_SUPPORT = "OPEN_SUPPORT"
case ACTION_OPEN_HELP = "OPEN_HELP"
case ACTION_OPEN_TERMS_AND_CONDITIONS = "OPEN_TERMS_AND_CONDITIONS"
case ACTION_ENABLE_PROMO = "ENABLE_PROMO"
case ACTION_DISBALE_PROMO = "DISBALE_PROMO"
case ACTION_LEGAL_ACEPT = "LEGAL_ACEPT"
case ACTION_LEGAL_NO_ACEPT = "LEGAL_NO_ACEPT"
case ACTION_CONTINUE_BUYING = "CONTINUE_BUYING"
case ACTION_OPEN_TUTORIAL = "OPEN_TUTORIAL"
case ACTION_OPEN_QUESTION = "OPEN_QUESTION"
case ACTION_OPEN_RATE_APP = "OPEN_RATE_APP"
    //MARK - ACTION
case ACTION_CLOSE_TUTORIAL = "CLOSE_TUTORIAL"
case ACTION_CLOSE_END_TUTORIAL = "CLOSE_END_TUTORIAL"
case ACTION_VIEW_BANNER_PRODUCT = "VIEW_BANNER_PRODUCT"
case ACTION_VIEW_BANNER_CATEGORY = "VIEW_BANNER_CATEGORY"
case ACTION_VIEW_BANNER_SEARCH_TEXT = "VIEW_BANNER_SEARCH_TEXT"
case ACTION_VIEW_BANNER_TERMS = "VIEW_BANNER_TERMS"
case ACTION_OPEN_PRE_SHOPPING_CART = "OPEN_PRE_SHOPPING_CART"
case ACTION_GO_TO_HOME = "GO_TO_HOME"
case ACTION_OPEN_SEARCH_OPTIONS = "OPEN_SEARCH_OPTIONS"
case ACTION_CHANGE_ITEM = "CHANGE_ITEM"
case ACTION_VIEW_SPECIAL_DETAILS = "VIEW_SPECIAL_DETAILS"
case ACTION_OPEN_HOME = "OPEN_HOME"
case ACTION_OPEN_MG = "OPEN_MG"
case ACTION_OPEN_GR = "OPEN_GR"
case ACTION_OPEN_LIST = "OPEN_LIST"
case ACTION_OPEN_MORE_OPTION = "OPEN_MORE_OPTION"
case ACTION_BACK = "BACK"
case ACTION_PRODUCT_DETAIL_IMAGE_TAPPED = "PRODUCT_DETAIL_IMAGE_TAPPED"
case ACTION_INFORMATION = "INFORMATION"
case ACTION_ADD_TO_LIST = "ADD_TO_LIST"
    case ACTION_ADD_WISHLIST = "ADD_WISHLIST"
    case ACTION_DELETE_WISHLIST = "DELETE_WISHLIST"
    case ACTION_SHARE = "SHARE"
    case ACTION_OPEN_KEYBOARD = "OPEN_KEYBOARD"
    case ACTION_CLOSE_KEYBOARD = "CLOSE_KEYBOARD"
    case ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED = "BUNDLE_PRODUCT_DETAIL_TAPPED"
    case ACTION_CANCEL = "CANCEL"
    case ACTION_TEXT_SEARCH = "TEXT_SEARCH"
    case ACTION_SHOW_ORDER_DETAIL = "SHOW_ORDER_DETAIL"
    case ACTION_SHOW_LIST_STORE_LOCATOR = "SHOW_LIST_STORE_LOCATOR"
    case ACTION_SHOW_MAP_STORE_LOCATOR = "SHOW_MAP_STORE_LOCATOR"
    case ACTION_RECOVER_PASSWORD = "RECOVER_PASSWORD"
    case ACTION_LOGIN_USER = "LOGIN_USER"
    case ACTION_OPEN_CREATE_ACOUNT = "OPEN_CREATE_ACOUNT"
    case ACTION_OPEN_EDIT_PROFILE  = "OPEN_EDIT_PROFILE"
    case ACTION_SAVE  = "SAVE"
    case ACTION_OPEN_LEGAL_INFORMATION  = "OPEN_LEGAL_INFORMATION"
    case ACTION_OPEN_FORM_CHANGE_PASSWORD = "OPEN_FORM_CHANGE_PASSWORD"
    case ACTION_OPEN_GR_NEW_ADDRES = "OPEN_GR_NEW_ADDRES"
    case ACTION_OPEN_MG_NEW_ADDRES = "OPEN_MG_NEW_ADDRES"
    case ACTION_GR_SHOW_ADDREES_DETAIL = "GR_SHOW_ADDREES_DETAIL"
    case ACTION_MG_DELIVERY_SHOW_ADDREES_DETAIL = "MG_DELIVERY_SHOW_ADDREES_DETAIL"
    case ACTION_MG_BILL_SHOW_ADDREES_DETAIL = "MG_BILL_SHOW_ADDREES_DETAIL"
    case ACTION_GR_SET_ADDRESS_PREFERRED = "GR_SET_ADDRESS_PREFERRED"
    case ACTION_MG_SET_ADDRESS_PREFERRED = "MG_SET_ADDRESS_PREFERRED"
    case ACTION_MG_DELETE_ADDRESS = "MG_DELETE_ADDRESS"
    case ACTION_GR_DELETE_ADDRESS = "GR_DELETE_ADDRESS"
    case ACTION_GR_SAVE_ADDRESS = "GR_SAVE_ADDRESS"
    case ACTION_MG_SAVE_ADDRESS = "MG_SAVE_ADDRESS"
    case ACTION_GR_UPDATE_ADDRESS = "GR_UPDATE_ADDRESS"
    case ACTION_MG_UPDATE_ADDRESS = "MG_UPDATE_ADDRESS"
    case ACTION_SHOW_STORE_LOCATOR_IN_MAP = "SHOW_STORE_LOCATOR_IN_MAP"
    
    //MARK EVENTOS ANTERIORES
    case EVENT_PUSHNOTIFICATION = "EVENT_PUSHNOTIFICATION"
    case EVENT_SEARCHPRESS = "EVENT_SEARCHPRESS"
    case EVENT_SEARCHACTION = "EVENT_SEARCHACTION"
    case MG_EVENT_BANNERPRESS = "MG_EVENT_BANNERPRESS"
    case GR_EVENT_BANNERPRESS = "GR_EVENT_BANNERPRESS"
    case MG_EVENT_SPECIALPRESS = "MG_EVENT_SPECIALPRESS"
    case GR_EVENT_SPECIALPRESS = "GR_EVENT_SPECIALPRESS"
    case EVENT_SPECIALCHANGE = "MG_EVENT_SPECIALCHANGE"
    case MG_EVENT_SHOWPRODUCTDETAIL = "MG_EVENT_SHOWPRODUCTDETAIL"
    case GR_EVENT_SHOWPRODUCTDETAIL = "GR_EVENT_SHOWPRODUCTDETAIL"
    case MG_EVENT_FILTERDATA = "MG_EVENT_FILTERDATA"
    case GR_EVENT_FILTERDATA = "GR_EVENT_FILTERDATA"
    case MG_EVENT_PRODUCTSCATEGORY_ADDTOSHOPPINGCART = "MG_EVENT_PRODUCTSCATEGORY_ADDTOSHOPPINGCART"
    case GR_EVENT_PRODUCTSCATEGORY_ADDTOSHOPPINGCART = "GR_EVENT_PRODUCTSCATEGORY_ADDTOSHOPPINGCART"
    case MG_EVENT_PRODUCTDETAIL_SHOWLARGEIMAGE = "MG_EVENT_PRODUCTDETAIL_SHOWLARGEIMAGE"
    case GR_EVENT_PRODUCTDETAIL_SHOWLARGEIMAGE = "GR_EVENT_PRODUCTDETAIL_SHOWLARGEIMAGE"
    case MG_EVENT_PRODUCTDETAIL_INFORMATION = "MG_EVENT_PRODUCTDETAIL_INFORMATION"
    case GR_EVENT_PRODUCTDETAIL_INFORMATION = "GR_EVENT_PRODUCTDETAIL_INFORMATION"
    case MG_EVENT_PRODUCTDETAIL_ADDTOWISHLIST = "MG_EVENT_PRODUCTDETAIL_ADDTOWISHLIST"
    case GR_EVENT_PRODUCTDETAIL_ADDTOLIST = "GR_EVENT_PRODUCTDETAIL_ADDTOLIST"
    case GR_EVENT_PRODUCTDETAIL_ADDTOLISTCOMPLETE = "GR_EVENT_PRODUCTDETAIL_ADDTOLISTCOMPLETE"
    case MG_EVENT_PRODUCTDETAIL_REMOVEFROMWISHLIST = "MG_EVENT_PRODUCTDETAIL_REMOVEFROMWISHLIST"
    case GR_EVENT_PRODUCTDETAIL_REMOVEFROMLIST = "GR_EVENT_PRODUCTDETAIL_REMOVEFROMLIST"
    case MG_EVENT_PRODUCTDETAIL_SHAREPRODUCT = "MG_EVENT_PRODUCTDETAIL_SHAREPRODUCT"
    case GR_EVENT_PRODUCTDETAIL_SHAREPRODUCT = "GR_EVENT_PRODUCTDETAIL_SHAREPRODUCT"
    case MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART = "MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART"
    case GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART = "GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART"
    case MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTCOMPLETE = "MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTCOMPLETE"
    case GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTCOMPLETE = "GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTCOMPLETE"
    case GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTADDCOMMENT = "GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCARTADDCOMMENT"
    case MG_EVENT_PRODUCTDETAIL_RELATEDPRODUCT = "MG_EVENT_PRODUCTDETAIL_RELATEDPRODUCT"
    case GR_EVENT_LISTS_EDITLISTS = "GR_EVENT_LISTS_EDITLISTS"
    case GR_EVENT_LISTS_DELETE = "GR_EVENT_LISTS_DELETE"
    case GR_EVENT_LISTS_NEWLIST = "GR_EVENT_LISTS_NEWLIST"
    case GR_EVENT_LISTS_NEWLISTCOMPLETE = "GR_EVENT_LISTS_NEWLISTCOMPLETE"
    case GR_EVENT_LISTS_SEARCH = "GR_EVENT_LISTS_SEARCH"
    case GR_EVENT_LISTS_SEARCHCOMPLETE = "GR_EVENT_LISTS_SEARCHCOMPLETE"
    case GR_EVENT_LISTS_SHOWLISTDETAIL = "GR_EVENT_LISTS_SHOWLISTDETAIL"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_EDIT = "GR_EVENT_LISTS_SHOWLISTDETAIL_EDIT"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_ENDEDIT = "GR_EVENT_LISTS_SHOWLISTDETAIL_ENDEDIT"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEALL = "GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEALL"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEPRODUCT = "GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEPRODUCT"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_CHANGEQUANTITY = "GR_EVENT_LISTS_SHOWLISTDETAIL_CHANGEQUANTITY"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_SHOPALL = "GR_EVENT_LISTS_SHOWLISTDETAIL_SHOPALL"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST = "GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST"
    case GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL = "GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL"
    case EVENT_STORELOCATOR_LIST = "EVENT_STORELOCATOR_LIST"
    case EVENT_STORELOCATOR_MAP = "EVENT_STORELOCATOR_MAP"
    case EVENT_STORELOCATOR_MAP_MODE_MAP = "EVENT_STORELOCATOR_MAP_MODE_MAP"
    case EVENT_STORELOCATOR_MAP_MODE_SATELITE = "EVENT_STORELOCATOR_MAP_MODE_SATELITE"
    case EVENT_STORELOCATOR_MAP_USERLOCATION = "EVENT_STORELOCATOR_MAP_USERLOCATION"
    case EVENT_STORELOCATOR_MAP_SHOWSTOREDETAIL = "EVENT_STORELOCATOR_MAP_SHOWSTOREDETAIL"
    case EVENT_STORELOCATOR_MAP_SHARESTOREDETAIL = "EVENT_STORELOCATOR_MAP_SHARESTOREDETAIL"
    case EVENT_STORELOCATOR_MAP_CALLSTORE = "EVENT_STORELOCATOR_MAP_CALLSTORE"
    case EVENT_STORELOCATOR_MAP_DIRECTION = "EVENT_STORELOCATOR_MAP_DIRECTION"
    case EVENT_STORELOCATOR_MAP_HIDESTOREDETAIL = "EVENT_STORELOCATOR_MAP_HIDESTOREDETAIL"
    case EVENT_STORELOCATOR_LIST_SHOWSTOREINMAP = "EVENT_STORELOCATOR_LIST_SHOWSTOREINMAP"
    case EVENT_STORELOCATOR_LIST_DIRECTIONS = "EVENT_STORELOCATOR_LIST_DIRECTIONS"
    case EVENT_STORELOCATOR_LIST_CALLSTORE = "EVENT_STORELOCATOR_LIST_CALLSTORE"
    case EVENT_STORELOCATOR_LIST_DIRECTION = "EVENT_STORELOCATOR_LIST_DIRECTION"
    case EVENT_PROFILE_CLOSESESSION = "EVENT_PROFILE_CLOSESESSION"
    case EVENT_PROFILE_EDITPROFILE = "EVENT_PROFILE_EDITPROFILE"
    case EVENT_PROFILE_CHANGEPASSWORD = "EVENT_PROFILE_CHANGEPASSWORD"
    case EVENT_PROFILE_MYADDRESSES =  "EVENT_PROFILE_MYADDRESSES"
    case EVENT_PROFILE_MYADDRESSES_GR = "EVENT_PROFILE_MYADDRESSES_GR"
    case EVENT_PROFILE_MYADDRESSES_MG = "EVENT_PROFILE_MYADDRESSES_MG"
    case EVENT_PROFILE_MYADDRESSES_CREATE_GR = "EVENT_PROFILE_MYADDRESSES_CREATE_GR"
    case EVENT_PROFILE_MYADDRESSES_CREATE_MG = "EVENT_PROFILE_MYADDRESSES_CREATE_MG"
    case EVENT_PROFILE_MYADDRESSES_EDIT_GR = "EVENT_PROFILE_MYADDRESSES_EDIT_GR"
    case EVENT_PROFILE_MYADDRESSES_EDIT_MG = "EVENT_PROFILE_MYADDRESSES_EDIT_MG"
    case EVENT_PROFILE_RECENTPURCHASES = "EVENT_PROFILE_RECENTPURCHASES"
    case EVENT_PROFILE_RECENTPURCHASES_DETAIL = "EVENT_PROFILE_RECENTPURCHASES_DETAIL"
    case EVENT_PROFILE_RECENTPURCHASES_DETAIL_ADDTOSHOPPINGCART = "EVENT_PROFILE_RECENTPURCHASES_DETAIL_ADDTOSHOPPINGCART"
    case EVENT_PROFILE_RECENTPURCHASES_DETAIL_ADDTOSHOPPINGCARTCOMPLETE = "EVENT_PROFILE_RECENTPURCHASES_DETAIL_ADDTOSHOPPINGCARTCOMPLETE"
    case EVENT_HELP_DETAIL = "EVENT_HELP_DETAIL"
    case EVENT_LOGIN_CREATEACCOUNT = "EVENT_LOGIN_CREATEACCOUNT"
    case EVENT_LOGIN_USERDIDLOGIN = "EVENT_LOGIN_USERDIDLOGIN"
    case EVENT_SIGNUP_CREATEUSER = "EVENT_SIGNUP_CREATEUSER"
    

    
}