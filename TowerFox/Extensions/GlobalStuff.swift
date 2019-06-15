//
//  GlobalStuff.swift
//  PBSG
//
//  Created by cgc on 5/8/18.
//  Copyright © 2018 rockdevat. All rights reserved.
//

import UIKit
let SERVICE_PROTOCOL = "https://";
let SERVICES_PATH = "/api12/CMPv2Services";


func log(_ functionName: String = #function, line: Int = #line, file: String = #file, message: String = "") {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    print("---\(dateFormatter.string(from: Date())) l#:\(line) \(functionName) in \((file as NSString).lastPathComponent) " + message)
}
let videos = [URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!,
              URL(string: "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8")!,
              URL(string: "http://www.streambox.fr/playlists/test_001/stream.m3u8")!,
              URL(string: "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8")!,
              URL(string: "http://yt-dash-mse-test.commondatastorage.googleapis.com/media/car-20120827-85.mp4")!,
              URL(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!,
              URL(string: "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")!,
              URL(string: "http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")!,
              URL(string: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8")!,
              URL(string: "http://mirrors.standaloneinstaller.com/video-sample/jellyfish-25-mbps-hd-hevc.mp4")!]

let createCustomTokenURL = "https://us-central1-randevu-147aa.cloudfunctions.net/createAccount"
let getCharityDetailUrl = "https://apidata.guidestar.org/premier/v1/"
let getCharitySubscriptionKey = "f984abb343d74f4badd6ed077783d9ea"
let searchSubscriptionKey = "4822b2ec54e54f83a750738c89658749"
let searchCharityUrl = "https://apidata.guidestar.org/essentials/v1"
let kBgQ = DispatchQueue.global(qos: .background)
let kMainQueue = DispatchQueue.main
// Threads.
let FANames = ["FAGlass", "FAMusic", "FASearch", "FAEnvelopeO", "FAHeart", "FAStar", "FAStarO", "FAUser", "FAFilm", "FAThLarge", "FATh", "FAThList", "FACheck", "FATimes", "FARemove", "FAClose", "FASearchPlus", "FASearchMinus", "FAPowerOff", "FASignal", "FACog", "FAGear", "FATrashO", "FAHome", "FAFileO", "FAClockO", "FARoad", "FADownload", "FAArrowCircleODown", "FAArrowCircleOUp", "FAInbox", "FAPlayCircleO", "FARepeat", "FARotateRight", "FARefresh", "FAListAlt", "FALock", "FAFlag", "FAHeadphones", "FAVolumeOff", "FAVolumeDown", "FAVolumeUp", "FAQrcode", "FABarcode", "FATag", "FATags", "FABook", "FABookmark", "FAPrint", "FACamera", "FAFont", "FABold", "FAItalic", "FATextHeight", "FATextWidth", "FAAlignLeft", "FAAlignCenter", "FAAlignRight", "FAAlignJustify", "FAList", "FAOutdent", "FADedent", "FAIndent", "FAVideoCamera", "FAPictureO", "FAPhoto", "FAImage", "FAPencil", "FAMapMarker", "FAAdjust", "FATint", "FAPencilSquareO", "FAEdit", "FAShareSquareO", "FACheckSquareO", "FAArrows", "FAStepBackward", "FAFastBackward", "FABackward", "FAPlay", "FAPause", "FAStop", "FAForward", "FAFastForward", "FAStepForward", "FAEject", "FAChevronLeft", "FAChevronRight", "FAPlusCircle", "FAMinusCircle", "FATimesCircle", "FACheckCircle", "FAQuestionCircle", "FAInfoCircle", "FACrosshairs", "FATimesCircleO", "FACheckCircleO", "FABan", "FAArrowLeft", "FAArrowRight", "FAArrowUp", "FAArrowDown", "FAShare", "FAMailForward", "FAExpand", "FACompress", "FAPlus", "FAMinus", "FAAsterisk", "FAExclamationCircle", "FAGift", "FALeaf", "FAFire", "FAEye", "FAEyeSlash", "FAExclamationTriangle", "FAWarning", "FAPlane", "FACalendar", "FARandom", "FAComment", "FAMagnet", "FAChevronUp", "FAChevronDown", "FARetweet", "FAShoppingCart", "FAFolder", "FAFolderOpen", "FAArrowsV", "FAArrowsH", "FABarChart", "FABarChartO", "FATwitterSquare", "FAFacebookSquare", "FACameraRetro", "FAKey", "FACogs", "FAGears", "FAComments", "FAThumbsOUp", "FAThumbsODown", "FAStarHalf", "FAHeartO", "FASignOut", "FALinkedinSquare", "FAThumbTack", "FAExternalLink", "FASignIn", "FATrophy", "FAGithubSquare", "FAUpload", "FALemonO", "FAPhone", "FASquareO", "FABookmarkO", "FAPhoneSquare", "FATwitter", "FAFacebook", "FAFacebookF", "FAGithub", "FAUnlock", "FACreditCard", "FARss", "FAFeed", "FAHddO", "FABullhorn", "FABell", "FACertificate", "FAHandORight", "FAHandOLeft", "FAHandOUp", "FAHandODown", "FAArrowCircleLeft", "FAArrowCircleRight", "FAArrowCircleUp", "FAArrowCircleDown", "FAGlobe", "FAWrench", "FATasks", "FAFilter", "FABriefcase", "FAArrowsAlt", "FAUsers", "FAGroup", "FALink", "FAChain", "FACloud", "FAFlask", "FAScissors", "FACut", "FAFilesO", "FACopy", "FAPaperclip", "FAFloppyO", "FASave", "FASquare", "FABars", "FANavicon", "FAReorder", "FAListUl", "FAListOl", "FAStrikethrough", "FAUnderline", "FATable", "FAMagic", "FATruck", "FAPinterest", "FAPinterestSquare", "FAGooglePlusSquare", "FAGooglePlus", "FAMoney", "FACaretDown", "FACaretUp", "FACaretLeft", "FACaretRight", "FAColumns", "FASort", "FAUnsorted", "FASortDesc", "FASortDown", "FASortAsc", "FASortUp", "FAEnvelope", "FALinkedin", "FAUndo", "FARotateLeft", "FAGavel", "FALegal", "FATachometer", "FADashboard", "FACommentO", "FACommentsO", "FABolt", "FAFlash", "FASitemap", "FAUmbrella", "FAClipboard", "FAPaste", "FALightbulbO", "FAExchange", "FACloudDownload", "FACloudUpload", "FAUserMd", "FAStethoscope", "FASuitcase", "FABellO", "FACoffee", "FACutlery", "FAFileTextO", "FABuildingO", "FAHospitalO", "FAAmbulance", "FAMedkit", "FAFighterJet", "FABeer", "FAHSquare", "FAPlusSquare", "FAAngleDoubleLeft", "FAAngleDoubleRight", "FAAngleDoubleUp", "FAAngleDoubleDown", "FAAngleLeft", "FAAngleRight", "FAAngleUp", "FAAngleDown", "FADesktop", "FALaptop", "FATablet", "FAMobile", "FAMobilePhone", "FACircleO", "FAQuoteLeft", "FAQuoteRight", "FASpinner", "FACircle", "FAReply", "FAMailReply", "FAGithubAlt", "FAFolderO", "FAFolderOpenO", "FASmileO", "FAFrownO", "FAMehO", "FAGamepad", "FAKeyboardO", "FAFlagO", "FAFlagCheckered", "FATerminal", "FACode", "FAReplyAll", "FAMailReplyAll", "FAStarHalfO", "FAStarHalfEmpty", "FAStarHalfFull", "FALocationArrow", "FACrop", "FACodeFork", "FAChainBroken", "FAUnlink", "FAQuestion", "FAInfo", "FAExclamation", "FASuperscript", "FASubscript", "FAEraser", "FAPuzzlePiece", "FAMicrophone", "FAMicrophoneSlash", "FAShield", "FACalendarO", "FAFireExtinguisher", "FARocket", "FAMaxcdn", "FAChevronCircleLeft", "FAChevronCircleRight", "FAChevronCircleUp", "FAChevronCircleDown", "FAHtml5", "FACss3", "FAAnchor", "FAUnlockAlt", "FABullseye", "FAEllipsisH", "FAEllipsisV", "FARssSquare", "FAPlayCircle", "FATicket", "FAMinusSquare", "FAMinusSquareO", "FALevelUp", "FALevelDown", "FACheckSquare", "FAPencilSquare", "FAExternalLinkSquare", "FAShareSquare", "FACompass", "FACaretSquareODown", "FAToggleDown", "FACaretSquareOUp", "FAToggleUp", "FACaretSquareORight", "FAToggleRight", "FAEur", "FAEuro", "FAGbp", "FAUsd", "FADollar", "FAInr", "FARupee", "FAJpy", "FACny", "FARmb", "FAYen", "FARub", "FARuble", "FARouble", "FAKrw", "FAWon", "FABtc", "FABitcoin", "FAFile", "FAFileText", "FASortAlphaAsc", "FASortAlphaDesc", "FASortAmountAsc", "FASortAmountDesc", "FASortNumericAsc", "FASortNumericDesc", "FAThumbsUp", "FAThumbsDown", "FAYoutubeSquare", "FAYoutube", "FAXing", "FAXingSquare", "FAYoutubePlay", "FADropbox", "FAStackOverflow", "FAInstagram", "FAFlickr", "FAAdn", "FABitbucket", "FABitbucketSquare", "FATumblr", "FATumblrSquare", "FALongArrowDown", "FALongArrowUp", "FALongArrowLeft", "FALongArrowRight", "FAApple", "FAWindows", "FAAndroid", "FALinux", "FADribbble", "FASkype", "FAFoursquare", "FATrello", "FAFemale", "FAMale", "FAGratipay", "FAGittip", "FASunO", "FAMoonO", "FAArchive", "FABug", "FAVk", "FAWeibo", "FARenren", "FAPagelines", "FAStackExchange", "FAArrowCircleORight", "FAArrowCircleOLeft", "FACaretSquareOLeft", "FAToggleLeft", "FADotCircleO", "FAWheelchair", "FAVimeoSquare", "FATry", "FATurkishLira", "FAPlusSquareO", "FASpaceShuttle", "FASlack", "FAEnvelopeSquare", "FAWordpress", "FAOpenid", "FAUniversity", "FAInstitution", "FABank", "FAGraduationCap", "FAMortarBoard", "FAYahoo", "FAGoogle", "FAReddit", "FARedditSquare", "FAStumbleuponCircle", "FAStumbleupon", "FADelicious", "FADigg", "FAPiedPiperPp", "FAPiedPiperAlt", "FADrupal", "FAJoomla", "FALanguage", "FAFax", "FABuilding", "FAChild", "FAPaw", "FASpoon", "FACube", "FACubes", "FABehance", "FABehanceSquare", "FASteam", "FASteamSquare", "FARecycle", "FACar", "FAAutomobile", "FATaxi", "FACab", "FATree", "FASpotify", "FADeviantart", "FASoundcloud", "FADatabase", "FAFilePdfO", "FAFileWordO", "FAFileExcelO", "FAFilePowerpointO", "FAFileImageO", "FAFilePhotoO", "FAFilePictureO", "FAFileArchiveO", "FAFileZipO", "FAFileAudioO", "FAFileSoundO", "FAFileVideoO", "FAFileMovieO", "FAFileCodeO", "FAVine", "FACodepen", "FAJsfiddle", "FALifeRing", "FALifeBouy", "FALifeBuoy", "FALifeSaver", "FASupport", "FACircleONotch", "FARebel", "FARa", "FAResistance", "FAEmpire", "FAGe", "FAGitSquare", "FAGit", "FAHackerNews", "FAYCombinatorSquare", "FAYcSquare", "FATencentWeibo", "FAQq", "FAWeixin", "FAWechat", "FAPaperPlane", "FASend", "FAPaperPlaneO", "FASendO", "FAHistory", "FACircleThin", "FAHeader", "FAParagraph", "FASliders", "FAShareAlt", "FAShareAltSquare", "FABomb", "FAFutbolO", "FASoccerBallO", "FATty", "FABinoculars", "FAPlug", "FASlideshare", "FATwitch", "FAYelp", "FANewspaperO", "FAWifi", "FACalculator", "FAPaypal", "FAGoogleWallet", "FACcVisa", "FACcMastercard", "FACcDiscover", "FACcAmex", "FACcPaypal", "FACcStripe", "FABellSlash", "FABellSlashO", "FATrash", "FACopyright", "FAAt", "FAEyedropper", "FAPaintBrush", "FABirthdayCake", "FAAreaChart", "FAPieChart", "FALineChart", "FALastfm", "FALastfmSquare", "FAToggleOff", "FAToggleOn", "FABicycle", "FABus", "FAIoxhost", "FAAngellist", "FACc", "FAIls", "FAShekel", "FASheqel", "FAMeanpath", "FABuysellads", "FAConnectdevelop", "FADashcube", "FAForumbee", "FALeanpub", "FASellsy", "FAShirtsinbulk", "FASimplybuilt", "FASkyatlas", "FACartPlus", "FACartArrowDown", "FADiamond", "FAShip", "FAUserSecret", "FAMotorcycle", "FAStreetView", "FAHeartbeat", "FAVenus", "FAMars", "FAMercury", "FATransgender", "FAIntersex", "FATransgenderAlt", "FAVenusDouble", "FAMarsDouble", "FAVenusMars", "FAMarsStroke", "FAMarsStrokeV", "FAMarsStrokeH", "FANeuter", "FAGenderless", "FAFacebookOfficial", "FAPinterestP", "FAWhatsapp", "FAServer", "FAUserPlus", "FAUserTimes", "FABed", "FAHotel", "FAViacoin", "FATrain", "FASubway", "FAMedium", "FAYCombinator", "FAYc", "FAOptinMonster", "FAOpencart", "FAExpeditedssl", "FABatteryFull", "FABattery4", "FABatteryThreeQuarters", "FABattery3", "FABatteryHalf", "FABattery2", "FABatteryQuarter", "FABattery1", "FABatteryEmpty", "FABattery0", "FAMousePointer", "FAICursor", "FAObjectGroup", "FAObjectUngroup", "FAStickyNote", "FAStickyNoteO", "FACcJcb", "FACcDinersClub", "FAClone", "FABalanceScale", "FAHourglassO", "FAHourglassStart", "FAHourglass1", "FAHourglassHalf", "FAHourglass2", "FAHourglassEnd", "FAHourglass3", "FAHourglass", "FAHandRockO", "FAHandGrabO", "FAHandPaperO", "FAHandStopO", "FAHandScissorsO", "FAHandLizardO", "FAHandSpockO", "FAHandPointerO", "FAHandPeaceO", "FATrademark", "FARegistered", "FACreativeCommons", "FAGg", "FAGgCircle", "FATripadvisor", "FAOdnoklassniki", "FAOdnoklassnikiSquare", "FAGetPocket", "FAWikipediaW", "FASafari", "FAChrome", "FAFirefox", "FAOpera", "FAInternetExplorer", "FATelevision", "FATv", "FAContao", "FA500px", "FAAmazon", "FACalendarPlusO", "FACalendarMinusO", "FACalendarTimesO", "FACalendarCheckO", "FAIndustry", "FAMapPin", "FAMapSigns", "FAMapO", "FAMap", "FACommenting", "FACommentingO", "FAHouzz", "FAVimeo", "FABlackTie", "FAFonticons", "FARedditAlien", "FAEdge", "FACreditCardAlt", "FACodiepie", "FAModx", "FAFortAwesome", "FAUsb", "FAProductHunt", "FAMixcloud", "FAScribd", "FAPauseCircle", "FAPauseCircleO", "FAStopCircle", "FAStopCircleO", "FAShoppingBag", "FAShoppingBasket", "FAHashtag", "FABluetooth", "FABluetoothB", "FAPercent", "FAGitlab", "FAWpbeginner", "FAWpforms", "FAEnvira", "FAUniversalAccess", "FAWheelchairAlt", "FAQuestionCircleO", "FABlind", "FAAudioDescription", "FAVolumeControlPhone", "FABraille", "FAAssistiveListeningSystems", "FAAmericanSignLanguageInterpreting", "FAAslInterpreting", "FADeaf", "FADeafness", "FAHardOfHearing", "FAGlide", "FAGlideG", "FASignLanguage", "FASigning", "FALowVision", "FAViadeo", "FAViadeoSquare", "FASnapchat", "FASnapchatGhost", "FASnapchatSquare", "FAPiedPiper", "FAFirstOrder", "FAYoast", "FAThemeisle", "FAGooglePlusOfficial", "FAGooglePlusCircle", "FAFontAwesome", "FAFa", "FAAddressBook", "FAAddressBookO", "FAAdressCard", "FAAdressCardO", "FABandcamp", "FABath", "FABathtub", "FADriversLicense", "FADriversLicenseO", "FAEerCast", "FAEnvelopeOpen", "FAEnvelopeOpenO", "FAEtsy", "FAFreeCodeCamp", "FAGrav", "FAHandshakeO", "FAIdBadge", "FAIdCard", "FAIdCardO", "FAImdb", "FALinode", "FAMeetup", "FAMicrochip", "FAPodcast", "FAQuora", "FARavelry", "FAS15", "FAShower", "FASnowflakeO", "FASuperpowers", "FATelegram", "FAThermometer", "FAThermometer0", "FAThermometer1", "FAThermometer2", "FAThermometer3", "FAThermometer4", "FAThermometerEmpty", "FAThermometerFull", "FAThermometerHalf", "FAThermometerQuarter", "FAThermometerThreeQuarters", "FATimesRectangle", "FATimesRectangleO", "FAUserCircle", "FAUserCircleO", "FAUserO", "FAVcard", "FAVcardO", "FAWindowClose", "FAWindowCloseO", "FAWindowMaximize", "FAWindowMinimize", "FAWindowRestore", "FAWPExplorer"]
let charityList: [String] = ["Unicef", "PETA", "March of dimes", "Toys for tots", "Red Cross", "American cancer society", "Make a wish foundation", "American heart association", "Amnesty international", "Environmental defense fund"]
let charityLogos: [UIImage] = [#imageLiteral(resourceName: "unicef_logo"), #imageLiteral(resourceName: "peta_logo"), #imageLiteral(resourceName: "mod_logo"), #imageLiteral(resourceName: "toys_logo"), #imageLiteral(resourceName: "arc_logo"), #imageLiteral(resourceName: "acs_logo"), #imageLiteral(resourceName: "mawi_logo"), #imageLiteral(resourceName: "aha_logo"), #imageLiteral(resourceName: "eng_logo"), #imageLiteral(resourceName: "edf_logo")]
let costList: [Int] = [20, 50, 100, 0]
enum SelectionState {
    case teamContest
    case usual
    case editSelections
}

enum TypeOfSelection {
    case amongPlayers4
    case amongPlayers6
    case amongPlayers8
    case among3Items
    case among4Items
}

class GlobalStuff: NSObject {
    
}
extension String {
    func stringToDate(_ timeZ: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone(identifier: timeZ)
        var date = dateFormatter.date(from: self)
        if dateFormatter.date(from: self) == nil {
            dateFormatter.timeZone = TimeZone(identifier: timeZ)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            date = dateFormatter.date(from: self)
        }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM d @ h:mm a z"
        
        return date!
    }
    func stringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        var date = dateFormatter.date(from: self)
        if dateFormatter.date(from: self) == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = dateFormatter.date(from: self)
        }
        return date!
    }
    func localToUTC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        var dt = dateFormatter.date(from: self)
        if dt == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.calendar = NSCalendar.current
            dateFormatter.timeZone = TimeZone.current
            dt = dateFormatter.date(from: self)
        }
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var dt = dateFormatter.date(from: self)
        if dt == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dt = dateFormatter.date(from: self)
        }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        
        return dateFormatter.string(from: dt!)
    }
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        if isValid(regex: .phone) {
            print(self.onlyDigits())
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options:  [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }else{
                print("can't call")
            }
        }
    }

}

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY hh:mm a"
        let str = dateFormatter.string(from: self)
        return str
    }
    func dateToPostString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        let str = dateFormatter.string(from: self)
        //        if dateFormatter.string(from: self) == nil {
        //            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //            date = dateFormatter.date(from: self)
        //        }
        //        let str = dateFormatter.string(from: self)
        return str
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var nextTime: Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: noo)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var noo: Date {
        return Calendar.current.date(bySetting: .minute, value: 0, of: Calendar.current.date(bySetting: .second, value: 0, of: self)!)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }

}
