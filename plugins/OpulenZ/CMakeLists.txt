INCLUDE(BuildPlugin)

ADD_LIBRARY(adplug STATIC
	adplug/src/opl.h
	adplug/src/fmopl.c
	adplug/src/fmopl.h
	adplug/src/temuopl.cpp
	adplug/src/temuopl.h
)
TARGET_INCLUDE_DIRECTORIES(adplug PRIVATE adplug/src)
TARGET_INCLUDE_DIRECTORIES(adplug SYSTEM INTERFACE adplug/src)

BUILD_PLUGIN(opulenz
	OpulenZ.cpp
	OpulenZ.h
	MOCFILES OpulenZ.h
	EMBEDDED_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.png"
)

TARGET_LINK_LIBRARIES(opulenz adplug)
