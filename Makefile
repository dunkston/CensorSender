DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CensorSender
CensorSender_FILES = CensorSender.xm

export COPYFILE_DISABLE = 1

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"