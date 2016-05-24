DEBUG = 0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KBMoreMem
KBMoreMem_FILES = Tweak.xm
KBMoreMem_LIBRARIES = jetslammed objcipc

include $(THEOS_MAKE_PATH)/tweak.mk


