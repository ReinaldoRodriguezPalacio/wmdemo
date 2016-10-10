
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
//case GAI_APP_KEY = "UA-79544417-1" // QA - AT


    
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
    case SCREEN_SCHOOLLIST = "SchoolList"
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
    case SCREEN_SIGNUP = "SignUp"
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
    case SCREEN_INVOICE = "Invoice"
    case SCREEN_REFERED = "Refered"
    case SCREEN_REMINDER = "Reminder"
    case SCREEN_GRCHECKOUT = "GRCheckout"
    case SCREEN_GRADESLIST = "GradesList"
    case SCREEN_LANDINGPAGE = "LandingPage"
    
//MARK - CATEGORY
    case GR_CATEGORY_BANNER_COLLECTION_VIEW =  "C_GrbannerCollectionView"
    case MG_CATEGORY_BANNER_COLLECTION_VIEW =  "C_MgbannerCollectionView"
    case CATEGORY_TUTORIAL_AUTH = "C_Tutorial"
    case CATEGORY_TUTORIAL_NO_AUTH = "C_TutorialNoAuth"
    case CATEGORY_BANNER_TERMS =  "C_BannerTerms"
    case CATEGORY_SHOPPING_CAR_AUTH =  "C_ShoppingCartAuth"
    case CATEGORY_SHOPPING_CAR_NO_AUTH =  "C_ShoppingCartNoAuth"
    case CATEGORY_NAVIGATION_BAR =  "C_NavigationBar"
    case CATEGORY_SEARCH =  "C_Search"
    case CATEGORY_SPECIAL_BANNER = "C_SpecialBanner"
    case CATEGORY_CAROUSEL =  "C_Carousel"
    case CATEGORY_SPECIAL_DETAILS =  "C_SpecialDetails"
    case CATEGORY_TAP_BAR =  "C_TabBar"
    case CATEGORY_NOTIFICATION =  "C_Notification"
    case CATEGORY_PRODUCT_DETAIL_AUTH =  "C_ProductDetailAuth"
    case CATEGORY_PRODUCT_DETAIL_NO_AUTH =  "C_ProductDetailNoAuth"
    case CATEGORY_SEARCH_PRODUCT =  "C_SearchProduct"
    case CATEGORY_CAM_FIND_SEARCH_AUTH =  "C_CamFindSearchAuth"
    case CATEGORY_CAM_FIND_SEARCH_NO_AUTH =  "C_CamFindSearchNoAuth"
    case CATEGORY_SCAN_BAR_CODE =  "C_ScanBarCode"
    case CATEGORY_SEARCH_PRODUCT_FILTER_AUTH =  "C_SearchProductFilterAuth"
    case CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH =  "C_SearchProductFilterNoAuth"
    case MG_CATEGORY_SEARCH_PRODUCT_FILTER =  "C_MgsearchProductFilter"
    case MG_CATEGORY_DEPARTMENT_VIEW_AUTH =  "C_MgdepartmentViewAuth"
    case MG_CATEGORY_DEPARTEMNT_VIEW_NO_AUTH =  "C_MgdepartemntViewNoAuth"
    case MG_CATEGORY_ACCESSORY_AUTH =  "C_MgaccessoryAuth"
    case MG_CATEGORY_ACCESSORY_NO_AUTH =  "C_MgaccessoryNoAuth"
    case GR_CATEGORY_ACCESSORY_AUTH =  "C_GraccessoryAuth"
    case GR_CATEGORY_ACCESSORY_NO_AUTH =  "C_GraccessoryNoAuth"
    case MG_CATEGORY_FAMILIES_LIST_AUTH =  "C_MgfamiliesListAuth"
    case MG_CATEGORY_FAMILIES_LIST_NO_AUTH =  "C_MgfamiliesListNoAuth"
    case GR_CATEGORY_FAMILIES_LIST_AUTH =  "C_GrfamiliesListAuth"
    case GR_CATEGORY_FAMILIES_LIST_NO_AUTH =  "C_GrfamiliesListNoAuth"
    case CATEGORY_SUPER =  "C_Super"
    case CATEGORY_MY_LISTS =  "C_MyLists"
    case CATEGORY_MY_LIST =  "C_MyList"
    case CATEGORY_WISHLIST_EMPTY =  "C_WishlistEmpty"
    case CATEGORY_WISHLIST =  "C_Wishlist"
    case CATEGORY_PRACTILISTA =  "C_Practilista"
    case CATEGORY_PRACTILISTA_AUTH =  "C_PractilistaAuth"
    case CATEGORY_PRACTILISTA_NO_AUTH =  "C_PractilistaNoAuth"
    case CATEGORY_PRE_SHOPPING_CART =  "C_PreShoppingCart"
    case MG_CATEGORY_EMPTY_SHOPPING_CART =  "C_MGEmptyShoppingCart"
    case GR_CATEGORY_EMPTY_SHOPPING_CART =  "C_GREmptyShoppingCart"
    case CATEGORY_SHOPPING_CART_SUPER =  "C_ShoppingCartSuper"
    case CATEGORY_SHOPPING_CART =  "C_ShoppingCart"
    case MG_CATEGORY_BEFORE_TO_GO =  "C_MgbeforeToGo"
    case GR_CATEGORY_SHOPPING_CART_AUTH =  "C_GrshoppingCartAuth"
    case GR_CATEGORY_SHOPPING_CART_NO_AUTH =  "C_GrshoppingCartNoAuth"
    case MG_CATEGORY_SHOPPING_CART_AUTH =  "C_MgshoppingCartAuth"
    case MG_CATEGORY_SHOPPING_CART_NO_AUTH =  "C_MgshoppingCartNoAuth"
    case CATEGORY_QUANTITY_KEYBOARD_AUTH =  "C_QuantityKeyboardAuth"
    case CATEGORY_QUANTITY_KEYBOARD_NO_AUTH =  "C_QuantityKeyboardNoAuth"
    case CATEGORY_KEYBOARD_WEIGHABLE =  "C_KeyboardWeighable"
    case GR_CATEGORY_SHOPPING_CART =  "C_GrshoppingCart"
    case CATEGORY_NOTE_IN_KEY_BOARD =  "C_NoteInKeyBoard"
    case CATEGORY_NOTIFICATION_AUTH =  "C_NotificationAuth"
    case CATEGORY_NOTIFICATION_NO_AUTH =  "C_NotificationNoAuth"
    case CATEGORY_GENERATE_BILLING_AUTH =  "C_GenerateBillingAuth"
    case CATEGORY_GENERATE_BILLING_NO_AUTH =  "C_GenerateBillingNoAuth"
    case CATEGORY_STORELOCATOR_AUTH =  "C_StorelocatorAuth"
    case CATEGORY_STORELOCATOR_NO_AUTH =  "C_StorelocatorNoAuth"
    case CATEGORY_SUPPORT_AUTH =  "C_SupportAuth"
    case CATEGORY_SUPPORT_NO_AUTH =  "C_SupportNoAuth"
    case CATEGORY_GENERATE_ORDER_AUTH =  "C_GenerateOrderAuth"
    case CATEGORY_GENERATE_ORDER_NO_AUTH =  "C_GenerateOrderNoAuth"
    case CATEGORY_KEYBOARD_GRAMS =  "C_KeyboardGrams"
    case CATEGORY_MORE_OPTIONS_AUTH =  "C_MoreOptionsAuth"
    case CATEGORY_MORE_OPTIONS_NO_AUTH =  "C_MoreOptionsNoAuth"
    case CATEGORY_LOGIN =  "C_Login"
    case CATEGORY_FORGOT_PASSWORD =  "C_ForgotPassword"
    case CATEGORY_CREATE_ACOUNT =  "C_CreateAcount"
    case CATEGORY_EDIT_PROFILE =  "C_EditProfile"
    case CATEGORY_LEGAL_INFORMATION =  "C_LegalInformation"
    case CATEGORY_CHANGE_PASSWORD =  "C_ChangePassword"
    case CATEGORY_MY_ADDRES =  "C_MyAddres"
    case CATEGORY_GR_NEW_ADDRESS =  "C_GrNewAddress"
    case CATEGORY_MG_NEW_ADDRESS =  "C_MgNewAddress"
    case CATEGORY_GR_EDIT_ADDRESS =  "C_GrEditAddress"
    case CATEGORY_MG_EDIT_ADDRESS =  "C_MgEditAddress"
    case CATEGORY_ADD_TO_SHOPPING_CART_ALERT =  "C_AddToShoppingCartAlert"
    case CATEGORY_TOP_PURCHASED =  "C_TopPurchased"
    case CATEGORY_PREVIOUS_ORDERS =  "C_PreviousOrders"
    case CATEGORY_TERMS_CONDITION_AUTH =  "C_TermsConditionAuth"
    case CATEGORY_TERMS_CONDITION_NO_AUTH  =  "C_TermsConditionNoAuth"
    case CATEGORY_LIST_STORELOCATOR_AUTH =  "C_ListStorelocatorAuth"
    case CATEGORY_LIST_STORELOCATOR_NO_AUTH =  "C_ListStorelocatorNoAuth"
    case CATEGORY_GENERATE_ORDER_OK =  "C_GenerateOrderOk"
    case CATEGORY_HOW_TO_USE_THE_APP =  "C_HowToUseTheApp"
    //ultimas
    case CATEGORY_STORELOCATORMAP_AUTH =  "C_CStorelocatormapauth"
    case CATEGORY_STORELOCATORMAP_NOAUTH =  "C_CStorelocatormapnoauth"
    case CATEGORY_TERMS_AND_CONDITIONS_AUTH =  "C_CategoryTermsAndConditionsAuth"
    case CATEGORY_TERMS_AND_CONDITIONS_NOAUTH =  "C_CategoryTermsAndConditionsNoauth"
    case CATEGORY_MGPREVIOUS_ORDERS_DETAIL =  "C_CategoryMgpreviousOrdersDetail"
    case CATEGORY_MG_BANNER_AUTH = "C_MGBannerAuth"
    case CATEGORY_GR_BANNER_AUTH = "C_GRBannerAuth"
    case CATEGORY_MG_BANNER_NO_AUTH = "C_MGBannerNoAuth"
    case CATEGORY_GR_BANNER_NO_AUTH = "C_GRBannerNoAuth"
    case CATEGORY_ZOOMPRODUCTDETAIL_NO_AUTH =  "C_ZoomProductDetailNoAuth"
    case CATEGORY_ZOOMPRODUCTDETAIL_AUTH =  "C_ZoomProductDetailAuth"
    case CATEGORY_ADD_TO_LIST = "C_AddToList"
    case CATEGORY_MY_LISTS_DETAIL_EMPTY = "C_MyListDetailEmpty"
    case CATEGORY_FREQUENT_QUESTIONS = "C_FrequentQuestions"
    case CATEGORY_SIGNUP = "C_SignUp"
    case CATEGORY_MG_PREVIOUS_ORDER_DETAILS = "C_MgPrevoiusOrderDetail"
    case CATEGORY_GR_PREVIOUS_ORDER_DETAILS = "C_GrPrevoiusOrderDetail"
    case CATEGORY_ADD_NEW_ADDRESS_AUTH = "C_AddNewAddressAuth"
    
    
    //MARK - ACTION
    case ACTION_OPEN_BARCODE_SCANNED_UPC =  "A_OpenBarcodeScannedUpc"
    case ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO =  "A_OpenSearchByTakingAPhoto"
    case ACTION_BARCODE_SCANNED_UPC =  "A_BarcodeScannedUpc"
    case ACTION_SEARCH_BY_TAKING_A_PHOTO =  "A_SearchByTakingAPhoto"
    case ACTION_CANCEL_SEARCH =  "A_CancelSearch"
    case ACTION_BACK_SEARCH_PRODUCT =  "A_BackSearchProduct"
    case ACTION_APPLY_FILTER =  "A_ApplyFilter"
    case ACTION_SORT_BY_A_Z =  "A_SortByAZ"
    case ACTION_SORT_BY_Z_A =  "A_SortByZA"
    case ACTION_SORT_BY_$_$$$ =  "A_SortBy$_$$$"
    case ACTION_SORT_BY_$$$_$ =  "A_SortBy$$$_$"
    case ACTION_BY_POPULARITY =  "A_ByPopularity"
    case ACTION_OPEN_CATEGORY_DEPARMENT =  "A_OpenCategoryDeparment"
    case ACTION_OPEN_CATEGORY =  "A_OpenCategory"
    case ACTION_OPEN_CATEGORY_FAMILY =  "A_OpenCategoryFamily"
    case ACTION_OPEN_CATEGORY_LINE =  "A_OpenCategoryLine"
    case ACTION_SLIDER_PRICE_RANGE_SELECT =  "A_SliderPriceRangeSelect"
    case ACTION_BRAND_SELECTION =  "A_BrandSelection"
    case ACTION_SHOW_FAMILIES =  "A_ShowFamilies"
    case ACTION_OPEN_ACCESSORY_LINES =  "A_OpenAccessoryLines"
    case ACTION_OPEN_LINES =  "A_OpenLines"
    case ACTION_SELECTED_LINE =  "A_SelectedLine"
    case ACTION_HIDE_HIGHLIGHTS =  "A_HideHighlights"
    case ACTION_VIEW_RECOMMENDED =  "A_ViewRecommended"
    case ACTION_NEW_LIST =  "A_NewList"
    case ACTION_EDIT_LIST =  "A_EditList"
    case ACTION_TAPPED_VIEW_DETAILS_WISHLIST =  "A_TappedViewDetailsWishlist"
    case ACTION_TAPPED_VIEW_DETAILS_SUPERLIST =  "A_TappedViewDetailsSuperlist"
    case ACTION_TAPPED_VIEW_DETAILS_MYLIST =  "A_TappedViewDetailsMylist"
    case ACTION_BACK_WISHLIST =  "A_BackWishlist"
    case ACTION_EDIT_WISHLIST =  "A_BackEditWishlist"
    case ACTION_OPEN_DETAIL_WISHLIST =  "A_OpenDetailWishlist"
    case ACTION_DELETE_PRODUCT_WISHLIST =  "A_DeleteProductWishlist"
    case ACTION_DELETE_ALL_PRODUCTS_WISHLIST =  "A_DeleteAllProductsWishlist"
    case ACTION_DELETE_PRODUCT_MYLIST =  "A_DeleteProductMylist"
    case ACTION_DELETE_PRODUCT_CART =  "A_DeleteProductCart"
    case ACTION_DELETE_ALL_PRODUCTS_CART =  "A_DeleteAllProductsCart"
    case ACTION_DELETE_ALL_PRODUCTS_MYLIST =  "A_DeleteAllProductsMylist"
    case ACTION_CHECKOUT =  "A_Checkout"
    case ACTION_OPEN_PRACTILISTA =  "A_OpenPractilista"
    case ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA =  "A_OpenProductDetailPractilista"
    case ACTION_ADD_ALL_TO_SHOPPING_CART =  "A_AddAllToShoppingCart"
    case ACTION_DUPLICATE_LIST =  "A_DuplicateList"
    case ACTION_CANCEL_NEW_LIST =  "A_CancelNewList"
    case ACTION_CREATE_NEW_LIST =  "A_CreateNewList"
    case ACTION_CANCEL_ADD_TO_LIST =  "A_CancelAddToList"
    case ACTION_EMPTY_LIST =  "A_EmptyList"
    case ACTION_EDIT_MY_LIST =  "A_EditMyList"
    case ACTION_BACK_MY_LIST =  "A_BackMyList"
    case ACTION_OPEN_PRODUCT_DETAIL =  "A_OpenProductDetail"
    case ACTION_DISABLE_PRODUCT =  "A_DisableProduct"
    case ACTION_ENABLE_PRODUCT =  "A_EnableProduct"
    case ACTION_GR_OPEN_CATEGORY =  "A_GrOpenCategory"
    case ACTION_MG_OPEN_CATEGORY =  "A_MgOpenCategory"
    case ACTION_GR_OPEN_SHOPPING_CART =  "A_GrOpenShoppingCart"
    case ACTION_MG_OPEN_SHOPPING_CART =  "A_MgOpenShoppingCart"
    case ACTION_CLOSED =  "A_Closed"
    case ACTION_ERASE_QUANTITY =  "A_EraseQuantity"
    case ACTION_OPEN_SHOPPING_CART_SUPER =  "A_OpenShoppingCartSuper"
    case ACTION_OPEN_SHOPPING_CART_MG =  "A_OpenShoppingCartMg"
    case ACTION_ADD_NOTE =  "A_AddNote"
    case ACTION_ADD_NOTE_FOR_SEND =  "A_AddNoteForSend"
    case ACTION_CART_CLOSED =  "A_CartClosed"
    case ACTION_EDIT_CART =  "A_EditCart"
    case ACTION_BACK_TO_PRE_SHOPPING_CART =  "A_BackToPreShoppingCart"
    case ACTION_BACK_TO_SHOPPING_CART =  "A_BackToShoppingCart"
    case ACTION_QUANTITY_KEYBOARD =  "A_QuantityKeyboard"
    case ACTION_CHANGE_NUMER_OF_PIECES =  "A_ChangeNumerOfPieces"
    case ACTION_ADD_TO_SHOPPING_CART =  "A_AddToShoppingCart"
    case ACTION_OPEN_LOGIN_PRE_CHECKOUT =  "A_OpenLoginPreCheckout"
    case ACTION_OPEN_LOGIN =  "A_OpenLogin"
    case ACTION_ADD_ALL_WISHLIST =  "A_AddAllWishlist"
    case ACTION_CHANGE_NUMER_OF_KG =  "A_ChangeNumerOfKg"
    case ACTION_ADD_MY_LIST =  "A_AddMyList"
    case ACTION_OK =  "A_Ok"
    case ACTION_REMOVE_ALL =  "A_RemoveAll"
    case ACTION_BACK_PRE_SHOPPING_CART =  "A_BackPreShoppingCart"
    case ACTION_REMOVE =  "A_Remove"
    case ACTION_ADD_GRAMS =  "A_AddGrams"
    case ACTION_DECREASE_GRAMS =  "A_DecreaseGrams"
    case ACTION_TAPPED_100_GR =  "A_Tapped100Gr"
    case ACTION_TAPPED_250_GR =  "A_Tapped250Gr"
    case ACTION_TAPPED_500_GR =  "A_Tapped500Gr"
    case ACTION_TAPPED_750_GR =  "A_Tapped750Gr"
    case ACTION_TAPPED_1_KG =  "A_Tapped1Kg"
    case ACTION_UPDATE_SHOPPING_CART =  "A_UpdateShoppingCart"
    case ACTION_UPDATE_LIST =  "A_UpdateList"
    case ACTION_OPEN_KEYBOARD_KILO =  "A_OpenKeyboardKilo"
    case ACTION_BACK_KEYBOARG_GRAMS =  "A_BackKeyboargGrams"
    case ACTION_OPEN_NOTE =  "A_OpenNote"
    case ACTION_CLOSE_NOTE =  "A_CloseNote"
    case ACTION_BACK_TO_MORE_OPTIONS =  "A_BackToMoreOptions"
    case ACTION_BACK_TO_EDIT_PROFILE =  "A_BackToEditProfile"
    case ACTION_OPEN_DETAIL_NOTIFICATION =  "A_OpenDetailNotification"
    case ACTION_CLOSE_GERATE_BILLIG =  "A_CloseGerateBillig"
    case ACTION_BACK_TO_MAP =  "A_BackToMap"
    case ACTION_LIST_SHARE_STORE =  "A_ListShareStore"
    case ACTION_LIST_CALL_STORE =  "A_ListCallStore"
    case ACTION_LIST_DIRECTIONS =  "A_ListDirections"
    case ACTION_LIST_SHOW_ON_MAP =  "A_ListShowOnMap"
    case ACTION_MY_LISTS_DETAIL_EMPTY =  "A_MyListsDetailEmpty"
    case ACTION_MAP_SHARE_STORE =  "A_MapShareStore"
    case ACTION_MAP_CALL_STORE =  "A_MapCallStore"
    case ACTION_MAP_DIRECTIONS =  "A_MapDirections"
    case ACTION_MAP_ROUTE_STORE =  "A_MapRouteStore"
    case ACTION_STOREDETAIL =  "A_Storedetail"
    case ACTION_USER_CURRENT_LOCATION =  "A_UserCurrentLocation"
    case ACTION_MAP_TYPE =  "A_MapType"
    case ACTION_CALL_SUPPORT =  "A_CallSupport"
    case ACTION_EMAIL_SUPPORT =  "A_EmailSupport"
    case ACTION_SHIPPING_OPTIONS =  "A_ShippingOptions"
    case ACTION_PAYMENTOPTIONS =  "A_Paymentoptions"
    case ACTION_TYPE_DELIVERY =  "A_TypeDelivery"
    case ACTION_CHANGE_ADDRES_DELIVERY =  "A_ChangeAddresDelivery"
    case ACTION_CHANGE_DELIVERY_TYPE =  "A_ChangeDeliveryType"
    case ACTION_CHANGE_TIME_DELIVERY =  "A_ChangeTimeDelivery"
    case ACTION_DATE_CHANGE =  "A_DateChange"
    case ACTION_TIME_DELIVERY =  "A_TimeDelivery"
    case ACTION_FINIHS_ORDER =  "A_FinishOrder"
    case ACTION_OPEN_CONFIRMATION =  "A_OpenConfirmation"
    case ACTION_DISCOUT_ASOCIATE =  "A_DiscoutAsociate"
    case ACTION_BUY_GR =  "A_BuyGr"
    case ACTION_BUY_MG =  "A_BuyMg"
    case ACTION_CLOSE_SESSION =  "A_CloseSession"
    case ACTION_OPEN_ACCOUNT_ADDRES =  "A_OpenAccountAddres"
    case ACTION_OPEN_MORE_ITEMES_PURCHASED =  "A_OpenMoreItemesPurchased"
    case ACTION_OPEN_PREVIOUS_ORDERS =  "A_OpenPreviousOrders"
    case ACTION_OPEN_SCANNED_TICKET =  "A_OpenScannedTicket"
    case ACTION_OPEN_STORE_LOCATOR =  "A_OpenStoreLocator"
    case ACTION_OPEN_ELECTRONIC_BILLING =  "A_OpenElectronicBilling"
    case ACTION_OPEN_NOTIFICATIONS =  "A_OpenNotifications"
    case ACTION_OPEN_HOW_USE_APP =  "A_OpenHowUseApp"
    case ACTION_OPEN_SUPPORT =  "A_OpenSupport"
    case ACTION_OPEN_HELP =  "A_OpenHelp"
    case ACTION_OPEN_TERMS_AND_CONDITIONS =  "A_OpenTermsAndConditions"
    case ACTION_ENABLE_PROMO =  "A_EnablePromo"
    case ACTION_DISBALE_PROMO =  "A_DisbalePromo"
    case ACTION_LEGAL_ACEPT =  "A_LegalAcept"
    case ACTION_LEGAL_NO_ACEPT =  "A_LegalNoAcept"
    case ACTION_CONTINUE_BUYING =  "A_ContinueBuying"
    case ACTION_OPEN_TUTORIAL =  "A_OpenTutorial"
    case ACTION_OPEN_QUESTIONS =  "A_OpenQuestions"
    case ACTION_OPEN_RATE_APP =  "A_OpenRateApp"
    case ACTION_CLOSE_TUTORIAL =  "A_CloseTutorial"
    case ACTION_CLOSE_END_TUTORIAL =  "A_CloseEndTutorial"
    case ACTION_VIEW_BANNER_PRODUCT =  "A_ViewBannerProduct"
    case ACTION_VIEW_BANNER_CATEGORY =  "A_ViewBannerCategory"
    case ACTION_VIEW_BANNER_LINE =  "A_ViewBannerLine"
    case ACTION_VIEW_BANNER_SEARCH_TEXT =  "A_ViewBannerSearchText"
    case ACTION_VIEW_BANNER_TERMS =  "A_ViewBannerTerms"
    case ACTION_OPEN_PRE_SHOPPING_CART =  "A_OpenPreShoppingCart"
    case ACTION_GO_TO_HOME =  "A_GoToHome"
    case ACTION_OPEN_SEARCH_OPTIONS =  "A_OpenSearchOptions"
    case ACTION_CHANGE_ITEM =  "A_ChangeItem"
    case ACTION_VIEW_SPECIAL_DETAILS =  "A_ViewSpecialDetails"
    case ACTION_OPEN_HOME =  "A_OpenHome"
    case ACTION_OPEN_MG =  "A_OpenMg"
    case ACTION_OPEN_GR =  "A_OpenGr"
    case ACTION_OPEN_LIST =  "A_OpenList"
    case ACTION_OPEN_MORE_OPTION =  "A_OpenMoreOption"
    case ACTION_BACK =  "A_Back"
    case ACTION_PRODUCT_DETAIL_IMAGE_TAPPED =  "A_ProductDetailImageTapped"
    case ACTION_INFORMATION =  "A_Information"
    case ACTION_ADD_TO_LIST =  "A_AddToList"
    case ACTION_ADD_WISHLIST =  "A_AddWishlist"
    case ACTION_DELETE_WISHLIST =  "A_DeleteWishlist"
    case ACTION_SHARE =  "A_Share"
    case ACTION_OPEN_KEYBOARD =  "A_OpenKeyboard"
    case ACTION_CLOSE_KEYBOARD =  "A_CloseKeyboard"
    case ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED =  "A_BundleProductDetailTapped"
    case ACTION_CANCEL =  "A_Cancel"
    case ACTION_TEXT_SEARCH =  "A_TextSearch"
    case ACTION_SHOW_ORDER_DETAIL =  "A_ShowOrderDetail"
    case ACTION_SHOW_LIST_STORE_LOCATOR =  "A_ShowListStoreLocator"
    case ACTION_SHOW_MAP_STORE_LOCATOR =  "A_ShowMapStoreLocator"
    case ACTION_RECOVER_PASSWORD =  "A_RecoverPassword"
    case ACTION_LOGIN_USER =  "A_LoginUser"
    case ACTION_OPEN_CREATE_ACOUNT =  "A_OpenCreateAcount"
    case ACTION_OPEN_EDIT_PROFILE  =  "A_OpenEditProfile"
    case ACTION_SAVE  =  "A_Save"
    case ACTION_OPEN_LEGAL_INFORMATION  =  "A_OpenLegalInformation"
    case ACTION_OPEN_FORM_CHANGE_PASSWORD =  "A_OpenFormChangePassword"
    case ACTION_OPEN_GR_NEW_ADDRES =  "A_OpenGrNewAddres"
    case ACTION_OPEN_MG_NEW_ADDRES =  "A_OpenMgNewAddres"
    case ACTION_GR_SHOW_ADDREES_DETAIL =  "A_GrShowAddreesDetail"
    case ACTION_MG_DELIVERY_SHOW_ADDREES_DETAIL =  "A_MgDeliveryShowAddreesDetail"
    case ACTION_MG_BILL_SHOW_ADDREES_DETAIL =  "A_MgBillShowAddreesDetail"
    case ACTION_GR_SET_ADDRESS_PREFERRED =  "A_GrSetAddressPreferred"
    case ACTION_MG_SET_ADDRESS_PREFERRED =  "A_MgSetAddressPreferred"
    case ACTION_MG_DELETE_ADDRESS =  "A_MgDeleteAddress"
    case ACTION_GR_DELETE_ADDRESS =  "A_GrDeleteAddress"
    case ACTION_GR_SAVE_ADDRESS =  "A_GrSaveAddress"
    case ACTION_MG_SAVE_ADDRESS =  "A_MgSaveAddress"
    case ACTION_GR_UPDATE_ADDRESS =  "A_GrUpdateAddress"
    case ACTION_MG_UPDATE_ADDRESS =  "A_MgUpdateAddress"
    case ACTION_SHOW_STORE_LOCATOR_IN_MAP =  "A_ShowStoreLocatorInMap"
    //ultimas
    case ACTION_LOCATOR_CALL_STORE = "A_LocatorCallStore"
    case ACTION_LOCATOR_ROUTE_STORE = "A_LocatorRouteStore"
    case ACTION_LOCATOR_SHARE_STORE = "A_LocatorShareStore"
    case ACTION_OPEN_ADD_TO_LIST =  "A_OpenAddToList"
    case ACTION_SHOW_PRODUCT_DETAIL =  "A_ShowProductDetail"
    case ACTION_BACK_TO_PREVIOUS_ORDER =  "A_BackToPreviousOrder"
    case ACTION_BACKSUPPORT = "A_Backsupport"
    case ACTION_SHOWLIST_STORELOCATOR =  "A_ShowlistStorelocator"
    case ACTION_BACK_STORELOCATOR =  "A_BackStoreLocator"
    case ACTION_DIPONIBILIDAD_DE_PRODUCTO = "A_DisponibilidaddeProductos"
    case ACTION_APAGOSEGURO =  "A_PagoSeguro"
    case ACTION_PILITICAS_DE_DEVOLUCION_Y_CANCELACION_DEPEDIDOS =  "A_Politicasdedevolucionycancelaciondepedidos"
    case ACTION_TIEMPO_DE_ENTREGA =  "A_TiempodeEntrega"
    case ACTION_TERMS_CONDITION_AUTH = "A_Términosycondiciones"
    case ACTION_AVISO_DE_PRIVACIDAD  = " A_AvisodePrivacidad"
    case ACTION_APP_SESSION_END = "A_CerrarSesión"
    case ACTION_RELATED_PRODUCT  = " A_RelatedProduct"
    case ACTION_CHANGE_PASSWORD =  "A_ChangePassword"
    case ACTION_BACK_PRODUCTDETAIL =  "A_BackProductDetail"
    case ACTION_ZOMMIMAGE_PRODUCTDETAIL =  "A_ZoomImageProductDetail"
    case ACTION_BARCODE_SCANNED_TICKET =  "A_BarcodeScannedTicket"
    case ACTION_OPEN_REFERED = "A_OpenRefered"
    case ACTION_SAVE_SIGNUP = "A_SaveSignUp"
    case ACTION_CHANGE_DATE = "A_ChangeDate"
    case ACTION_SAVE_NEW_ADDRESS  =  "A_SaveNewAddress"
    
    
    case ACTION_RATING_I_LIKE_APP =  "A_RatingILikeApp"
    case ACTION_RATING_I_DONT_LIKE_APP =  "A_RatingIDontLikeApp"
    
    case ACTION_RATING_OPEN_APP_STORE =  "A_RatingOpenAppStore"
    case ACTION_RATING_MAYBE_LATER =  "A_RatingMaybeLater"
    case ACTION_RATING_NO_THANKS =  "A_RatingNothanks"
    case ACTION_PUSH_NOTIFICATION_OPEN = "A_Push_Notification_Open"
    
}

