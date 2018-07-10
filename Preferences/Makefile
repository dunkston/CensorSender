include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CensorSenderPrefs
CensorSenderPrefs_FILES = CensorSenderSettingsController.m
CensorSenderPrefs_INSTALL_PATH = /Library/PreferenceBundles
CensorSenderPrefs_FRAMEWORKS = UIKit
CensorSenderPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CensorSenderPrefs.plist$(ECHO_END)