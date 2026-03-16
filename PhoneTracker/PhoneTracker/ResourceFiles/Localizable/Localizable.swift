//
//  Localizable.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import Foundation

struct Localizable {
//    struct Common {
//        static let continueText: String = "common.continue".loc
//        static let save: String = "common.save".loc
//        static let cancel: String = "common.cancel".loc
//        static let delete: String = "common.delete".loc
//        static let ok: String = "common.ok".loc
//        static let name: String = "common.name".loc
//        static let address: String = "common.address".loc
//        static let radius: String = "common.radius".loc
//        static let icon: String = "common.icon".loc
//        static let tryAgain: String = "common.tryAgain".loc
//        static let and: String = "common.and".loc
//        static let week: String = "common.week".loc
//        static let month: String = "common.month".loc
//        static let weekly: String = "common.weekly".loc
//        static let monthly: String = "common.monthly".loc
//        static let annual: String = "common.annual".loc
//        static let year: String = "common.year".loc
//        static let today: String = "common.today".loc
//        static let noData: String = "common.noData".loc
//        static let sos: String = "common.sos".loc
//        static let empty: String = "common.empty".loc
//        static let map: String = "common.map".loc
//    }
//    
//    struct TabBar {
//        static let people: String           = "tabBar.people".loc
//        static let zones: String            = "tabBar.zones".loc
//        static let history: String          = "tabBar.history".loc
//        static let devices: String          = "tabBar.devices".loc
//    }
//    
//    struct People {
//        static let title: String = "people.title".loc
//        static let addPeople: String = "people.addPeople".loc
//        static let joinByCode: String = "people.joinByCode".loc
//        static let rename: String = "people.rename".loc
//        static let remove: String = "people.remove".loc
//        static let inviteFirstMember: String = "people.inviteFirstMember".loc
//        static let editMemberName: String = "people.editMemberName".loc
//        static let invitePeople: String = "people.invitePeople".loc
//        static let shareInviteCode: String = "people.shareInviteCode".loc
//        static let copy: String = "people.copy".loc
//        static let shareCode: String = "people.shareCode".loc
//        static let joinWithCode: String = "people.joinWithCode".loc
//        static let enterCode: String = "people.enterCode".loc
//        static let join: String = "people.join".loc
//    }
//    
//    struct Zones {
//        static let add: String = "zones.add".loc
//        static let edit: String = "zones.edit".loc
//        static let enterName: String = "zones.enterName".loc
//        static let enterAdress: String = "zones.enterAdress".loc
//        static let home: String = "zones.home".loc
//        static let work: String = "zones.work".loc
//        static let shop: String = "zones.shop".loc
//        static let school: String = "zones.school".loc
//        static let addHome: String = "zones.addHome".loc
//        static let addWork: String = "zones.addWork".loc
//        static let addShop: String = "zones.addShop".loc
//        static let addSchool: String = "zones.addSchool".loc
//        static let chooseLocation: String = "zones.chooseLocation".loc
//        static let ready: String = "zones.ready".loc
//    }
//    
//    struct History {
//        static let title: String = "history.title".loc
//        static let trackingTitle: String = "history.trackingTitle".loc
//        static let trackingMessage: String = "history.trackingMessage".loc
//        static let noMovements: String = "history.noMovements".loc
//        static let noLocationData: String = "history.noLocationData".loc
//    }
//    
//    struct Devices {
//        static let title: String = "devices.title".loc
//        static let findAndTrack: String = "devices.findAndTrack".loc
//        static let noDevices: String = "devices.noDevices".loc
//        static let startSearching: String = "devices.startSearching".loc
//        static let scan: String = "devices.scan".loc
//        static let search: String = "devices.search".loc
//        static let searching: String = "devices.searching".loc
//        static let addNew: String = "devices.addNew".loc
//        static let searchResults: String = "devices.searchResults".loc
//        static let name: String = "devices.name".loc
//        static let type: String = "devices.type".loc
//        static let edit: String = "devices.edit".loc
//    }
//    
//    struct Settings {
//        static let title: String = "settings.title".loc
//        static let accesses: String = "settings.accesses".loc
//        static let location: String = "settings.location".loc
//        static let notifications: String = "settings.notifications".loc
//        static let battery: String = "settings.battery".loc
//        static let general: String = "settings.general".loc
//        static let termsOfUse: String = "settings.termsOfUse".loc
//        static let privacyPolicy: String = "settings.privacyPolicy".loc
//        static let feedback: String = "settings.feedback".loc
//        static let deleteAccount: String = "settings.deleteAccount".loc
//        static let goToProfile: String = "settings.goToProfile".loc
//        static let profileImage: String = "settings.profileImage".loc
//        static let takePhoto: String = "settings.takePhoto".loc
//        static let selectFromLibrary: String = "settings.selectFromLibrary".loc
//        static let editProfileName: String = "settings.editProfileName".loc
//        static let deleteAccountWarning: String = "settings.deleteAccountWarning".loc
//    }
//    
//    struct Onboard {
//        static let titles: [String] = [
//            "onboard.first.title1".loc,
//            "onboard.first.title2".loc,
//            "onboard.first.title3".loc,
//            "onboard.first.title4".loc
//        ]
//        
//        static let descriptions: [String] = [
//            "onboard.first.description1".loc,
//            "onboard.first.description2".loc,
//            "onboard.first.description3".loc,
//            "onboard.first.description4".loc
//        ]
//        
//        static let popupPhoneVerification: [String] = [
//            "onboard.second.sendingRequest".loc,
//            "onboard.second.obtainingData".loc,
//            "onboard.second.dataProcessing".loc,
//            "onboard.second.verified".loc
//        ]
//        
//        static let search: String = "onboard.second.search".loc
//        static let chooseFromContacts: String = "onboard.second.chooseFromContacts".loc
//        static let keepSafe: String = "onboard.second.keepSafe".loc
//        static let byContinuing: String = "onboard.second.byContinuing".loc
//        static let enterNumber: String = "onboard.second.enterNumber".loc
//        static let privacyNotice: String = "onboard.second.privacyNotice".loc
//    }
//    
//    struct Offer {
//        static let unlockFullAccess: String = "offer.unlockFullAccess".loc
//        static let getPremium: String = "offer.getPremium".loc
//        static let benefits: String = "offer.benefits".loc
//        static let protectMatters: String = "offer.protectMatters".loc
//        static let restore: String = "offer.restore".loc
//        static let savePercent: String = "offer.savePercent".loc
//        static let mostPopular: String = "offer.mostPopular".loc
//        static let bestValue: String = "offer.bestValue".loc
//        static let cancelAnytime: String = "offer.cancelAnytime".loc
//        
//        static let featuresListTexts: [String] = [
//            "offer.realTimeTracking".loc,
//            "offer.deviceTracking".loc.loc,
//            "offer.fullLocationHistory".loc,
//            "offer.noAds".loc,
//            "offer.unlimitedAlerts".loc,
//            "offer.unlimitedGeozones".loc
//        ]
//    }
//    
//    struct Alert {
//        static let memberDeletion: String = "alert.memberDeletion".loc
//        static let memberDeletionMessage: String = "alert.memberDeletionMessage".loc
//        static let zoneDeletion: String = "alert.zoneDeletion".loc
//        static let zoneDeletionMessage: String = "alert.zoneDeletionMessage".loc
//        static let deviceDeletion: String = "alert.deviceDeletion".loc
//        static let deviceDeletionMessage: String = "alert.deviceDeletionMessage".loc
//    }
//    
//    struct Notification {
//        static let noOneReceive: String = "notification.view.noOneReceive".loc
//        static let invitePeople: String = "notification.view.invitePeople".loc
//        static let sosSentToPeople: String = "notification.view.sosSentToPeople".loc
//        static let clickedByMistake: String = "notification.view.clickedByMistake".loc
//        
//        static let keepTrackingActive: String = "notification.keepTrackingActive".loc
//        static let unlockUnlimitedTracking: String = "notification.unlockUnlimitedTracking".loc
//        static let dontLoseFeatures: String = "notification.dontLoseFeatures".loc
//        static let upgradeForBestExperience: String = "notification.upgradeForBestExperience".loc
//        
//        static let entry: String = "notification.entry".loc
//        static let exit: String = "notification.exit".loc
//        static let sos: String = "notification.sos".loc
//        static let seeLocation: String = "notification.seeLocation".loc
//        
//        struct Day1_1h {
//            static let header: String = keepTrackingActive
//            static let body: String = "notification.body.keepTrackingActive".loc
//        }
//        
//        struct Day1_4h {
//            static let header: String = unlockUnlimitedTracking
//            static let body: String = "notification.body.unlockUnlimitedTracking".loc
//        }
//        
//        struct Day2 {
//            static let header: String = dontLoseFeatures
//            static let body: String = "notification.body.dontLoseFeatures".loc
//        }
//        
//        struct Day7 {
//            static let header: String = upgradeForBestExperience
//            static let body: String = "notification.body.upgradeForBestExperience".loc
//        }
//    }
}
