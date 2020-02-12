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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, REFrostedViewControllerDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var frostedViewController: REFrostedViewController?
    var navigationController = TNavigationViewController()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Library")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIApplication.shared.statusBarView?.backgroundColor = UIColor.primaryColor()
        UIApplication.shared.statusBarView?.tintColor = .white

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

