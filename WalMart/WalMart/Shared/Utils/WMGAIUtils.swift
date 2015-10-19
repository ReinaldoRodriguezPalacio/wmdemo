
//  WTGAIUtils.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 02/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum WMGAIUtils : String {


//case GAI_APP_KEY = "UA-52615607-1" // productivo
//case GAI_APP_KEY = "UA-68704781-1" // desarrollo
case GAI_APP_KEY = "UA-62456603-1"



case MODULE_HOME = "HOME"
case SCREEN_PRODUCTDETAIL = "SCREEN_PRODUCTDETAIL"
case SCREEN_SHOPPINGCART = "SHOPPING_CART"
    
case SCREEN_FILTER = "SCREEN_FILTER"
case SCREEN_SPLASH = "SCREEN_SPLASH"
case SCREEN_HOME = "SCREEN_HOME"
case SCREEN_CATEGORIES = "SCREEN_CATEGORIES"
case SCREEN_LISTS = "SCREEN_LISTS"
case SCREEN_STORELACATION = "SCREEN_STORELACATION"
case SCREEN_MORE = "SCREEN_MORE"
case SCREEN_PROFILE = "SCREEN_PROFILE"
case SCREEN_HELP = "SCREEN_HELP"
case SCREEN_PRESHOPPINGCART = "SCREEN_PRESHOPPINGCART"
case SCREEN_LOGIN = "SCREEN_LOGIN"
case MG_SCREEN_WISHLIST = "MG_SCREEN_WISHLIST"
case MG_SCREEN_CATEGORY = "MG_SCREEN_CATEGORY"
case MG_SCREEN_PRODUCTSCATEGORY = "MG_SCREEN_PRODUCTSCATEGORY"
case GR_SCREEN_CATEGORY = "GR_SCREEN_CATEGORY"
case GR_SCREEN_PRODUCTSCATEGORY = "GR_SCREEN_PRODUCTSCATEGORY"
case MG_SCREEN_SHOWLARTEIMAGES = "MG_SCREEN_SHOWLARTEIMAGES"
case GR_SCREEN_SHOWLARTEIMAGES = "GR_SCREEN_SHOWLARTEIMAGES"
case GR_SCREEN_DETAILLIST = "GR_SCREEN_DETAILLIST"
case GR_SCREEN_ADDRESSES = "GR_SCREEN_ADDRESSES"
case GR_SCREEN_CHECKOUT = "GR_SCREEN_CHECKOUT"
case GR_SCREEN_SHOPPINGCART = "GR_SCREEN_SHOPPINGCART"
case SCREEN_RECENTPURCHASES = "SCREEN_RECENTPURCHASES"
case MG_SCREEN_ADDRESSES = "MG_SCREEN_ADDRESSES"
case MG_SCREEN_ADDRESSESLIST = "MG_SCREEN_ADDRESSESLIST"
case GR_SCREEN_ADDRESSESLIST = "GR_SCREEN_ADDRESSESLIST"
case MG_SCREEN_ADDRESSESDETAIL = "MG_SCREEN_ADDRESSESDETAIL"
case GR_SCREEN_ADDRESSESDETAIL = "GR_SCREEN_ADDRESSESDETAIL"
case MG_SCREEN_RECENTPURCHASES_DETAIL = "MG_SCREEN_RECENTPURCHASES_DETAIL"
case GR_SCREEN_RECENTPURCHASES_DETAIL = "GR_SCREEN_RECENTPURCHASES_DETAIL"
case SCREEN_EDITPROFILE = "SCREEN_EDITPROFILE"
case SCREEN_SIGNUP = "SCREEN_SIGNUP"
case SCREEN_HELP_DETAIL = "SCREEN_HELP_DETAIL"
    
//MARK - CATEGORY
case CATEGORY_TUTORIAL_AUTH = "CATEGORY_TUTORIAL_AUTH"
case CATEGORY_TUTORIAL_NO_AUTH = "CATEGORY_TUTORIAL_NO_AUTH"
case GR_CATEGORY_BANNER_COLLECTION_VIEW = "GR_CATEGORY_BANNER_COLLECTION_VIEW"
case MG_CATEGORY_BANNER_COLLECTION_VIEW = "MG_CATEGORY_BANNER_COLLECTION_VIEW"
case CATEGORY_BANNER_TERMS = "CATEGORY_BANNER_TERMS"
case CATEGORY_SHOPPING_CAR_AUTH = "CATEGORY_SHOPPING_CAR_AUTH"
case CATEGORY_SHOPPING_CAR_NO_AUTH = "CATEGORY_SHOPPING_CAR_NO_AUTH"
case CATEGORY_NAVIGATION_BAR = "CATEGORY_NAVIGATION_BAR"
case CATEGORY_SEARCH = "CATEGORY_SEARCH"
case CATEGORY_SPECIAL_BANNER = "CATEGORY_SPECIAL_BANNER"
case CATEGORY_CAROUSEL = "CATEGORY_CAROUSEL"
case CATEGORY_SPECIAL_DETAILS = "CATEGORY_SPECIAL_DETAILS"
case CATEGORY_TAP_BAR = "CATEGORY_TAP_BAR"
case CATEGORY_PRODUCT_DETAIL_AUTH = "CATEGORY_PRODUCT_DETAIL_AUTH"
case CATEGORY_PRODUCT_DETAIL_NO_AUTH = "CATEGORY_PRODUCT_DETAIL_NO_AUTH"
case CATEGORY_SEARCH_PRODUCT = "CATEGORY_SEARCH_PRODUCT"
case CATEGORY_SEARCH_PRODUCT_FILTER_AUTH = "CATEGORY_SEARCH_PRODUCT_FILTER_AUTH"
case CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH = "CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH"
case MG_CATEGORY_SEARCH_PRODUCT_FILTER = "MG_CATEGORY_SEARCH_PRODUCT_FILTER"
case MG_CATEGORY_DEPARTMENT_VIEW_AUTH = "MG_DEPARTMENT_VIEW_AUTH"
case MG_CATEGORY_DEPARTEMNT_VIEW_NO_AUTH = "MG_DEPARTEMNT_VIEW_NO_AUTH"
case MG_CATEGORY_FAMILIES_LIST_AUTH = "MG_CATEGORY_FAMILIES_LIST_AUTH"
case MG_CATEGORY_FAMILIES_LIST_NO_AUTH = "MG_CATEGORY_FAMILIES_LIST_NO_AUTH"
case GR_CATEGORY_FAMILIES_LIST_AUTH = "GR_CATEGORY_FAMILIES_LIST_AUTH"
case GR_CATEGORY_FAMILIES_LIST_NO_AUTH = "GR_CATEGORY_FAMILIES_LIST_NO_AUTH"
case CATEGORY_SUPER = "CATEGORY_SUPER"
case CATEGORY_MY_LISTS = "CATEGORY_MY_LISTS"
case CATEGORY_WISHLIST_EMPTY = "CATEGORY_WISHLIST_EMPTY"
case CATEGORY_WISHLIST = "CATEGORY_WISHLIST"
case CATEGORY_PRACTILISTA = "CATEGORY_PRACTILISTA"
case CATEGORY_MY_LIST = "CATEGORY_MY_LIST"
case CATEGORY_ADD_TO_LIST = "CATEGORY_ADD_TO_LIST"
case CATEGORY_PRE_SHOPPING_CART = "CATEGORY_PRE_SHOPPING_CART"
case MG_CATEGORY_EMPTY_SUPER_CART = "MG_CATEGORY_EMPTY_SUPER_CART"
case GR_CATEGORY_EMPTY_SUPER_CART = "GR_CATEGORY_EMPTY_SUPER_CART"
case CATEGORY_SHOPPING_CART_SUPER = "CATEGORY_SHOPPING_CART_SUPER"
case CATEGORY_ADD_NOTE = "CATEGORY_ADD_NOTE"
case CATEGORY_SHOPPING_CART = "CATEGORY_SHOPPING_CART"
case CATEGORY_SHOPPING_CART_MG = "CATEGORY_SHOPPING_CART_MG"
case CATEGORY_BEFORE_TO_GO = "CATEGORY_BEFORE_TO_GO"
case GR_CATEGORY_SHOPPING_CART_AUTH = "GR_CATEGORY_SHOPPING_CART_AUTH"
case GR_CATEGORY_SHOPPING_CART_NO_AUTH = "GR_CATEGORY_SHOPPING_CART_NO_AUTH"
case CATEGORY_OPEN_KEYBOARD = "CATEGORY_OPEN_KEYBOARD"
case CATEGORY_KEYBOARD_WEIGHABLE = "CATEGORY_KEYBOARD_WEIGHABLE"
case GR_CATEGORY_SHOPPING_CART = "GR_CATEGORY_SHOPPING_CART"
case CATEGORY_NOTE_IN_KEY_BOARD = "CATEGORY_NOTE_IN_KEY_BOARD"
case CATEGORY_NOTIFICATION_AUTH = "CATEGORY_NOTIFICATION_AUTH"
case CATEGORY_NOTIFICATION_NO_AUTH = "CATEGORY_NOTIFICATION_NO_AUTH"
case CATEGORY_GENERATE_BILLING_AUTH = "CATEGORY_GENERATE_BILLING_AUTH"
case CATEGORY_GENERATE_BILLING_NO_AUTH = "CATEGORY_GENERATE_BILLING_NO_AUTH"
case CATEGORY_STORELOCATOR_AUTH = "ACTION_STORELOCATOR_AUTH"
case CATEGORY_STORELOCATOR_NO_AUTH = "ACTION_STORELOCATOR_NO_AUTH"
case CATEGORY_SUPPORT_AUTH = "CATEGORY_SUPPORT_AUTH"
case CATEGORY_SUPPORT_NO_AUTH = "CATEGORY_SUPPORT_NO_AUTH"
case CATEGORY_GENERATE_ORDER_AUTH = "CATEGORY_GENERATE_ORDER_AUTH"
case CATEGORY_GENERATE_ORDER_NO_AUTH = "CATEGORY_GENERATE_ORDER_NO_AUTH"
    
//MARK - ACTION
case ACTION_CLOSE_TUTORIAL = "ACTION_CLOSE_TUTORIAL"
case ACTION_CLOSE_END_TUTORIAL = "ACTION_CLOSE_END_TUTORIAL"
case ACTION_VIEW_BANNER_PRODUCT = "ACTION_VIEW_BANNER_PRODUCT"
case ACTION_VIEW_BANNER_CATEGORY = "ACTION_VIEW_BANNER_CATEGORY"
case ACTION_VIEW_BANNER_SEARCH_TEXT = "ACTION_VIEW_BANNER_SEARCH_TEXT"
case ACTION_VIEW_BANNER_TERMS = "ACTION_VIEW_BANNER_TERMS"
case ACTION_OPEN_PRE_SHOPPING_CART = "ACTION_OPEN_PRE_SHOPPING_CART"
case ACTION_GO_TO_HOME = "ACTION_GO_TO_HOME"
case ACTION_OPEN_SEARCH_OPTIONS = "ACTION_OPEN_SEARCH_OPTIONS"
case ACTION_CHANGE_ITEM = "ACTION_CHANGE_ITEM"
case ACTION_VIEW_SPECIAL_DETAILS = "ACTION_VIEW_SPECIAL_DETAILS"
case ACTION_OPEN_HOME = "ACTION_OPEN_HOME"
case ACTION_OPEN_MG = "ACTION_OPEN_MG"
case ACTION_OPEN_GR = "ACTION_OPEN_GR"
case ACTION_OPEN_LIST = "ACTION_OPEN_LIST"
case ACTION_OPEN_MORE_OPTION = "ACTION_OPEN_MORE_OPTION"
case ACTION_BACK = "ACTION_BACK"
case ACTION_PRODUCT_DETAIL_IMAGE_TAPPED = "ACTION_PRODUCT_DETAIL_IMAGE_TAPPED"
case ACTION_INFORMATION = "ACTION_INFORMATION"
case ACTION_ADD_WISHLIST = "ACTION_ADD_WISHLIST"
case ACTION_DELETE_WISHLIST = "ACTION_DELETE_WISHLIST"
case ACTION_SHARE = "ACTION_SHARE"
case ACTION_OPEN_KEYBOARD = "ACTION_OPEN_KEYBOARD"
case ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED = "ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED"
case ACTION_CANCEL = "ACTION_CANCEL"
case ACTION_TEXT_SEARCH = "ACTION_TEXT_SEARCH"
case ACTION_BARCODE_SCANNED_UPC = "ACTION_BARCODE_SCANNED_UPC"
case ACTION_SEARCH_BY_TAKING_A_PHOTO = "ACTION_SEARCH_BY_TAKING_A_PHOTO"
case ACTION_CANCEL_SEARCH = "ACTION_CANCEL_SEARCH"
case ACTION_BACK_SEARCH_PRODUCT = "ACTION_BACK_SEARCH_PRODUCT"
case ACTION_APPLY_FILTER = "ACTION_APPLY_FILTER"
case ACTION_SORT_BY_A_Z = "ACTION_SORT_BY_A_Z"
case ACTION_SORT_BY_Z_A = "ACTION_SORT_BY_Z_A"
case ACTION_SORT_BY_$_$$$ = "ACTION_SORT_BY_$_$$$"
case ACTION_SORT_BY_$$$_$ = "ACTION_SORT_BY_$$$_$"
case ACTION_BY_POPULARITY = "ACTION_BY_POPULARITY"
case ACTION_OPEN_CATEGORY_DEPARMENT = "ACTION_OPEN_CATEGORY_DEPARMENT"
case ACTION_OPEN_CATEGORY_FAMILY = "ACTION_OPEN_CATEGORY_FAMILY"
case ACTION_OPEN_CATEGORY_LINE = "ACTION_OPEN_CATEGORY_LINE"
case ACTION_SLIDER_PRICE_RANGE_SELECT = "ACTION_SLIDER_PRICE_RANGE_SELECT"
case ACTION_BRAND_SELECTION = "ACTION_BRAND_SELECTION"
case ACTION_SHOW_FAMILIES = "ACTION_SHOW_FAMILIES"
case ACTION_OPEN_LINES = "ACTION_OPEN_LINES"
case ACTION_SELECTED_LINE = "ACTION_SELECTED_LINE"
case ACTION_HIDE_HIGHLIGHTS = "ACTION_HIDE_HIGHLIGHTS"
case ACTION_VIEW_RECOMMENDED = "ACTION_VIEW_RECOMMENDED"
case ACTION_NEW_LIST = "ACTION_NEW_LIST"
case ACTION_EDIT_LIST = "ACTION_EDIT_LIST"
case ACTION_TAPPED_VIEW_DETAILS_WISHLIST = "ACTION_TAPPED_VIEW_DETAILS_WISHLIST"
case ACTION_TAPPED_VIEW_DETAILS_SUPERLIST = "ACTION_TAPPED_VIEW_DETAILS_SUPERLIST"
case ACTION_TAPPED_VIEW_DETAILS_MYLIST = "ACTION_TAPPED_VIEW_DETAILS_MYLIST"
case ACTION_BACK_MYLIST = "ACTION_BACK_MYLIST"
case ACTION_BACK_WISHLIST = "ACTION_BACK_WISHLIST"
case ACTION_EDIT_WISHLIST = "ACTION_BACK_EDIT_WISHLIST"
case ACTION_OPEN_DETAIL_WISHLIST = "ACTION_OPEN_DETAIL_WISHLIST"
case ACTION_CHECKOUT = "ACTION_CHECKOUT"
case ACTION_OPEN_PRACTILISTA = "ACTION_OPEN_PRACTILISTA"
case ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA = "ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA"
case ACTION_ADD_ALL_TO_SHOPPING_CART = "ACTION_ADD_ALL_TO_SHOPPING_CART"
case ACTION_DUPLICATE_LIST = "ACTION_DUPLICATE_LIST"
case ACTION_CANCEL_NEW_LIST = "ACTION_CANCEL_NEW_LIST"
case ACTION_CREATE_NEW_LIST = "ACTION_CREATE_NEW_LIST"
case ACTION_CANCEL_ADD_TO_LIST = "ACTION_CANCEL_ADD_TO_LIST"
case ACTION_EMPTY_LIST = "ACTION_EMPTY_LIST"
case ACTION_EDIT_MY_LIST = "ACTION_EDIT_MY_LIST"
case ACTION_BACK_MY_LIST = "ACTION_BACK_MY_LIST"
case ACTION_OPEN_PRODUCT_DETAIL = "ACTION_OPEN_PRODUCT_DETAIL"
case ACTION_DISABLE_PRODUCT = "ACTION_DISABLE_PRODUCT"
case ACTION_ENABLE_PRODUCT = "ACTION_ENABLE_PRODUCT"
case ACTION_GR_OPEN_CATEGORY = "ACTION_GR_OPEN_CATEGORY"
case ACTION_MG_OPEN_CATEGORY = "ACTION_MG_OPEN_CATEGORY"
case ACTION_GR_OPEN_SHOPPING_CART = "ACTION_GR_OPEN_SHOPPING_CART"
case ACTION_MG_OPEN_SHOPPING_CART = "ACTION_MG_OPEN_SHOPPING_CART"
case ACTION_CLOSED = "ACTION_CLOSED"
case ACTION_OPEN_SHOPPING_CART_SUPER = "ACTION_OPEN_SHOPPING_CART_SUPER"
case ACTION_OPEN_SHOPPING_CART_MG = "ACTION_OPEN_SHOPPING_CART_MG"
case ACTION_ADD_NOTE = "ACTION_ADD_NOTE"
case ACTION_ADD_NOTE_FOR_SEND = "ACTION_ADD_NOTE_FOR_SEND"
case ACTION_CART_CLOSED = "ACTION_CART_CLOSED"
case ACTION_EDIT_CART = "ACTION_EDIT_CART"
case ACTION_BACK_TO_PRE_SHOPPING_CART = "ACTION_BACK_TO_PRE_SHOPPING_CART"
case ACTION_QUANTITY_KEYBOARD = "ACTION_QUANTITY_KEYBOARD"
case ACTION_CHANGE_NUMER_OF_PIECES = "ACTION_CHANGE_NUMER_OF_PIECES"
case ACTION_ADD_TO_SHOPPING_CART = "ACTION_ADD_TO_SHOPPING_CART"
case ACTION_OPEN_LOGIN_PRE_CHECKOUT = "ACTION_OPEN_LOGIN_PRE_CHECKOUT"
case ACTION_ADD_ALL_WISHLIST = "ACTION_ADD_ALL_WISHLIST"
case ACTION_CHANGE_NUMER_OF_KG = "ACTION_CHANGE_NUMER_OF_KG"
case ACTION_ADD_MY_LIST = "ACTION_ADD_MY_LIST"
case ACTION_OK = "ACTION_OK"
case ACTION_REMOVE_ALL = "ACTION_REMOVE_ALL"
case ACTION_BACK_PRE_SHOPPING_CART = "ACTION_BACK_PRE_SHOPPING_CART"
case ACTION_REMOVE = "ACTION_REMOVE"
case ACTION_ADD_GRAMS = "ACTION_ADD_GRAMS"
case ACTION_DECREASE_GRAMS = "ACTION_DECREASE_GRAMS"
case ACTION_TAPPED_100_GR = "ACTION_TAPPED_100_GR"
case ACTION_TAPPED_250_GR = "ACTION_TAPPED_250_GR"
case ACTION_TAPPED_500_GR = "ACTION_TAPPED_500_GR"
case ACTION_TAPPED_750_GR = "ACTION_TAPPED_750_GR"
case ACTION_TAPPED_1_KG = "ACTION_TAPPED_1_KG"
case ACTION_UPDATE_SHOPPING_CART = "ACTION_UPDATE_SHOPPING_CART"
case ACTION_UPDATE_LIST = "ACTION_UPDATE_LIST"
case ACTION_OPEN_NOTE = "ACTION_OPEN_NOTE"
case ACTION_BACK_TO_MORE_OPTION = "ACTION_BACK_TO_MORE_OPTION"
case ACTION_OPEN_DETAIL_NOTIFICATION = "ACTION_OPEN_DETAIL_NOTIFICATION"
case ACTION_CLOSE_GERATE_BILLIG
case ACTION_BACK_TO_MAP = "ACTION_BACK_TO_MAP"
case ACTION_LIST_SHARE_STORE = "ACTION_LIST_SHARE_STORE"
case ACTION_LIST_CALL_STORE = "ACTION_LIST_CALL_STORE"
case ACTION_LIST_DIRECTIONS = "ACTION_LIST_DIRECTIONS"
case ACTION_LIST_SHOW_ON_MAP = "ACTION_LIST_SHOW_ON_MAP"
case ACTION_MAP_SHARE_STORE = "ACTION_MAP_SHARE_STORE"
case ACTION_MAP_CALL_STORE = "ACTION_MAP_CALL_STORE"
case ACTION_MAP_DIRECTIONS = "ACTION_MAP_DIRECTIONS"
case ACTION_STOREDETAIL = "ACTION_STOREDETAIL"
case ACTION_USER_CURRENT_LOCATION = "ACTION_USER_CURRENT_LOCATION"
case ACTION_MAP_TYPE = "ACTION_MAP_TYPE"
case ACTION_CALL_SUPPORT = "ACTION_CALL_SUPPORT"
case ACTION_EMAIL_SUPPORT = "ACTION_EMAIL_SUPPORT"
case ACTION_SHIPPING_OPTIONS = "ACTION_SHIPPING_OPTIONS"
case ACTION_PAYMENTOPTIONS = "ACTION_PAYMENTOPTIONS"
case ACTION_BUY = "ACTION_BUY"
    
    
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
    

    case EVENT_GR_EVENT_SHOPPINGCART_SHOP = "EVENT_GR_EVENT_SHOPPINGCART_SHOP"

    case EVENT_GR_EVENT_CHECKOUT_SENDORDER = "EVENT_GR_EVENT_CHECKOUT_SENDORDER"
    case EVENT_GR_EVENT_CHECKOUT_ERROR = "EVENT_GR_EVENT_CHECKOUT_ERROR"
    case EVENT_GR_EVENT_CHECKOUT_CONFIRMORDER = "EVENT_GR_EVENT_CHECKOUT_CONFIRMORDER"
    
}