//
//  MainTabBarController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import KeychainAccess
import UIKit

class MainTabBarController: UITabBarController, FinishesOnboarding, ContentLockable {
    
    var isLockScreenShowing: Bool = false
    var isLockManuallyTriggered: Bool = false
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "Global.AppInstalled") {
            log("App has been run before, will not clear keychain.")
        } else {
            log("App first run, clearing keychain.")
            try! Keychain().removeAll()
            defaults.set(true, forKey: "Global.AppInstalled")
        }
        selectedIndex = 1
        
        // Configure global URL session
        URLSession.shared.configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        URLSession.shared.configuration.timeoutIntervalForRequest = 1.5
        URLSession.shared.configuration.timeoutIntervalForResource = 1.5
        URLSession.shared.configuration.waitsForConnectivity = false
        
        // Set images for tab bar based on iOS version
        if #available(iOS 15.0, *) {
            log("Setting tab bar images for iOS 15 and above.")
            tabBar.items![0].image = UIImage(systemName: "exclamationmark.shield")
            tabBar.items![0].selectedImage = UIImage(systemName: "exclamationmark.shield.fill")
            tabBar.items![1].image = UIImage(systemName: "key")
            tabBar.items![1].selectedImage = UIImage(systemName: "key.fill")
            tabBar.items![2].image = UIImage(systemName: "ellipsis.rectangle")
            tabBar.items![2].selectedImage = UIImage(systemName: "ellipsis.rectangle.fill")
            tabBar.items![3].image = UIImage(systemName: "gearshape")
            tabBar.items![3].selectedImage = UIImage(systemName: "gearshape.fill")
        } else if #available(iOS 14.0, *) {
            log("Setting tab bar images for iOS 14.")
            tabBar.items![0].image = UIImage(named: "Tab.Alerts")
            tabBar.items![0].selectedImage = UIImage(named: "Tab.Alerts.Selected")
            tabBar.items![1].image = UIImage(named: "Tab.Logins")
            tabBar.items![1].selectedImage = UIImage(named: "Tab.Logins.Selected")
            tabBar.items![2].image = UIImage(named: "Tab.Generator")
            tabBar.items![2].selectedImage = UIImage(named: "Tab.Generator.Selected")
            tabBar.items![3].image = UIImage(named: "Tab.Settings")
            tabBar.items![3].selectedImage = UIImage(named: "Tab.Settings.Selected")
        }
        
        // Localization
        viewControllers![0].title = NSLocalizedString("AlertsTab", comment: "Tabs")
        viewControllers![1].title = NSLocalizedString("LoginsTab", comment: "Tabs")
        viewControllers![2].title = NSLocalizedString("GeneratorTab", comment: "Tabs")
        viewControllers![3].title = NSLocalizedString("SettingsTab", comment: "Tabs")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstOpenOperationsDone {
            if defaults.bool(forKey: "Onboarding.Completed") == true {
                log("App first started, onboarding already completed, performing regular startup operations.")
                setUpObservers()
                performSegue(withIdentifier: "ShowMasterPasswordNoAnimation", sender: self)
            } else {
                log("App first started, beginning onboarding.")
                defaults.set(false, forKey: "Onboarding.Completed")
                performSegue(withIdentifier: "ShowOnboarding", sender: self)
            }
            isFirstOpenOperationsDone = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        switch segue.identifier {
        case "ShowOnboarding":
            if let onboardingNavigationController = destinationViewController as? OnboardingNavigationController {
                onboardingNavigationController.finishesOnboardingDelegate = self
            }
            log("Preparations for showing onboarding view completed.")
        case "ShowMasterPassword", "ShowMasterPasswordNoAnimation":
            isLockScreenShowing = true
            if let authenticationViewController = destinationViewController as? AuthenticationViewController {
                authenticationViewController.unlockImmediately = !isLockManuallyTriggered
                authenticationViewController.contentLockableDelegate = self
            }
            log("Preparations for showing authentication view completed.")
        default: break
        }
    }
    
    // MARK: ContentLockable
    
    func lockContent(animated: Bool, useAutoUnlock: Bool = false) {
        log("Locking \(self.className)")
        userProfile = nil
        isLockManuallyTriggered = !useAutoUnlock
        for viewController: UIViewController in viewControllers! {
            lockContentRecursively(viewController, animated: animated)
        }
        if presentedViewController == nil {
            switch animated {
            case true: performSegue(withIdentifier: "ShowMasterPassword", sender: self)
            case false: performSegue(withIdentifier: "ShowMasterPasswordNoAnimation", sender: self)
            }
        } else {
            presentedViewController?.dismiss(animated: false, completion: {
                switch animated {
                case true: self.performSegue(withIdentifier: "ShowMasterPassword", sender: self)
                case false: self.performSegue(withIdentifier: "ShowMasterPasswordNoAnimation", sender: self)
                }
            })
        }
    }
    
    func unlockContent() {
        log("Unlocking \(self.className)")
        isLockScreenShowing = false
        for viewController: UIViewController in viewControllers! {
            unlockContentRecursively(viewController)
        }
    }
    
    // MARK: FinishesOnboarding
    
    func finishOnboarding() {
        log("User has finished onboarding.")
        defaults.set(true, forKey: "Onboarding.Completed")
        log("Configuring default settings.")
        if files.ubiquityIdentityToken != nil {
            log("iCloud is available, turning on iCloud sync by default.")
            log("iCloud is turned off in this build due to some issues.")
            defaults.set(false, forKey: "Feature.iCloudSync")
        } else {
            log("iCloud is not available, turning off iCloud sync by default.")
            defaults.set(false, forKey: "Feature.iCloudSync")
        }
        defaults.set(true, forKey: "Feature.BreachDetection")
        defaults.set(true, forKey: "Feature.BreachDetection.Email")
        defaults.set(true, forKey: "Feature.BreachDetection.Password")
        defaults.set(true, forKey: "Feature.AppLock")
        defaults.set(0, forKey: "Feature.AppLock.Timeout")
        setUpObservers()
        lockContent(animated: true)
    }
    
    // MARK: Helper Functions
    
    func setUpObservers() {
        notifications.addObserver(self, selector: #selector(lockContentWhenResignActive), name: UIScene.didEnterBackgroundNotification, object: nil)
        notifications.addObserver(self, selector: #selector(lockContentWhenBecameActive), name: UIScene.willEnterForegroundNotification, object: nil)
    }
    
    func lockContentRecursively(_ viewController: UIViewController, animated: Bool) {
        if let contentLockDelegate = viewController as? ContentLockable {
            contentLockDelegate.lockContent(animated: animated, useAutoUnlock: !isLockManuallyTriggered)
        }
        if let navigationController = viewController as? UINavigationController {
            for childViewController: UIViewController in navigationController.viewControllers {
                lockContentRecursively(childViewController, animated: animated)
            }
        }
    }
    
    func unlockContentRecursively(_ viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            if let contentLockDelegate = viewController as? ContentLockable {
                contentLockDelegate.unlockContent()
            }
            for childViewController: UIViewController in navigationController.viewControllers {
                unlockContentRecursively(childViewController)
            }
        }
    }
    
    @objc func lockContentWhenResignActive() {
        log("Application has entered background.")
        defaults.set(Int(Date().timeIntervalSince1970), forKey: "Feature.AppLock.LastResignedActive")
        if !isLockScreenShowing {
            if presentingViewController == nil {
                log("Applying lock overlay.")
                performSegue(withIdentifier: "ShowLockOverlay", sender: self)
            } else {
                log("Dismissing presenting \(String(describing: presentingViewController)), then applying lock overlay.")
                dismiss(animated: false) {
                    self.performSegue(withIdentifier: "ShowLockOverlay", sender: self)
                }
            }
        }
    }
    
    @objc func lockContentWhenBecameActive() {
        log("Application has entered foreground.")
        if !isLockScreenShowing {
            if let _ = userProfile {
                log("App has unlocked data, deciding whether or not to lock content or hide overlay only.")
                dismiss(animated: false) {
                    log("App last resigned active: \(defaults.integer(forKey: "Feature.AppLock.LastResignedActive"))")
                    log("App should clear cache: \(defaults.integer(forKey: "Feature.AppLock.LastResignedActive") + defaults.integer(forKey: "Feature.AppLock.Timeout") * 60)")
                    log("Current time: \(Int(Date().timeIntervalSince1970))")
                    if Int(defaults.integer(forKey: "Feature.AppLock.LastResignedActive") + defaults.integer(forKey: "Feature.AppLock.Timeout") * 60) <= Int(Date().timeIntervalSince1970) {
                        self.lockContent(animated: false, useAutoUnlock: true)
                    }
                }
            } else {
                log("App has not been unlocked, locking by default.")
                self.lockContent(animated: false, useAutoUnlock: true)
            }
        }
    }
    
}
