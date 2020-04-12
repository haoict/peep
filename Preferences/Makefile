include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = peepPrefs

peepPrefs_FILES = peepRootListController.m $(wildcard SkittyPrefs/*.m)
peepPrefs_INSTALL_PATH = /Library/PreferenceBundles
peepPrefs_FRAMEWORKS = UIKit
peepPrefs_PRIVATE_FRAMEWORKS = Preferences
peepPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/peepPrefs.plist$(ECHO_END)
