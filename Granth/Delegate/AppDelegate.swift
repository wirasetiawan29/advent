//
//  AppDelegate.swift
//  Granth

import UIKit
import IQKeyboardManagerSwift
import REFrostedViewController
import Fabric
import Crashlytics
import CoreData
import GoogleMobileAds
import GoogleSignIn
import Firebase
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, REFrostedViewControllerDelegate, GIDSignInDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var frostedViewController: REFrostedViewController?
    var navigationController = TNavigationViewController()
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Library")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarView?.tintColor = .black

        GIDSignIn.sharedInstance().clientID = "843220621492-p4gsdrelqhhce6kgomjq60kfu4r6gb4m.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if TPreferences.readBoolean(WALKTHROUGH) {
            let vc = SplashViewController(nibName: "SplashViewController", bundle: nil)
            navigationController = TNavigationViewController(rootViewController: vc)
        }
        else {
            let vc = walkthroughViewController(nibName: "walkthroughViewController", bundle: nil)
            navigationController = TNavigationViewController(rootViewController: vc)
        }
        TPreferences.writeString(UDID, value: UIDevice.current.identifierForVendor?.uuidString)
        navigationController.isNavigationBarHidden = true
        self.window? .makeKeyAndVisible()
        let menuController = SideBarMenuViewController(nibName: "SideBarMenuViewController", bundle: nil)
        
        frostedViewController = REFrostedViewController(contentViewController: navigationController, menuViewController: menuController)
        frostedViewController?.direction = .left
        frostedViewController?.liveBlurBackgroundStyle = .light
        frostedViewController?.liveBlur = true
        frostedViewController?.delegate = self
        frostedViewController?.panGestureEnabled = false
        window?.rootViewController = frostedViewController
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        IQKeyboardManager.shared.enable = true
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox: "\(TPreferences.readString(PAYPAL_CLIENT_ID) ?? "")"])
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        
        return true
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       if let error = error {
           if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
               print("The user has not signed in before or they have since signed out.")
           } else {
               print("\(error.localizedDescription)")
           }

           NotificationCenter.default.post(
               name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
           return
       }

           let userId = user.userID
           let idToken = user.authentication.idToken!
           let fullName = user.profile.name
           let givenName = user.profile.givenName
           let familyName = user.profile.familyName
           let email = user.profile.email
           NotificationCenter.default.post(
               name: Notification.Name(rawValue: "ToggleAuthUINotification"),
               object: nil,
               userInfo: ["statusText": "Signed in user:\n\(fullName!)"])

           print("Successfully logged into Google", user!)

           guard let accessToken = user.authentication.accessToken else { return }
           let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

           Auth.auth().signIn(with: credentials, completion: { (user, error) in
               if let err = error {
                   print("Failed to create a Firebase User with Google account: ", err)
                   return
               }

               guard let uid = user?.additionalUserInfo else { return }
               print("Successfully logged into Firebase with Google", uid)
           })
          }

       func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           return GIDSignIn.sharedInstance().handle(url)
       }

       func application(_ application: UIApplication,
                         open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
          return GIDSignIn.sharedInstance().handle(url)
        }

       func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                 withError error: Error!) {
         NotificationCenter.default.post(
           name: Notification.Name(rawValue: "ToggleAuthUINotification"),
           object: nil,
           userInfo: ["statusText": "User has disconnected."])

       }
    
    class func getDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }

    // [START receive_message]
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       // If you are receiving a notification message while your app is in the background,
       // this callback will not be fired till the user taps on the notification launching the application.
       // TODO: Handle data of notification
       // With swizzling disabled you must let Messaging know about the message, for Analytics
       // Messaging.messaging().appDidReceiveMessage(userInfo)
       // Print message ID.
       if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
       }

       // Print full message.
       print(userInfo)
     }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("APNs token retrieved: \(deviceToken)")

      // With swizzling disabled you must set the APNs token here.
      // Messaging.messaging().apnsToken = deviceToken
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")

    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
  // [START ios_10_data_message]
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
  }
  // [END ios_10_data_message]
}
