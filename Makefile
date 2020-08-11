
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.3:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Hazmat
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
